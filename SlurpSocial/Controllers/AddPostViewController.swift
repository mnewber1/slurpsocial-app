//
//  AddPostViewController.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit
import CoreLocation
import PhotosUI

class AddPostViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let locationManager = CLLocationManager()

    private var selectedImage: UIImage?
    private var currentLocation: CLLocation?
    private var currentAddress: String?

    // MARK: - UI Components

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.setTitle(" Add Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .systemBlue
        return button
    }()

    private let restaurantTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Restaurant Name"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .words
        return tf
    }()

    private let ramenNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Ramen Name (e.g., Tonkotsu Special)"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .words
        return tf
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Rating"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let ratingSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 5
        slider.value = 3
        slider.tintColor = .systemOrange
        return slider
    }()

    private let ratingValueLabel: UILabel = {
        let label = UILabel()
        label.text = "3.0 ⭐"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let brothTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Broth Type"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let brothTypePicker: UISegmentedControl = {
        let items = ["Tonkotsu", "Shoyu", "Miso", "Shio", "Other"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let spiceLevelLabel: UILabel = {
        let label = UILabel()
        label.text = "Spice Level"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let spiceLevelPicker: UISegmentedControl = {
        let items = ["None", "Mild", "Medium", "Hot", "🔥"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let noodleTextureLabel: UILabel = {
        let label = UILabel()
        label.text = "Noodle Texture"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let noodleTexturePicker: UISegmentedControl = {
        let items = ["Soft", "Medium", "Firm", "Extra Firm"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1
        return sc
    }()

    private let reviewTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return tv
    }()

    private let reviewPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Write your review..."
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.setTitle(" Add Location", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private let locationStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post Ramen", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        setupActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginStatus()
    }

    private func checkLoginStatus() {
        if !AuthenticationService.shared.isLoggedIn {
            let alert = UIAlertController(title: "Login Required", message: "Please login to post your ramen experience.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.tabBarController?.selectedIndex = 3 // Switch to profile tab
            })
            present(alert, animated: true)
        }
    }

    private func setupUI() {
        title = "Add Ramen"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(addPhotoButton)
        contentView.addSubview(restaurantTextField)
        contentView.addSubview(ramenNameTextField)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(ratingSlider)
        contentView.addSubview(ratingValueLabel)
        contentView.addSubview(brothTypeLabel)
        contentView.addSubview(brothTypePicker)
        contentView.addSubview(spiceLevelLabel)
        contentView.addSubview(spiceLevelPicker)
        contentView.addSubview(noodleTextureLabel)
        contentView.addSubview(noodleTexturePicker)
        contentView.addSubview(reviewTextView)
        reviewTextView.addSubview(reviewPlaceholder)
        contentView.addSubview(locationButton)
        contentView.addSubview(locationStatusLabel)
        contentView.addSubview(postButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        restaurantTextField.translatesAutoresizingMaskIntoConstraints = false
        ramenNameTextField.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingSlider.translatesAutoresizingMaskIntoConstraints = false
        ratingValueLabel.translatesAutoresizingMaskIntoConstraints = false
        brothTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        brothTypePicker.translatesAutoresizingMaskIntoConstraints = false
        spiceLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        spiceLevelPicker.translatesAutoresizingMaskIntoConstraints = false
        noodleTextureLabel.translatesAutoresizingMaskIntoConstraints = false
        noodleTexturePicker.translatesAutoresizingMaskIntoConstraints = false
        reviewTextView.translatesAutoresizingMaskIntoConstraints = false
        reviewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageContainerView.heightAnchor.constraint(equalToConstant: 200),

            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            addPhotoButton.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            addPhotoButton.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),

            restaurantTextField.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 20),
            restaurantTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            restaurantTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            restaurantTextField.heightAnchor.constraint(equalToConstant: 44),

            ramenNameTextField.topAnchor.constraint(equalTo: restaurantTextField.bottomAnchor, constant: 12),
            ramenNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ramenNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ramenNameTextField.heightAnchor.constraint(equalToConstant: 44),

            ratingLabel.topAnchor.constraint(equalTo: ramenNameTextField.bottomAnchor, constant: 20),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            ratingValueLabel.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            ratingValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            ratingSlider.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            ratingSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            brothTypeLabel.topAnchor.constraint(equalTo: ratingSlider.bottomAnchor, constant: 20),
            brothTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            brothTypePicker.topAnchor.constraint(equalTo: brothTypeLabel.bottomAnchor, constant: 8),
            brothTypePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brothTypePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            spiceLevelLabel.topAnchor.constraint(equalTo: brothTypePicker.bottomAnchor, constant: 20),
            spiceLevelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            spiceLevelPicker.topAnchor.constraint(equalTo: spiceLevelLabel.bottomAnchor, constant: 8),
            spiceLevelPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            spiceLevelPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            noodleTextureLabel.topAnchor.constraint(equalTo: spiceLevelPicker.bottomAnchor, constant: 20),
            noodleTextureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            noodleTexturePicker.topAnchor.constraint(equalTo: noodleTextureLabel.bottomAnchor, constant: 8),
            noodleTexturePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noodleTexturePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            reviewTextView.topAnchor.constraint(equalTo: noodleTexturePicker.bottomAnchor, constant: 20),
            reviewTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewTextView.heightAnchor.constraint(equalToConstant: 100),

            reviewPlaceholder.topAnchor.constraint(equalTo: reviewTextView.topAnchor, constant: 12),
            reviewPlaceholder.leadingAnchor.constraint(equalTo: reviewTextView.leadingAnchor, constant: 12),

            locationButton.topAnchor.constraint(equalTo: reviewTextView.bottomAnchor, constant: 16),
            locationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            locationStatusLabel.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 4),
            locationStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            postButton.topAnchor.constraint(equalTo: locationStatusLabel.bottomAnchor, constant: 24),
            postButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 50),
            postButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        reviewTextView.delegate = self
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func setupActions() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        imageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhotoTapped)))
        imageContainerView.isUserInteractionEnabled = true

        ratingSlider.addTarget(self, action: #selector(ratingChanged), for: .valueChanged)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func addPhotoTapped() {
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.presentCamera()
        })

        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Error", message: "Camera not available")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func ratingChanged() {
        let rating = round(ratingSlider.value * 2) / 2 // Round to nearest 0.5
        ratingSlider.value = rating
        ratingValueLabel.text = String(format: "%.1f ⭐", rating)
    }

    @objc private func locationButtonTapped() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showAlert(title: "Location Access Denied", message: "Please enable location access in Settings to add your location.")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            locationButton.setTitle(" Getting location...", for: .normal)
        @unknown default:
            break
        }
    }

    @objc private func postButtonTapped() {
        guard AuthenticationService.shared.isLoggedIn else {
            checkLoginStatus()
            return
        }

        guard let userId = AuthenticationService.shared.currentUser?.id else { return }

        guard let restaurantName = restaurantTextField.text, !restaurantName.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter the restaurant name")
            return
        }

        guard let ramenName = ramenNameTextField.text, !ramenName.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter the ramen name")
            return
        }

        let rating = Double(round(ratingSlider.value * 2) / 2)

        let brothTypes: [BrothType] = [.tonkotsu, .shoyu, .miso, .shio, .other]
        let brothType = brothTypes[brothTypePicker.selectedSegmentIndex]

        let spiceLevels: [SpiceLevel] = [.none, .mild, .medium, .hot, .extreme]
        let spiceLevel = spiceLevels[spiceLevelPicker.selectedSegmentIndex]

        let noodleTextures: [NoodleTexture] = [.soft, .medium, .firm, .extraFirm]
        let noodleTexture = noodleTextures[noodleTexturePicker.selectedSegmentIndex]

        let review = reviewTextView.text.isEmpty || reviewTextView.text == "Write your review..." ? nil : reviewTextView.text

        let post = RamenPost(
            userId: userId,
            restaurantName: restaurantName,
            ramenName: ramenName,
            rating: rating,
            review: review,
            latitude: currentLocation?.coordinate.latitude,
            longitude: currentLocation?.coordinate.longitude,
            address: currentAddress,
            brothType: brothType,
            spiceLevel: spiceLevel,
            noodleTexture: noodleTexture
        )

        postButton.isEnabled = false
        postButton.setTitle("Posting...", for: .normal)

        RamenPostService.shared.createPost(post, image: selectedImage) { [weak self] result in
            DispatchQueue.main.async {
                self?.postButton.isEnabled = true
                self?.postButton.setTitle("Post Ramen", for: .normal)

                switch result {
                case .success:
                    self?.resetForm()
                    self?.tabBarController?.selectedIndex = 0 // Switch to feed
                    self?.showAlert(title: "Success", message: "Your ramen post has been shared!")
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func resetForm() {
        selectedImage = nil
        imageView.image = nil
        addPhotoButton.isHidden = false
        restaurantTextField.text = ""
        ramenNameTextField.text = ""
        ratingSlider.value = 3
        ratingValueLabel.text = "3.0 ⭐"
        brothTypePicker.selectedSegmentIndex = 0
        spiceLevelPicker.selectedSegmentIndex = 0
        noodleTexturePicker.selectedSegmentIndex = 1
        reviewTextView.text = ""
        reviewPlaceholder.isHidden = false
        currentLocation = nil
        currentAddress = nil
        locationStatusLabel.text = ""
        locationButton.setTitle(" Add Location", for: .normal)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        reviewPlaceholder.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        reviewPlaceholder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            selectedImage = image
            imageView.image = image
            addPhotoButton.isHidden = true
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AddPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.selectedImage = image
                    self?.imageView.image = image
                    self?.addPhotoButton.isHidden = true
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension AddPostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentLocation = location
        locationButton.setTitle(" Location Added ✓", for: .normal)

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                var addressParts: [String] = []
                if let name = placemark.name { addressParts.append(name) }
                if let city = placemark.locality { addressParts.append(city) }
                if let state = placemark.administrativeArea { addressParts.append(state) }

                self?.currentAddress = addressParts.joined(separator: ", ")
                self?.locationStatusLabel.text = "📍 \(self?.currentAddress ?? "")"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationButton.setTitle(" Add Location", for: .normal)
        showAlert(title: "Location Error", message: "Could not get your location. Please try again.")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
            locationButton.setTitle(" Getting location...", for: .normal)
        }
    }
}
