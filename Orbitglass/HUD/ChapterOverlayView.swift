import UIKit

final class ChapterOverlayView: UIView {
    var onContinue: (() -> Void)?
    private let titleLabel = UILabel()
    private let captionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignTokens.shadowUI.withAlphaComponent(0.78)
        titleLabel.font = DomeType.bold(34)
        titleLabel.textColor = DesignTokens.inkUI
        titleLabel.textAlignment = .center

        captionLabel.font = DomeType.regular(16)
        captionLabel.textColor = DesignTokens.mutedUI
        captionLabel.textAlignment = .center
        captionLabel.numberOfLines = 0

        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = "Continue"
        config.baseBackgroundColor = DesignTokens.accentUI
        config.baseForegroundColor = DesignTokens.bgUI
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = DomeType.demi(16)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, captionLabel, button])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])
        setChapter(2)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setChapter(_ chapter: Int) {
        let clamped = min(RestitutionCut.chapterCount, max(1, chapter))
        let titles = ["Glass Lip", "Warm Pins", "Pale Weather", "Last Pocket"]
        let lines = [
            "Tap releases the glass. Hold aims, and the next bounce dies sooner.",
            "A full tilt can miss the pocket. Keep the board level when the lane is open.",
            "An untilted bounce still clears a peg. Spend the tilt only to steer.",
            "Light every star, then take the center pocket.",
        ]
        titleLabel.text = titles[clamped - 1]
        captionLabel.text = lines[clamped - 1]
        titleLabel.accessibilityLabel = "Chapter \(clamped). \(titles[clamped - 1])"
    }

    @objc private func continueTapped() { onContinue?() }
}
