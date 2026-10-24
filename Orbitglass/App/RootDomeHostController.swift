import SpriteKit
import UIKit

final class RootDomeHostController: UIViewController, DomePresenting {
    private let scene = DomeScene()
    private let store = RunRecordStore.shared
    private let skView = SKView()
    private let gauge = TopGaugeBarView()
    private let pauseOverlay = PauseOverlayView()
    private let chapterOverlay = ChapterOverlayView()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = DesignTokens.bgUI
        store.seedDemoIfNeeded()

        skView.frame = view.bounds
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
        skView.preferredFramesPerSecond = 60
        skView.allowsTransparency = false
        view.addSubview(skView)

        gauge.translatesAutoresizingMaskIntoConstraints = false
        pauseOverlay.translatesAutoresizingMaskIntoConstraints = false
        chapterOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gauge)
        view.addSubview(pauseOverlay)
        view.addSubview(chapterOverlay)
        pauseOverlay.isHidden = true
        chapterOverlay.isHidden = true

        NSLayoutConstraint.activate([
            gauge.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gauge.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gauge.topAnchor.constraint(equalTo: view.topAnchor),
            pauseOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pauseOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pauseOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            pauseOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chapterOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chapterOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chapterOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            chapterOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        gauge.pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        pauseOverlay.onResume = { [weak self] in self?.resume() }
        pauseOverlay.onRecords = { [weak self] in
            guard let self else { return }
            self.presentSheet(RecordsTableViewController(store: self.store))
        }
        pauseOverlay.onSettings = { [weak self] in
            guard let self else { return }
            self.presentSheet(SettingsSheetViewController(store: self.store))
        }
        chapterOverlay.onContinue = { [weak self] in self?.continueChapter() }

        scene.presenter = self
        scene.recordStore = store
        skView.presentScene(scene)
        applyReviewChrome()
        styleNavigation()
    }

    func domeUpdated(score: Int, chapter: Int, lit: Int, goal: Int) {
        gauge.render(score: score, chapter: chapter, lit: lit, goal: goal)
    }

    func domeShowChapter(_ chapter: Int) {
        guard ReviewLaunch.screen == nil else { return }
        chapterOverlay.setChapter(chapter)
        chapterOverlay.isHidden = false
    }

    private func applyReviewChrome() {
        guard let pose = ReviewLaunch.screen else { return }
        if pose == "pause" {
            pauseOverlay.isHidden = false
        }
        if pose == "chapter" {
            chapterOverlay.setChapter(max(2, scene.simulation.chapter))
            chapterOverlay.isHidden = false
        }
    }

    @objc private func pauseTapped() {
        guard ReviewLaunch.screen == nil else { return }
        scene.haltRun()
        pauseOverlay.isHidden = false
    }

    private func resume() {
        pauseOverlay.isHidden = true
        scene.resumeRun()
    }

    private func continueChapter() {
        chapterOverlay.isHidden = true
        scene.resumeRun()
    }

    private func presentSheet(_ controller: UIViewController) {
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .pageSheet
        if let sheet = navigation.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        navigation.navigationBar.standardAppearance = navAppearance()
        navigation.navigationBar.scrollEdgeAppearance = navAppearance()
        present(navigation, animated: true)
    }

    private func styleNavigation() {
        UINavigationBar.appearance().tintColor = DesignTokens.accentUI
    }

    private func navAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = DesignTokens.surfaceUI
        appearance.titleTextAttributes = [
            .foregroundColor: DesignTokens.inkUI,
            .font: DomeType.demi(17),
        ]
        return appearance
    }
}
