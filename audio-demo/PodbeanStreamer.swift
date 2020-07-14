//
//  PodbeanStreamer.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/14.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import UIKit
import AVFoundation

class PodbeanStreamer: Streamer {
    /// An `AVAudioUnitTimePitch` used to perform the time/pitch shift effect
    let timePitchNode = AVAudioUnitTimePitch()
    
    /// A `Float` representing the pitch of the audio
    var pitch: Float {
        get {
            return timePitchNode.pitch
        }
        set {
            timePitchNode.pitch = newValue
        }
    }
    
    /// A `Float` representing the playback rate of the audio
    var rate: Float {
        get {
            return timePitchNode.rate
        }
        set {
            timePitchNode.rate = newValue
        }
    }
    
    // MARK: - Methods
    
    override func attachNodes() {
        super.attachNodes()
        engine.attach(timePitchNode)
    }
    
    override func connectNodes() {
        engine.connect(playerNode, to: timePitchNode, format: readFormat)
        engine.connect(timePitchNode, to: engine.mainMixerNode, format: readFormat)
    }
}
