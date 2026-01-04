//
//  MapViewController.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var posts: [RamenPost] = []

    private let centerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .systemBackground
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        setupLocationManager()
        loadPosts()

        NotificationCenter.default.addObserver(self, selector: #selector(postsUpdated), name: .postsUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }

    private func setupUI() {
        title = "Ramen Map"
        view.backgroundColor = .systemBackground

        view.addSubview(mapView)
        view.addSubview(centerButton)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        centerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            centerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            centerButton.widthAnchor.constraint(equalToConstant: 50),
            centerButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        centerButton.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "RamenAnnotation")
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func loadPosts() {
        // Remove existing annotations except user location
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)

        // Load posts with location asynchronously
        RamenPostService.shared.getAllPosts { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let allPosts):
                self.posts = allPosts.filter { $0.coordinate != nil }

                // Add annotations
                for post in self.posts {
                    guard let coordinate = post.coordinate else { continue }

                    let annotation = RamenAnnotation(post: post)
                    annotation.coordinate = coordinate
                    annotation.title = post.restaurantName
                    annotation.subtitle = "\(post.ramenName) - \(String(format: "%.1f", post.rating))⭐"
                    self.mapView.addAnnotation(annotation)
                }

                // Zoom to show all annotations if we have any
                if !self.posts.isEmpty {
                    let annotations = self.mapView.annotations.filter { !($0 is MKUserLocation) }
                    self.mapView.showAnnotations(annotations, animated: true)
                }

            case .failure:
                // Silently fail
                self.posts = []
            }
        }
    }

    @objc private func centerOnUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        } else {
            locationManager.requestLocation()
        }
    }

    @objc private func postsUpdated() {
        loadPosts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let ramenAnnotation = annotation as? RamenAnnotation else { return nil }

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "RamenAnnotation", for: annotation) as! MKMarkerAnnotationView
        view.canShowCallout = true
        view.markerTintColor = UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0)
        view.glyphImage = UIImage(systemName: "bowl.fill")

        // Add detail button
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button

        // Add image thumbnail
        if let image = RamenPostService.shared.loadImage(for: ramenAnnotation.post) {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 4
            view.leftCalloutAccessoryView = imageView
        }

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let ramenAnnotation = view.annotation as? RamenAnnotation else { return }

        let detailVC = PostDetailViewController(post: ramenAnnotation.post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if posts.isEmpty {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

// MARK: - RamenAnnotation

class RamenAnnotation: MKPointAnnotation {
    let post: RamenPost

    init(post: RamenPost) {
        self.post = post
        super.init()
    }
}
