//
//  LoadingIndicator.swift
//  SlurpSocial
//
//  Reusable loading indicator overlay
//

import UIKit

class LoadingIndicator {
    private static var overlayView: UIView?
    private static var activityIndicator: UIActivityIndicatorView?

    static func show(in view: UIView, message: String? = nil) {
        DispatchQueue.main.async {
            // Remove any existing overlay
            hide()

            // Create overlay
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // Create container
            let container = UIView()
            container.backgroundColor = UIColor.systemBackground
            container.layer.cornerRadius = Theme.CornerRadius.medium
            container.translatesAutoresizingMaskIntoConstraints = false
            Theme.Shadow.applyCard(to: container)

            // Create activity indicator
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = Theme.Colors.primary
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()

            // Create label if message provided
            var messageLabel: UILabel?
            if let message = message {
                let label = UILabel()
                label.text = message
                label.font = Theme.Typography.subheadline
                label.textColor = Theme.Colors.secondaryText
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                messageLabel = label
            }

            // Build hierarchy
            container.addSubview(indicator)
            if let label = messageLabel {
                container.addSubview(label)
            }
            overlay.addSubview(container)
            view.addSubview(overlay)

            // Layout
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
                container.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

                indicator.topAnchor.constraint(equalTo: container.topAnchor, constant: Theme.Spacing.xl),
                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            ])

            if let label = messageLabel {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: Theme.Spacing.md),
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Theme.Spacing.lg),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Theme.Spacing.lg),
                    label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Theme.Spacing.xl),
                ])
            } else {
                indicator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Theme.Spacing.xl).isActive = true
            }

            // Fade in
            overlay.alpha = 0
            Theme.Animation.fadeIn(overlay)

            overlayView = overlay
            activityIndicator = indicator
        }
    }

    static func hide() {
        DispatchQueue.main.async {
            if let overlay = overlayView {
                Theme.Animation.fadeOut(overlay) {
                    overlay.removeFromSuperview()
                }
            }
            overlayView = nil
            activityIndicator = nil
        }
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
    func showLoading(message: String? = nil) {
        LoadingIndicator.show(in: view, message: message)
    }

    func hideLoading() {
        LoadingIndicator.hide()
    }

    func showError(_ message: String, retryAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let retry = retryAction {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                retry()
            })
        }
        present(alert, animated: true)
    }

    func showSuccess(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - Inline Loading for Buttons

extension UIButton {
    private struct AssociatedKeys {
        static var originalTitle: UInt8 = 0
        static var activityIndicator: UInt8 = 1
    }

    func showLoading() {
        isEnabled = false

        // Store original title
        objc_setAssociatedObject(self, &AssociatedKeys.originalTitle, titleLabel?.text, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // Hide title
        setTitle("", for: .normal)

        // Add activity indicator
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        objc_setAssociatedObject(self, &AssociatedKeys.activityIndicator, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func hideLoading() {
        isEnabled = true

        // Restore title
        if let originalTitle = objc_getAssociatedObject(self, &AssociatedKeys.originalTitle) as? String {
            setTitle(originalTitle, for: .normal)
        }

        // Remove activity indicator
        if let indicator = objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}
