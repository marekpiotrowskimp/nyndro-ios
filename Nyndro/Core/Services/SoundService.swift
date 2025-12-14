//
//  SoundService.swift
//  Nyndro
//
//  Service for playing audio feedback
//

import AVFoundation

/// Service responsible for playing sound effects
final class SoundService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SoundService()
    
    // MARK: - Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var soundCache: [String: URL] = [:]
    
    // MARK: - Initialization
    
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadSounds() {
        let soundNames = ["click", "bell", "singing_bowl", "gong"]
        
        for name in soundNames {
            // Try to find in Sounds subdirectory first, then in main bundle
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Sounds") {
                soundCache[name] = url
            } else if let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds") {
                soundCache[name] = url
            } else if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
                soundCache[name] = url
            } else if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
                soundCache[name] = url
            }
        }
    }
    
    // MARK: - Playback
    
    /// Play sound for counter sound type
    func play(sound: CounterSound) {
        guard sound != .none,
              let fileName = sound.fileName,
              let url = soundCache[fileName] else {
            return
        }
        
        playSound(at: url)
    }
    
    /// Play sound by name
    func play(soundNamed name: String) {
        guard let url = soundCache[name] else {
            // Try to load on demand from Sounds subdirectory
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Sounds") {
                soundCache[name] = url
                playSound(at: url)
            } else if let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds") {
                soundCache[name] = url
                playSound(at: url)
            } else if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
                soundCache[name] = url
                playSound(at: url)
            } else if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
                soundCache[name] = url
                playSound(at: url)
            }
            return
        }
        
        playSound(at: url)
    }
    
    /// Play sound from URL
    private func playSound(at url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    // MARK: - Celebration Sounds
    
    /// Play milestone celebration sound
    func playMilestoneSound(level: Int) {
        switch level {
        case 1:
            play(soundNamed: "click")
        case 2:
            play(soundNamed: "bell")
        case 3:
            play(soundNamed: "gong")
        default:
            play(soundNamed: "bell")
        }
    }
    
    /// Play practice completion sound
    func playCompletionSound() {
        play(soundNamed: "gong")
    }
    
    // MARK: - Volume Control
    
    /// Set the playback volume (0.0 to 1.0)
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    /// Stop any currently playing sound
    func stop() {
        audioPlayer?.stop()
    }
}
