import UIKit

final class TopGaugeBarView: UIView {
    let chapterMark = ChapterMark()
    let pauseButton = UIButton(type: .custom)
    private let scoreLabel = UILabel()
    private let goalLabel = UILabel()
    private let track = UIView()
    private let fill = UIView()
    private var fillWidth: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignTokens.surfaceUI.withAlphaComponent(0.94)

        scoreLabel.font = DomeType.digits(16)
        scoreLabel.textColor = DesignTokens.inkUI
        scoreLabel.textAlignment = .right
        scoreLabel.text = "0"

        goalLabel.font = DomeType.regular(12)
        goalLabel.textColor = DesignTokens.mutedUI
        goalLabel.text = "Light every star. Tap drops, hold aims."
        goalLabel.adjustsFontSizeToFitWidth = true
        goalLabel.minimumScaleFactor = 0.75

        track.backgroundColor = DesignTokens.bgUI
        track.layer.cornerRadius = 1.5
        fill.backgroundColor = DesignTokens.accentUI
        fill.layer.cornerRadius = 1.5

        pauseButton.accessibilityLabel = "Pause"
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        let glyph = PauseGlyphView()
        glyph.translatesAutoresizingMaskIntoConstraints = false
        glyph.isUserInteractionEnabled = false
        pauseButton.addSubview(glyph)

        let row = UIStackView(arrangedSubviews: [chapterMark, scoreLabel, pauseButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        track.translatesAutoresizingMaskIntoConstraints = false
        fill.translatesAutoresizingMaskIntoConstraints = false
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        chapterMark.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        addSubview(track)
        track.addSubview(fill)
        addSubview(goalLabel)

        let width = fill.widthAnchor.constraint(equalToConstant: 0)
        fillWidth = width
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            row.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4),
            chapterMark.widthAnchor.constraint(equalToConstant: 36),
            chapterMark.heightAnchor.constraint(equalToConstant: 22),
            pauseButton.widthAnchor.constraint(equalToConstant: 44),
            pauseButton.heightAnchor.constraint(equalToConstant: 44),
            glyph.centerXAnchor.constraint(equalTo: pauseButton.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 16),
            glyph.heightAnchor.constraint(equalToConstant: 16),
            track.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            track.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            track.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 2),
            track.heightAnchor.constraint(equalToConstant: 3),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            width,
            goalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            goalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            goalLabel.topAnchor.constraint(equalTo: track.bottomAnchor, constant: 4),
            goalLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func render(score: Int, chapter: Int, lit: Int, goal: Int) {
        scoreLabel.text = "\(score)"
        chapterMark.setChapter(chapter)
        let total = max(goal, 1)
        let fraction = min(1, CGFloat(lit) / CGFloat(total))
        layoutIfNeeded()
        fillWidth?.constant = track.bounds.width * fraction
    }
}

final class PauseGlyphView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ rect: CGRect) {
        DesignTokens.inkUI.setFill()
        UIBezierPath(roundedRect: CGRect(x: rect.minX, y: rect.minY, width: 4, height: rect.height), cornerRadius: 1).fill()
        UIBezierPath(roundedRect: CGRect(x: rect.maxX - 4, y: rect.minY, width: 4, height: rect.height), cornerRadius: 1).fill()
    }
}
