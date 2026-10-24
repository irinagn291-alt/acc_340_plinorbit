import UIKit

final class ChapterMark: UILabel {
    private let underline = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
        isAccessibilityElement = true
        underline.backgroundColor = DesignTokens.accentUI
        underline.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underline)
        NSLayoutConstraint.activate([
            underline.leadingAnchor.constraint(equalTo: leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 2),
        ])
        setChapter(1)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setChapter(_ chapter: Int) {
        let clamped = min(RestitutionCut.chapterCount, max(1, chapter))
        attributedText = NSAttributedString(
            string: String(format: "%02d", clamped),
            attributes: [
                .font: DomeType.demi(13),
                .foregroundColor: DesignTokens.inkUI,
                .kern: 1.8,
            ]
        )
        accessibilityLabel = "Chapter \(clamped)"
    }
}
