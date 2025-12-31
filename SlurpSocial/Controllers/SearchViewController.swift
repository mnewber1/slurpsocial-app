//
//  SearchViewController.swift
//  SlurpSocial
//
//  Search for ramen posts
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Properties

    private var posts: [RamenPost] = []
    private var searchTask: DispatchWorkItem?

    // MARK: - UI Elements

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search restaurants or ramen..."
        sc.searchBar.tintColor = Theme.Colors.primary
        return sc
    }()

    private lazy var filterSegmentedControl: UISegmentedControl = {
        let items = ["All", "Tonkotsu", "Shoyu", "Miso", "Shio"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = Theme.Colors.primary
        sc.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(RamenPostCell.self, forCellReuseIdentifier: "RamenPostCell")
        tv.separatorStyle = .none
        tv.backgroundColor = Theme.Colors.groupedBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = Theme.Colors.tertiaryText
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Search for your favorite ramen"
        label.font = Theme.Typography.headline
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let sublabel = UILabel()
        sublabel.text = "Find restaurants and ramen dishes"
        sublabel.font = Theme.Typography.subheadline
        sublabel.textColor = Theme.Colors.tertiaryText
        sublabel.textAlignment = .center
        sublabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(sublabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Theme.Spacing.lg),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Spacing.xl),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Spacing.xl),

            sublabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Theme.Spacing.sm),
            sublabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Spacing.xl),
            sublabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Spacing.xl),
        ])

        return view
    }()

    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.font = Theme.Typography.headline
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Search"
        view.backgroundColor = Theme.Colors.groupedBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        view.addSubview(filterSegmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(noResultsLabel)

        NSLayoutConstraint.activate([
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.Spacing.sm),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Spacing.lg),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Spacing.lg),

            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: Theme.Spacing.sm),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        updateUI()
    }

    private func updateUI() {
        let hasSearchText = !(searchController.searchBar.text?.isEmpty ?? true)
        emptyStateView.isHidden = hasSearchText || !posts.isEmpty
        noResultsLabel.isHidden = !hasSearchText || !posts.isEmpty
        tableView.isHidden = posts.isEmpty
    }

    // MARK: - Actions

    @objc private func filterChanged() {
        performSearch()
    }

    private func performSearch() {
        // Cancel previous search
        searchTask?.cancel()

        guard let query = searchController.searchBar.text, !query.isEmpty else {
            posts = []
            updateUI()
            tableView.reloadData()
            return
        }

        // Debounce search
        let task = DispatchWorkItem { [weak self] in
            self?.executeSearch(query: query)
        }
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    private func executeSearch(query: String) {
        showLoading(message: "Searching...")

        RamenPostService.shared.searchPosts(query: query) { [weak self] result in
            self?.hideLoading()

            switch result {
            case .success(var foundPosts):
                // Apply filter
                if let brothFilter = self?.getSelectedBrothType() {
                    foundPosts = foundPosts.filter { $0.brothType == brothFilter }
                }
                self?.posts = foundPosts
                self?.updateUI()
                self?.tableView.reloadData()

            case .failure(let error):
                self?.showError(error.localizedDescription)
            }
        }
    }

    private func getSelectedBrothType() -> BrothType? {
        switch filterSegmentedControl.selectedSegmentIndex {
        case 1: return .tonkotsu
        case 2: return .shoyu
        case 3: return .miso
        case 4: return .shio
        default: return nil
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        performSearch()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RamenPostCell", for: indexPath) as? RamenPostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let detailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
}

// MARK: - RamenPostCellDelegate

extension SearchViewController: RamenPostCellDelegate {
    func didTapLike(for post: RamenPost) {
        guard AuthenticationService.shared.isLoggedIn else {
            showError("Please log in to like posts")
            return
        }
        RamenPostService.shared.likePost(post.id)
    }
}
