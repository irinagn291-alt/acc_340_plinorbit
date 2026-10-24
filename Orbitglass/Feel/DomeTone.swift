import AVFoundation
import UIKit

/// Glass tones from a buffer. One haptic, on a lit star. No recorded clips and no microphone.
@MainActor
final class DomeTone {
    static let shared = DomeTone()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat?
    private var started = false
    private let collectHaptic = UIImpactFeedbackGenerator(style: .medium)

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
    }

    func prepare() {
        collectHaptic.prepare()
        guard !started, let format else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.prepare()
        do {
            try engine.start()
            started = true
        } catch {
            started = false
        }
    }

    func releaseTick() {
        play(start: 640, end: 640, seconds: 0.04, gain: 0.07, partials: 1)
    }

    func bounce() {
        play(start: 280, end: 190, seconds: 0.07, gain: 0.1, partials: 2)
    }

    func collect() {
        collectHaptic.impactOccurred(intensity: 0.7)
        collectHaptic.prepare()
        play(start: 720, end: 960, seconds: 0.12, gain: 0.09, partials: 2)
    }

    func failGlass() {
        play(start: 240, end: 90, seconds: 0.18, gain: 0.11, partials: 1)
    }

    func chapterChime() {
        play(start: 520, end: 780, seconds: 0.16, gain: 0.08, partials: 2)
    }

    private func play(start: Float, end: Float, seconds: Double, gain: Float, partials: Int) {
        guard started, let format, let buffer = glass(start: start, end: end, seconds: seconds, gain: gain, partials: partials, format: format) else {
            return
        }
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    private func glass(
        start: Float,
        end: Float,
        seconds: Double,
        gain: Float,
        partials: Int,
        format: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        let rate = format.sampleRate
        guard rate > 0 else { return nil }
        let frames = AVAudioFrameCount(max(1, rate * seconds))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let samples = buffer.floatChannelData?[0]
        else { return nil }
        buffer.frameLength = frames
        let count = Int(frames)
        var phase = Float(0)
        for index in 0..<count {
            let along = Float(index) / Float(max(count - 1, 1))
            let hz = start + (end - start) * along
            phase += hz / Float(rate)
            let wrapped = phase * 2 * Float.pi
            var wave = sin(wrapped)
            if partials > 1 {
                wave += sin(wrapped * 2.02) * 0.28
            }
            let envelope = exp(-3.4 * along)
            samples[index] = wave * envelope * gain
        }
        return buffer
    }
}
