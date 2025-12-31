//
//  FeedViewController.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit

class FeedViewController: UIViewController {

    // MARK: - Properties

    private var posts: [RamenPost] = []
    private var isLoading = false
    private var currentSortOption: SortOption = .newest

    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case topRated = "Top Rated"
        case mostLiked = "Most Liked"
    }

    // MARK: - UI Elements

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(RamenPostCell.self, forCellReuseIdentifier: RamenPostCell.identifier)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 400
        tv.separatorStyle = .none
        tv.backgroundColor = Theme.Colors.groupedBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Theme.Colors.primary
        rc.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        return rc
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "bowl.fill"))
        imageView.tintColor = Theme.Colors.tertiaryText
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "No ramen posts yet!"
        label.font = Theme.Typography.headline
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let sublabel = UILabel()
        sublabel.text = "Be the first to share your bowl"
        sublabel.font = Theme.Typography.subheadline
        sublabel.textColor = Theme.Colors.tertiaryText
        sublabel.textAlignment = .center
        sublabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(sublabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Theme.Spacing.lg),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            sublabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Theme.Spacing.sm),
            sublabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPosts()

        NotificationCenter.default.addObserver(self, selector: #selector(postsDidUpdate), name: .postsUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Soft refresh on appear
        if !posts.isEmpty {
            loadPosts(showLoading: false)
        }
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Slurp Social"
        view.backgroundColor = Theme.Colors.groupedBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = Theme.Colors.primary

        // Sort button
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(showSortOptions))
        navigationItem.rightBarButtonItem = sortButton

        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        tableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Data Loading

    private func loadPosts(showLoading: Bool = true) {
        guard !isLoading else { return }
        isLoading = true

        if showLoading && posts.isEmpty {
            self.showLoading(message: "Loading posts...")
        }

        RamenPostService.shared.getAllPosts { [weak self] result in
            self?.isLoading = false
            self?.hideLoading()
            self?.refreshControl.endRefreshing()

            switch result {
            case .success(var fetchedPosts):
                // Apply sort
                self?.sortPosts(&fetchedPosts)
                self?.posts = fetchedPosts
                self?.updateUI()

            case .failure(let error):
                if self?.posts.isEmpty ?? true {
                    self?.showError(error.localizedDescription) {
                        self?.loadPosts()
                    }
                }
            }
        }
    }

    private func sortPosts(_ posts: inout [RamenPost]) {
        switch currentSortOption {
        case .newest:
            posts.sort { $0.createdAt > $1.createdAt }
        case .topRated:
            posts.sort { $0.rating > $1.rating }
        case .mostLiked:
            posts.sort { $0.likes > $1.likes }
        }
    }

    private func updateUI() {
        emptyStateView.isHidden = !posts.isEmpty
        tableView.isHidden = posts.isEmpty
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func refreshPosts() {
        loadPosts(showLoading: false)
    }

    @objc private func postsDidUpdate() {
        loadPosts(showLoading: false)
    }

    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)

        for option in SortOption.allCases {
            let action = UIAlertAction(title: option.rawValue, style: .default) { [weak self] _ in
                self?.currentSortOption = option
                var sorted = self?.posts ?? []
                self?.sortPosts(&sorted)
                self?.posts = sorted
                self?.tableView.reloadData()
            }

            if option == currentSortOption {
                action.setValue(true, forKey: "checked")
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RamenPostCell.identifier, for: indexPath) as? RamenPostCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]
        cell.configure(with: post)
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let post = posts[indexPath.row]
        let detailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - RamenPostCellDelegate

extension FeedViewController: RamenPostCellDelegate {
    func didTapLike(for post: RamenPost) {
        guard AuthenticationService.shared.isLoggedIn else {
            showError("Please log in to like posts")
            return
        }

        RamenPostService.shared.likePost(post.id) { [weak self] result in
            if case .success = result {
                self?.loadPosts(showLoading: false)
            }
        }
    }

    func didTapComment(for post: RamenPost) {
        let commentsVC = CommentsViewController(post: post)
        navigationController?.pushViewController(commentsVC, animated: true)
    }

    func didTapBookmark(for post: RamenPost) {
        guard AuthenticationService.shared.isLoggedIn else {
            showError("Please log in to bookmark posts")
            return
        }

        // TODO: Implement bookmark toggle
        showSuccess("Bookmarked!")
    }
}
