//
//  Theme.swift
//  SlurpSocial
//
//  Centralized styling and theming
//

import UIKit

enum Theme {

    // MARK: - Colors

    enum Colors {
        static let primary = UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0)       // Ramen Red
        static let primaryDark = UIColor(red: 0.7, green: 0.15, blue: 0.15, alpha: 1.0)  // Darker Red
        static let secondary = UIColor.systemOrange
        static let accent = UIColor(red: 0.95, green: 0.6, blue: 0.3, alpha: 1.0)        // Warm Orange

        static let background = UIColor.systemBackground
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let groupedBackground = UIColor.systemGroupedBackground

        static let text = UIColor.label
        static let secondaryText = UIColor.secondaryLabel
        static let tertiaryText = UIColor.tertiaryLabel

        static let success = UIColor.systemGreen
        static let warning = UIColor.systemYellow
        static let error = UIColor.systemRed

        static let cardBackground = UIColor.systemBackground
        static let cardShadow = UIColor.black.withAlphaComponent(0.1)

        static let starFilled = UIColor.systemOrange
        static let starEmpty = UIColor.systemGray4

        // Tag colors
        static let brothTag = UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1.0)
        static let spiceTag = UIColor.systemOrange
        static let noodleTag = UIColor.systemBrown
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let subheadline = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let round: CGFloat = 9999 // For pills
    }

    // MARK: - Shadow

    enum Shadow {
        static func apply(to view: UIView, opacity: Float = 0.1, radius: CGFloat = 8, offset: CGSize = CGSize(width: 0, height: 4)) {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = opacity
            view.layer.shadowRadius = radius
            view.layer.shadowOffset = offset
            view.layer.masksToBounds = false
        }

        static func applyCard(to view: UIView) {
            apply(to: view, opacity: 0.1, radius: 8, offset: CGSize(width: 0, height: 2))
        }

        static func applyButton(to view: UIView) {
            apply(to: view, opacity: 0.2, radius: 4, offset: CGSize(width: 0, height: 2))
        }
    }

    // MARK: - Animations

    enum Animation {
        static let quick: TimeInterval = 0.15
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5

        static func spring(duration: TimeInterval = 0.5, damping: CGFloat = 0.7, velocity: CGFloat = 0.5, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseInOut, animations: animations, completion: completion)
        }

        static func fadeIn(_ view: UIView, duration: TimeInterval = standard) {
            view.alpha = 0
            UIView.animate(withDuration: duration) {
                view.alpha = 1
            }
        }

        static func fadeOut(_ view: UIView, duration: TimeInterval = standard, completion: (() -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 0
            }) { _ in
                completion?()
            }
        }
    }
}

// MARK: - Button Styling Extensions

extension UIButton {
    func applyPrimaryStyle() {
        backgroundColor = Theme.Colors.primary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Theme.Typography.headline
        layer.cornerRadius = Theme.CornerRadius.medium
        Theme.Shadow.applyButton(to: self)
    }

    func applySecondaryStyle() {
        backgroundColor = .clear
        setTitleColor(Theme.Colors.primary, for: .normal)
        titleLabel?.font = Theme.Typography.headline
        layer.cornerRadius = Theme.CornerRadius.medium
        layer.borderWidth = 2
        layer.borderColor = Theme.Colors.primary.cgColor
    }

    func applyDestructiveStyle() {
        backgroundColor = Theme.Colors.error
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Theme.Typography.headline
        layer.cornerRadius = Theme.CornerRadius.medium
    }
}

// MARK: - TextField Styling Extensions

extension UITextField {
    func applyStandardStyle() {
        borderStyle = .none
        backgroundColor = Theme.Colors.secondaryBackground
        layer.cornerRadius = Theme.CornerRadius.medium
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: Theme.Spacing.lg, height: 0))
        leftViewMode = .always
        font = Theme.Typography.body
    }
}

// MARK: - View Card Styling

extension UIView {
    func applyCardStyle() {
        backgroundColor = Theme.Colors.cardBackground
        layer.cornerRadius = Theme.CornerRadius.medium
        Theme.Shadow.applyCard(to: self)
    }
}
