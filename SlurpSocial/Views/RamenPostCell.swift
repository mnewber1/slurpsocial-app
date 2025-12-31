//
//  RamenPostCell.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit

protocol RamenPostCellDelegate: AnyObject {
    func didTapLike(for post: RamenPost)
    func didTapBookmark(for post: RamenPost)
    func didTapComment(for post: RamenPost)
}

extension RamenPostCellDelegate {
    func didTapBookmark(for post: RamenPost) {}
    func didTapComment(for post: RamenPost) {}
}

class RamenPostCell: UITableViewCell {

    static let identifier = "RamenPostCell"

    weak var delegate: RamenPostCellDelegate?
    private var post: RamenPost?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.cardBackground
        view.layer.cornerRadius = Theme.CornerRadius.medium
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let ramenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Theme.CornerRadius.medium
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.backgroundColor = Theme.Colors.secondaryBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bowl.fill")
        imageView.tintColor = Theme.Colors.tertiaryText
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let restaurantLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.headline
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ramenNameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.subheadline
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let brothTypeLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.caption1
        label.textColor = .white
        label.backgroundColor = Theme.Colors.brothTag
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.subheadline
        label.textColor = Theme.Colors.text
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.caption1
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var actionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Theme.Spacing.lg
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = Theme.Colors.error
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        return button
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Typography.caption1
        label.textColor = Theme.Colors.secondaryText
        return label
    }()

    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        button.tintColor = Theme.Colors.primary
        button.addTarget(self, action: #selector(commentTapped), for: .touchUpInside)
        return button
    }()

    private lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = Theme.Colors.secondary
        button.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        return button
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
        backgroundColor = .clear
        contentView.backgroundColor = Theme.Colors.groupedBackground

        contentView.addSubview(containerView)
        containerView.addSubview(ramenImageView)
        ramenImageView.addSubview(placeholderImageView)
        containerView.addSubview(restaurantLabel)
        containerView.addSubview(ramenNameLabel)
        containerView.addSubview(ratingStackView)
        containerView.addSubview(brothTypeLabel)
        containerView.addSubview(reviewLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(actionStackView)
        containerView.addSubview(dateLabel)

        // Action stack items
        let likeStack = createActionItem(button: likeButton, label: likeCountLabel)
        actionStackView.addArrangedSubview(likeStack)
        actionStackView.addArrangedSubview(commentButton)
        actionStackView.addArrangedSubview(bookmarkButton)

        Theme.Shadow.applyCard(to: containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.sm),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.sm),

            ramenImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            ramenImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ramenImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ramenImageView.heightAnchor.constraint(equalToConstant: 200),

            placeholderImageView.centerXAnchor.constraint(equalTo: ramenImageView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: ramenImageView.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 60),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 60),

            restaurantLabel.topAnchor.constraint(equalTo: ramenImageView.bottomAnchor, constant: Theme.Spacing.md),
            restaurantLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            restaurantLabel.trailingAnchor.constraint(equalTo: ratingStackView.leadingAnchor, constant: -Theme.Spacing.sm),

            ratingStackView.centerYAnchor.constraint(equalTo: restaurantLabel.centerYAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            ramenNameLabel.topAnchor.constraint(equalTo: restaurantLabel.bottomAnchor, constant: Theme.Spacing.xs),
            ramenNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            ramenNameLabel.trailingAnchor.constraint(equalTo: brothTypeLabel.leadingAnchor, constant: -Theme.Spacing.sm),

            brothTypeLabel.centerYAnchor.constraint(equalTo: ramenNameLabel.centerYAnchor),
            brothTypeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            brothTypeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            brothTypeLabel.heightAnchor.constraint(equalToConstant: 22),

            reviewLabel.topAnchor.constraint(equalTo: ramenNameLabel.bottomAnchor, constant: Theme.Spacing.sm),
            reviewLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            reviewLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            locationLabel.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: Theme.Spacing.sm),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            actionStackView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: Theme.Spacing.md),
            actionStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.sm),
            actionStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.Spacing.md),

            dateLabel.centerYAnchor.constraint(equalTo: actionStackView.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
        ])
    }

    private func createActionItem(button: UIButton, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [button, label])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }

    func configure(with post: RamenPost) {
        self.post = post

        restaurantLabel.text = post.restaurantName
        ramenNameLabel.text = post.ramenName
        reviewLabel.text = post.review
        reviewLabel.isHidden = post.review?.isEmpty ?? true
        likeCountLabel.text = "\(post.likes)"

        configureRating(post.rating)

        if let broth = post.brothType {
            brothTypeLabel.text = "  \(broth.rawValue)  "
            brothTypeLabel.isHidden = false
        } else {
            brothTypeLabel.isHidden = true
        }

        // Load image async
        placeholderImageView.isHidden = false
        ramenImageView.image = nil

        RamenPostService.shared.loadImage(for: post) { [weak self] image in
            if let image = image {
                self?.ramenImageView.image = image
                self?.placeholderImageView.isHidden = true
            }
        }

        if let address = post.address {
            locationLabel.text = "📍 \(address)"
            locationLabel.isHidden = false
        } else {
            locationLabel.isHidden = true
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        dateLabel.text = formatter.localizedString(for: post.createdAt, relativeTo: Date())
    }

    private func configureRating(_ rating: Double) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit

            if Double(i) <= rating {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = Theme.Colors.starFilled
            } else if Double(i) - 0.5 <= rating {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = Theme.Colors.starFilled
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = Theme.Colors.starEmpty
            }

            starImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            ratingStackView.addArrangedSubview(starImageView)
        }
    }

    // MARK: - Actions

    @objc private func likeTapped() {
        guard let post = post else { return }

        // Animate
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        }

        delegate?.didTapLike(for: post)
    }

    @objc private func commentTapped() {
        guard let post = post else { return }
        delegate?.didTapComment(for: post)
    }

    @objc private func bookmarkTapped() {
        guard let post = post else { return }

        // Animate
        UIView.animate(withDuration: 0.1, animations: {
            self.bookmarkButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.bookmarkButton.transform = .identity
            }
        }

        delegate?.didTapBookmark(for: post)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ramenImageView.image = nil
        placeholderImageView.isHidden = false
        post = nil
        delegate = nil
    }
}
