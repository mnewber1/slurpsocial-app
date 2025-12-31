//
//  PostDetailViewController.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit
import MapKit

class PostDetailViewController: UIViewController {

    private let post: RamenPost
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let placeholderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bowl.fill")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let restaurantLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let ramenNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let ratingView = UIStackView()

    private let attributesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()

    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 12
        map.isUserInteractionEnabled = true
        return map
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()

    init(post: RamenPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = post.restaurantName

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(imageView)
        imageView.addSubview(placeholderImageView)
        contentView.addSubview(restaurantLabel)
        contentView.addSubview(ramenNameLabel)
        contentView.addSubview(ratingView)
        contentView.addSubview(attributesStackView)
        contentView.addSubview(reviewLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(dateLabel)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        restaurantLabel.translatesAutoresizingMaskIntoConstraints = false
        ramenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        attributesStackView.translatesAutoresizingMaskIntoConstraints = false
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingView.axis = .horizontal
        ratingView.spacing = 4

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            placeholderImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            restaurantLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            restaurantLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            restaurantLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            ramenNameLabel.topAnchor.constraint(equalTo: restaurantLabel.bottomAnchor, constant: 4),
            ramenNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ramenNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            ratingView.topAnchor.constraint(equalTo: ramenNameLabel.bottomAnchor, constant: 12),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            attributesStackView.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 12),
            attributesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            attributesStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            reviewLabel.topAnchor.constraint(equalTo: attributesStackView.bottomAnchor, constant: 16),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            mapView.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 150),

            addressLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func configureContent() {
        restaurantLabel.text = post.restaurantName
        ramenNameLabel.text = post.ramenName
        reviewLabel.text = post.review ?? "No review provided."

        // Image
        if let image = RamenPostService.shared.loadImage(for: post) {
            imageView.image = image
            placeholderImageView.isHidden = true
        }

        // Rating
        configureRating()

        // Attributes
        configureAttributes()

        // Map
        configureMap()

        // Date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = "Posted \(formatter.string(from: post.createdAt))"
    }

    private func configureRating() {
        for i in 1...5 {
            let star = UIImageView()
            star.contentMode = .scaleAspectFit

            if Double(i) <= post.rating {
                star.image = UIImage(systemName: "star.fill")
                star.tintColor = .systemOrange
            } else if Double(i) - 0.5 <= post.rating {
                star.image = UIImage(systemName: "star.leadinghalf.filled")
                star.tintColor = .systemOrange
            } else {
                star.image = UIImage(systemName: "star")
                star.tintColor = .systemGray3
            }

            star.widthAnchor.constraint(equalToConstant: 24).isActive = true
            star.heightAnchor.constraint(equalToConstant: 24).isActive = true
            ratingView.addArrangedSubview(star)
        }

        let ratingLabel = UILabel()
        ratingLabel.text = String(format: "%.1f", post.rating)
        ratingLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        ratingLabel.textColor = .label
        ratingView.addArrangedSubview(ratingLabel)
    }

    private func configureAttributes() {
        if let broth = post.brothType {
            let tag = createTag(text: broth.rawValue, color: UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0))
            attributesStackView.addArrangedSubview(tag)
        }

        if let spice = post.spiceLevel {
            let tag = createTag(text: spice.displayName, color: .systemOrange)
            attributesStackView.addArrangedSubview(tag)
        }

        if let noodle = post.noodleTexture {
            let tag = createTag(text: noodle.rawValue, color: .systemBrown)
            attributesStackView.addArrangedSubview(tag)
        }
    }

    private func createTag(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = "  \(text)  "
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = color
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }

    private func configureMap() {
        guard let coordinate = post.coordinate else {
            mapView.isHidden = true
            return
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = post.restaurantName
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: false)

        if let address = post.address {
            addressLabel.text = "📍 \(address)"
        } else {
            addressLabel.isHidden = true
        }
    }
}
