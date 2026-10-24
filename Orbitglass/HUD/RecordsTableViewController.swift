import UIKit

final class RecordsTableViewController: UITableViewController {
    private let store: RunRecordStore
    private var rows: [(String, String)] = []

    init(store: RunRecordStore) {
        self.store = store
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Records"
        tableView.register(
            UINib(nibName: "RecordRowCell", bundle: Bundle(for: RecordRowCell.self)),
            forCellReuseIdentifier: RecordRowCell.reuseID
        )
        tableView.backgroundColor = DesignTokens.bgUI
        tableView.separatorColor = DesignTokens.mutedUI.withAlphaComponent(0.28)
        tableView.rowHeight = 64
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(close)
        )
        navigationItem.rightBarButtonItem?.tintColor = DesignTokens.accentUI
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadRows()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecordRowCell.reuseID, for: indexPath)
        if let row = cell as? RecordRowCell {
            let item = rows[indexPath.row]
            row.show(title: item.0, detail: item.1)
        }
        return cell
    }

    private func reloadRows() {
        let record = store.record
        var lines = [
            ("Best score", "\(record.bestScore)"),
            ("Highest chapter", "\(record.highestChapter)"),
        ]
        for chapter in 1...RestitutionCut.chapterCount {
            let clears = record.diagramClears[chapter] ?? 0
            lines.append(("Chapter \(chapter) clears", "\(clears)"))
        }
        rows = lines
        tableView.reloadData()
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

extension RecordRowCell {
    static let reuseID = "RecordRowCell"
}
