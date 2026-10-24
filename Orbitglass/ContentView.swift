import SwiftUI

struct ContentView: View {
    var body: some View {
        PlayView()
    }
}

/// Full-bleed dome. Pause and chapter stay overlays on this same scene.
struct PlayView: View {
    var body: some View {
        DomeHost()
            .ignoresSafeArea()
    }
}

struct PauseView: View {
    var body: some View {
        PlayView()
    }
}

struct ChapterView: View {
    var body: some View {
        PlayView()
    }
}

private struct DomeHost: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RootDomeHostController {
        RootDomeHostController()
    }

    func updateUIViewController(_ uiViewController: RootDomeHostController, context: Context) {}
}

#Preview {
    ContentView()
}
