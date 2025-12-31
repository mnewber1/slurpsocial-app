//
//  RamenPostCell.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import UIKit

class RamenPostCell: UITableViewCell {

    static let identifier = "RamenPostCell"

    var onLikeTapped: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let ramenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bowl.fill")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let restaurantLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let ramenNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        return stack
    }()

    private let brothTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
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
        contentView.backgroundColor = .systemGroupedBackground

        contentView.addSubview(containerView)
        containerView.addSubview(ramenImageView)
        ramenImageView.addSubview(placeholderImageView)
        containerView.addSubview(restaurantLabel)
        containerView.addSubview(ramenNameLabel)
        containerView.addSubview(ratingStackView)
        containerView.addSubview(brothTypeLabel)
        containerView.addSubview(reviewLabel)
        containerView.addSubview(likeButton)
        containerView.addSubview(likeCountLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(locationLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        ramenImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        restaurantLabel.translatesAutoresizingMaskIntoConstraints = false
        ramenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        brothTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            ramenImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            ramenImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ramenImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ramenImageView.heightAnchor.constraint(equalToConstant: 200),

            placeholderImageView.centerXAnchor.constraint(equalTo: ramenImageView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: ramenImageView.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 60),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 60),

            restaurantLabel.topAnchor.constraint(equalTo: ramenImageView.bottomAnchor, constant: 12),
            restaurantLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            restaurantLabel.trailingAnchor.constraint(equalTo: ratingStackView.leadingAnchor, constant: -8),

            ratingStackView.centerYAnchor.constraint(equalTo: restaurantLabel.centerYAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            ramenNameLabel.topAnchor.constraint(equalTo: restaurantLabel.bottomAnchor, constant: 4),
            ramenNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            ramenNameLabel.trailingAnchor.constraint(equalTo: brothTypeLabel.leadingAnchor, constant: -8),

            brothTypeLabel.centerYAnchor.constraint(equalTo: ramenNameLabel.centerYAnchor),
            brothTypeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            brothTypeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            brothTypeLabel.heightAnchor.constraint(equalToConstant: 20),

            reviewLabel.topAnchor.constraint(equalTo: ramenNameLabel.bottomAnchor, constant: 8),
            reviewLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            reviewLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            likeButton.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            likeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 0),

            dateLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])

        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
    }

    func configure(with post: RamenPost) {
        restaurantLabel.text = post.restaurantName
        ramenNameLabel.text = post.ramenName
        reviewLabel.text = post.review
        likeCountLabel.text = "\(post.likes)"

        // Configure rating stars
        configureRating(post.rating)

        // Configure broth type
        if let broth = post.brothType {
            brothTypeLabel.text = "  \(broth.rawValue)  "
            brothTypeLabel.isHidden = false
        } else {
            brothTypeLabel.isHidden = true
        }

        // Configure image
        if let image = RamenPostService.shared.loadImage(for: post) {
            ramenImageView.image = image
            placeholderImageView.isHidden = true
        } else {
            ramenImageView.image = nil
            placeholderImageView.isHidden = false
        }

        // Configure location
        if let address = post.address {
            locationLabel.text = "📍 \(address)"
            locationLabel.isHidden = false
        } else {
            locationLabel.isHidden = true
        }

        // Configure date
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
                starImageView.tintColor = .systemOrange
            } else if Double(i) - 0.5 <= rating {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = .systemOrange
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .systemGray3
            }

            starImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            ratingStackView.addArrangedSubview(starImageView)
        }
    }

    @objc private func likeTapped() {
        onLikeTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ramenImageView.image = nil
        placeholderImageView.isHidden = false
        onLikeTapped = nil
    }
}
