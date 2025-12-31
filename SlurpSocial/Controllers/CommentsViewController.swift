//
//  CommentsViewController.swift
//  SlurpSocial
//
//  View and add comments on posts
//

import UIKit

class CommentsViewController: UIViewController {

    // MARK: - Properties

    private let post: RamenPost
    private var comments: [Comment] = []

    // MARK: - UI Elements

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tv.separatorInset = UIEdgeInsets(top: 0, left: Theme.Spacing.lg, bottom: 0, right: Theme.Spacing.lg)
        tv.backgroundColor = Theme.Colors.background
        tv.keyboardDismissMode = .interactive
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.borderStyle = .none
        tf.backgroundColor = Theme.Colors.secondaryBackground
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 0))
        tf.rightViewMode = .always
        tf.font = Theme.Typography.body
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = Theme.Colors.primary
        button.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No comments yet.\nBe the first to comment!"
        label.font = Theme.Typography.subheadline
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var inputBottomConstraint: NSLayoutConstraint!

    // MARK: - Init

    init(post: RamenPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        loadComments()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Comments"
        view.backgroundColor = Theme.Colors.background

        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        view.addSubview(emptyStateLabel)

        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendButton)

        // Add separator line
        let separator = UIView()
        separator.backgroundColor = Theme.Colors.secondaryBackground
        separator.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.addSubview(separator)

        inputBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),

            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBottomConstraint,
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),

            separator.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            separator.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            inputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: Theme.Spacing.md),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -Theme.Spacing.sm),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -Theme.Spacing.md),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),

            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Spacing.xl),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Spacing.xl),
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Data

    private func loadComments() {
        showLoading(message: "Loading comments...")

        APIClient.shared.request("/posts/\(post.id.uuidString)/comments") { [weak self] (result: Result<APIResponse<[Comment]>, Error>) in
            self?.hideLoading()

            switch result {
            case .success(let response):
                self?.comments = response.data ?? []
                self?.updateUI()
            case .failure(let error):
                self?.showError(error.localizedDescription)
            }
        }
    }

    private func updateUI() {
        emptyStateLabel.isHidden = !comments.isEmpty
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func sendComment() {
        guard let text = inputTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard AuthenticationService.shared.isLoggedIn else {
            showError("Please log in to comment")
            return
        }

        inputTextField.isEnabled = false
        sendButton.isEnabled = false

        let body = ["content": text]

        Task {
            do {
                let response: APIResponse<Comment> = try await APIClient.shared.request(
                    "/posts/\(post.id.uuidString)/comments",
                    method: .POST,
                    body: body,
                    requiresAuth: true
                )

                await MainActor.run {
                    if let comment = response.data {
                        self.comments.insert(comment, at: 0)
                        self.updateUI()
                        self.inputTextField.text = ""
                    }
                    self.inputTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.inputTextField.resignFirstResponder()
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                    self.inputTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                }
            }
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputBottomConstraint.constant = -keyboardHeight

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        inputBottomConstraint.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let comment = comments[indexPath.row]
        guard let currentUser = AuthenticationService.shared.currentUser,
              comment.userId == currentUser.id || post.userId == currentUser.id else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteComment(at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func deleteComment(at indexPath: IndexPath) {
        let comment = comments[indexPath.row]

        Task {
            do {
                try await APIClient.shared.requestVoid(
                    "/posts/\(post.id.uuidString)/comments/\(comment.id.uuidString)",
                    method: .DELETE,
                    requiresAuth: true
                )

                await MainActor.run {
                    self.comments.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.updateUI()
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return true
    }
}

// MARK: - Comment Model

struct Comment: Codable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let username: String?
    let userDisplayName: String?
    let userProfileImageURL: String?
    let content: String
    let createdAt: Date
}

// MARK: - Comment Cell

class CommentCell: UITableViewCell {

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.backgroundColor = Theme.Colors.secondaryBackground
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = Theme.Colors.tertiaryText
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.subheadline.withTraits(traits: .traitBold)
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.subheadline
        label.textColor = Theme.Colors.text
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.caption2
        label.textColor = Theme.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none

        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.md),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),

            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Theme.Spacing.md),
            usernameLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -Theme.Spacing.sm),

            dateLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),

            contentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Theme.Spacing.xs),
            contentLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.md),
        ])
    }

    func configure(with comment: Comment) {
        usernameLabel.text = comment.userDisplayName ?? comment.username ?? "User"
        contentLabel.text = comment.content

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        dateLabel.text = formatter.localizedString(for: comment.createdAt, relativeTo: Date())

        // Load avatar
        if let urlString = comment.userProfileImageURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.avatarImageView.image = image
                    }
                }
            }.resume()
        }
    }
}

// MARK: - UIFont Extension

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

// MARK: - APIClient Extension for Completion Handler

extension APIClient {
    func request<T: Decodable>(_ endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        Task {
            do {
                let result: T = try await request(endpoint)
                await MainActor.run {
                    completion(.success(result))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
