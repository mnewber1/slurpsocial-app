//
//  EditProfileViewController.swift
//  SlurpSocial
//
//  Edit user profile
//

import UIKit
import PhotosUI

protocol EditProfileDelegate: AnyObject {
    func didUpdateProfile()
}

class EditProfileViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: EditProfileDelegate?
    private var selectedImage: UIImage?

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.backgroundColor = Theme.Colors.secondaryBackground
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = Theme.Colors.tertiaryText
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        iv.addGestureRecognizer(tap)
        return iv
    }()

    private lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.titleLabel?.font = Theme.Typography.subheadline
        button.setTitleColor(Theme.Colors.primary, for: .normal)
        button.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Display Name"
        label.font = Theme.Typography.subheadline
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var displayNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your display name"
        tf.applyStandardStyle()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio"
        label.font = Theme.Typography.subheadline
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bioTextView: UITextView = {
        let tv = UITextView()
        tv.font = Theme.Typography.body
        tv.backgroundColor = Theme.Colors.secondaryBackground
        tv.layer.cornerRadius = Theme.CornerRadius.medium
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/500"
        label.font = Theme.Typography.caption1
        label.textColor = Theme.Colors.tertiaryText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.applyPrimaryStyle()
        button.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentProfile()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Edit Profile"
        view.backgroundColor = Theme.Colors.background
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(displayNameField)
        contentView.addSubview(bioLabel)
        contentView.addSubview(bioTextView)
        contentView.addSubview(characterCountLabel)
        contentView.addSubview(saveButton)

        bioTextView.delegate = self

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xl),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Theme.Spacing.sm),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            displayNameLabel.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: Theme.Spacing.xl),
            displayNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            displayNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),

            displayNameField.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: Theme.Spacing.sm),
            displayNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            displayNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),
            displayNameField.heightAnchor.constraint(equalToConstant: 50),

            bioLabel.topAnchor.constraint(equalTo: displayNameField.bottomAnchor, constant: Theme.Spacing.lg),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),

            bioTextView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: Theme.Spacing.sm),
            bioTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            bioTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),
            bioTextView.heightAnchor.constraint(equalToConstant: 120),

            characterCountLabel.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: Theme.Spacing.xs),
            characterCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),

            saveButton.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: Theme.Spacing.xl),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xl),
        ])
    }

    private func loadCurrentProfile() {
        guard let user = AuthenticationService.shared.currentUser else { return }

        displayNameField.text = user.displayName
        bioTextView.text = user.bio ?? ""
        updateCharacterCount()

        if let urlString = user.profileImageURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }.resume()
        }
    }

    private func updateCharacterCount() {
        let count = bioTextView.text.count
        characterCountLabel.text = "\(count)/500"
        characterCountLabel.textColor = count > 500 ? Theme.Colors.error : Theme.Colors.tertiaryText
    }

    // MARK: - Actions

    @objc private func cancel() {
        dismiss(animated: true)
    }

    @objc private func changePhoto() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func saveProfile() {
        guard let displayName = displayNameField.text, !displayName.isEmpty else {
            showError("Please enter a display name")
            return
        }

        let bio = bioTextView.text
        if (bio?.count ?? 0) > 500 {
            showError("Bio must be less than 500 characters")
            return
        }

        saveButton.showLoading()

        // TODO: Upload image to server and get URL
        // For now, just update text fields
        AuthenticationService.shared.updateProfile(
            displayName: displayName,
            bio: bio,
            profileImageURL: nil
        ) { [weak self] result in
            self?.saveButton.hideLoading()

            switch result {
            case .success:
                self?.delegate?.didUpdateProfile()
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showError(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCount()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self?.profileImageView.image = image
                    self?.selectedImage = image
                }
            }
        }
    }
}
