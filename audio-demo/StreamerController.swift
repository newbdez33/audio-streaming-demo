//
//  StreamerController.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/14.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import UIKit
import AVFoundation

class StreamerController: ObservableObject, StreamingDelegate {
    
    @Published var progressStreaming:Float = 0.0
    @Published var progress:Float = 0.0
    @Published var durationValue:Double = 0.0
    @Published var duration = "0"
    @Published var elapsedtime = "0"
    @Published var elapsedtimeValue:Double = 0.0
    @Published var averagePowerForChannel0:Float = 0
    @Published var averagePowerForChannel1:Float = 0
    @Published var isPlaying = false
    
    lazy var streamer: PodbeanStreamer = {
        setupAudioSession()
        
        let streamer = PodbeanStreamer()
        streamer.pitch = 0
        streamer.rate = 1
        streamer.delegate = self
        return streamer
    }()
    
    func streamer(_ streamer: Streaming, failedDownloadWithError error: Error, forURL url: URL) {
        //
    }
    
    func streamer(_ streamer: Streaming, updatedDownloadProgress progress: Float, forURL url: URL) {
        self.progressStreaming = progress
    }
    
    func streamer(_ streamer: Streaming, changedState state: StreamingState) {
        switch state {
        case .playing:
            isPlaying = true
        case .paused, .stopped:
            isPlaying = false
        }
    }
    
    func streamer(_ streamer: Streaming, updatedCurrentTime currentTime: TimeInterval) {
        self.elapsedtime = self.prettifyTimestamp(currentTime)
        self.elapsedtimeValue = currentTime
        guard self.durationValue != 0 else { return }
        self.progress = Float(currentTime/self.durationValue)
    }
    
    func streamer(_ streamer: Streaming, updatedDuration duration: TimeInterval) {
        self.durationValue = duration
        self.duration = self.prettifyTimestamp(duration)
    }
    
    public func prettifyTimestamp(_ timestamp: Double) -> String {
        let hours = Int(timestamp / 60 / 60)
        let minutes = Int((timestamp - Double(hours * 60)) / 60)
        
        let secondsLeft = Int(timestamp) - (minutes * 60)
        
        return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", secondsLeft))"
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, policy: .default, options: [.allowBluetoothA2DP,.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            //os_log("Failed to activate audio session: %@", log: ViewController.logger, type: .default, #function, #line, error.localizedDescription)
        }
    }
}
