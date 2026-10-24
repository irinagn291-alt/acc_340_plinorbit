import UIKit

final class SettingsSheetViewController: UIViewController {
    private let store: RunRecordStore
    private let status = UILabel()

    init(store: RunRecordStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.bgUI
        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(close)
        )
        navigationItem.rightBarButtonItem?.tintColor = DesignTokens.accentUI

        let heading = UILabel()
        heading.text = "ORBITGLASS"
        heading.font = DomeType.demi(12)
        heading.textColor = DesignTokens.accentUI
        let titleLabel = UILabel()
        titleLabel.text = "On this device"
        titleLabel.font = DomeType.bold(28)
        titleLabel.textColor = DesignTokens.inkUI
        let caption = UILabel()
        caption.text = "Best score and chapter stay here. Nothing is wagered."
        caption.font = DomeType.regular(16)
        caption.textColor = DesignTokens.mutedUI
        caption.numberOfLines = 0

        status.font = DomeType.regular(14)
        status.textColor = DesignTokens.inkUI
        status.numberOfLines = 0
        status.text = " "

        let contact = button("Contact", filled: true, action: #selector(openContact))
        let reset = button("Reset", filled: false, action: #selector(resetScores))

        let stack = UIStackView(arrangedSubviews: [heading, titleLabel, caption, contact, reset, status])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(6, after: heading)
        stack.setCustomSpacing(18, after: caption)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contact.heightAnchor.constraint(equalToConstant: 48),
            reset.heightAnchor.constraint(equalToConstant: 48),
        ])
        let headingText = NSAttributedString(
            string: "ORBITGLASS",
            attributes: [
                .font: DomeType.demi(12),
                .foregroundColor: DesignTokens.accentUI,
                .kern: 2.0,
            ]
        )
        heading.attributedText = headingText
    }

    private func button(_ title: String, filled: Bool, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = title
        config.baseBackgroundColor = filled ? DesignTokens.accentUI : DesignTokens.surfaceUI
        config.baseForegroundColor = filled ? DesignTokens.bgUI : DesignTokens.inkUI
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = DomeType.demi(16)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.layer.borderWidth = filled ? 0 : 1
        button.layer.borderColor = DesignTokens.mutedUI.withAlphaComponent(0.45).cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func openContact() {
        guard let url = URL(string: "https://orbitglass-dome.pro/contact-us") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func resetScores() {
        store.resetAllData()
        status.text = "Scores cleared."
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
