import UIKit

final class PauseOverlayView: UIView {
    var onResume: (() -> Void)?
    var onRecords: (() -> Void)?
    var onSettings: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignTokens.shadowUI.withAlphaComponent(0.72)
        let title = UILabel()
        title.text = "Paused"
        title.font = DomeType.bold(32)
        title.textColor = DesignTokens.inkUI
        title.textAlignment = .center

        let caption = UILabel()
        caption.text = "The dome holds."
        caption.font = DomeType.regular(15)
        caption.textColor = DesignTokens.mutedUI
        caption.textAlignment = .center

        let resume = pill("Resume", filled: true)
        let records = pill("Records", filled: false)
        let settings = pill("Settings", filled: false)
        resume.addTarget(self, action: #selector(resumeTapped), for: .touchUpInside)
        records.addTarget(self, action: #selector(recordsTapped), for: .touchUpInside)
        settings.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, caption, resume, records, settings])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.setCustomSpacing(8, after: title)
        stack.setCustomSpacing(22, after: caption)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            resume.heightAnchor.constraint(equalToConstant: 48),
            records.heightAnchor.constraint(equalToConstant: 48),
            settings.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func pill(_ title: String, filled: Bool) -> UIButton {
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
        button.layer.borderColor = DesignTokens.mutedUI.withAlphaComponent(0.5).cgColor
        button.layer.cornerRadius = 24
        return button
    }

    @objc private func resumeTapped() { onResume?() }
    @objc private func recordsTapped() { onRecords?() }
    @objc private func settingsTapped() { onSettings?() }
}
