import UIKit

final class RecordRowCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = DesignTokens.surfaceUI
        selectionStyle = .none
        titleLabel.font = DomeType.demi(17)
        titleLabel.textColor = DesignTokens.inkUI
        detailLabel.font = DomeType.digits(17)
        detailLabel.textColor = DesignTokens.accentUI
        detailLabel.textAlignment = .right
    }

    func show(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
}
