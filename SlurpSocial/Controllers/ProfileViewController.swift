//
//  ProfileViewController.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit

class ProfileViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var userPosts: [RamenPost] = []

    // MARK: - UI Components

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 50
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .systemGray3
        return iv
    }()

    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()

    private let ramenCountView = StatView()
    private let joinDateView = StatView()

    private let postsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "My Ramen Posts"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        return cv
    }()

    private let loginPromptView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let loginPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to view your profile\nand share your ramen adventures!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private let logoutButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Logout", style: .plain, target: nil, action: nil)
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()

        NotificationCenter.default.addObserver(self, selector: #selector(authStateChanged), name: .authStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postsUpdated), name: .postsUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground

        logoutButton.target = self
        logoutButton.action = #selector(logoutTapped)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(statsStackView)
        statsStackView.addArrangedSubview(ramenCountView)
        statsStackView.addArrangedSubview(joinDateView)
        contentView.addSubview(postsHeaderLabel)
        contentView.addSubview(collectionView)

        view.addSubview(loginPromptView)
        loginPromptView.addSubview(loginPromptLabel)
        loginPromptView.addSubview(loginButton)
        loginPromptView.addSubview(signUpButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        postsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        loginPromptView.translatesAutoresizingMaskIntoConstraints = false
        loginPromptLabel.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false

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

            profileImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            displayNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            displayNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            displayNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            usernameLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            statsStackView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20),
            statsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            statsStackView.widthAnchor.constraint(equalToConstant: 200),

            postsHeaderLabel.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 24),
            postsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            collectionView.topAnchor.constraint(equalTo: postsHeaderLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 400),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Login prompt
            loginPromptView.topAnchor.constraint(equalTo: view.topAnchor),
            loginPromptView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginPromptView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginPromptView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loginPromptLabel.centerXAnchor.constraint(equalTo: loginPromptView.centerXAnchor),
            loginPromptLabel.centerYAnchor.constraint(equalTo: loginPromptView.centerYAnchor, constant: -60),
            loginPromptLabel.leadingAnchor.constraint(equalTo: loginPromptView.leadingAnchor, constant: 40),
            loginPromptLabel.trailingAnchor.constraint(equalTo: loginPromptView.trailingAnchor, constant: -40),

            loginButton.topAnchor.constraint(equalTo: loginPromptLabel.bottomAnchor, constant: 24),
            loginButton.centerXAnchor.constraint(equalTo: loginPromptView.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            signUpButton.centerXAnchor.constraint(equalTo: loginPromptView.centerXAnchor)
        ])

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RamenGridCell.self, forCellWithReuseIdentifier: RamenGridCell.identifier)
    }

    private func updateUI() {
        let isLoggedIn = AuthenticationService.shared.isLoggedIn

        scrollView.isHidden = !isLoggedIn
        loginPromptView.isHidden = isLoggedIn
        navigationItem.rightBarButtonItem = isLoggedIn ? logoutButton : nil

        if let user = AuthenticationService.shared.currentUser {
            displayNameLabel.text = user.displayName
            usernameLabel.text = "@\(user.username)"
            bioLabel.text = user.bio ?? "Ramen enthusiast 🍜"

            ramenCountView.configure(value: "\(user.ramenCount)", label: "Bowls")

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            joinDateView.configure(value: formatter.string(from: user.joinDate), label: "Joined")

            loadUserPosts(userId: user.id)
        }
    }

    private func loadUserPosts(userId: UUID) {
        userPosts = RamenPostService.shared.getPostsForUser(userId: userId)
        collectionView.reloadData()
    }

    // MARK: - Actions

    @objc private func loginTapped() {
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        present(nav, animated: true)
    }

    @objc private func signUpTapped() {
        let signUpVC = SignUpViewController()
        let nav = UINavigationController(rootViewController: signUpVC)
        present(nav, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            AuthenticationService.shared.logout()
        })
        present(alert, animated: true)
    }

    @objc private func authStateChanged() {
        updateUI()
    }

    @objc private func postsUpdated() {
        if let userId = AuthenticationService.shared.currentUser?.id {
            loadUserPosts(userId: userId)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RamenGridCell.identifier, for: indexPath) as? RamenGridCell else {
            return UICollectionViewCell()
        }

        let post = userPosts[indexPath.item]
        cell.configure(with: post)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 4) / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = userPosts[indexPath.item]
        let detailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - StatView

class StatView: UIView {
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(valueLabel)
        addSubview(titleLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(value: String, label: String) {
        valueLabel.text = value
        titleLabel.text = label
    }
}

// MARK: - RamenGridCell

class RamenGridCell: UICollectionViewCell {
    static let identifier = "RamenGridCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let placeholderView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bowl.fill")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.addSubview(placeholderView)
        contentView.addSubview(ratingLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            placeholderView.widthAnchor.constraint(equalToConstant: 30),
            placeholderView.heightAnchor.constraint(equalToConstant: 30),

            ratingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            ratingLabel.widthAnchor.constraint(equalToConstant: 32),
            ratingLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with post: RamenPost) {
        if let image = RamenPostService.shared.loadImage(for: post) {
            imageView.image = image
            placeholderView.isHidden = true
        } else {
            imageView.image = nil
            placeholderView.isHidden = false
        }

        ratingLabel.text = " \(String(format: "%.1f", post.rating))⭐ "
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        placeholderView.isHidden = false
    }
}
