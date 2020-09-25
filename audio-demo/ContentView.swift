//
//  ContentView.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/13.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import SwiftUI
import AVFoundation
import Accelerate

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

struct ContentView: View {
    @State private var url = //"https://mcdn.podbean.com/mf/web/g9swyq/live_20200521_193712_original_92s72.m4a"
    "https://mcdn.podbean.com/mf/web/u4mtq8/Jan_R_C_EDIT.m4a"
    @State private var silences = false
    @State private var eq = false
    
    @ObservedObject private var streaming = StreamerController()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Audio streaming player demo")
                .font(.headline)
            HStack {
                TextField("URL", text: $url)
                Button(action: {
                    self.streaming.streamer.stop()
                    self.streaming.duration = "0"
                    self.streaming.elapsedtime = "0"
                    self.streaming.durationValue = 0
                    self.streaming.progressStreaming = 0
                    self.streaming.progress = 0
                    if let u = URL(string: self.url) {
                        self.streaming.streamer.url = u
                    }
                }) {
                    Text("RESET")
                }
            }
            Toggle(isOn: $silences) {
                Text("Shortens Silences")
            }.toggleStyle(CheckboxToggleStyle())
            Toggle("Full Volume Voice EQ", isOn: $eq)
            .onReceive([self.eq].publisher.first()) { (value) in
                    //self.toggleEQ()
            }
            .toggleStyle(CheckboxToggleStyle())
//            Slider(value: Binding(    //TODO
//                get: {
//                    self.streaming.progress
//                },
//                set: {(newValue) in
//                      self.streaming.progress = newValue
//                }
//            ))
            ProgressBar(value: $streaming.progress).frame(height: 20)
            HStack {
                Spacer()
                Text("\(streaming.elapsedtime)")
                Text("/")
                Text("\(streaming.duration)")
            }
            HStack {
                Button(action: {

                    if self.streaming.streamer.state == .playing {
                        self.streaming.streamer.pause()
                    } else {
                        self.streaming.streamer.play()
                    }

                }) {
                    Text("\(streaming.isPlaying ? "PAUSE" : "PLAY" )")
                        .font(.title)
                }
                Spacer()
                Button(action: {
                    self.skipBackward()
                }) {
                    Text("-15")
                        .font(.title)
                }
                Button(action: {
                    self.skipForward()
                }) {
                    Text("+15")
                        .font(.title)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear() {
            self.buildPlayer()
        }
    }
    
    func skipForward() {
        let currentTime = self.streaming.elapsedtimeValue + 15
        guard currentTime < self.streaming.durationValue else { return }
        do {
            try self.streaming.streamer.seek(to: currentTime)
        } catch {
            
        }
    }
    
    func skipBackward() {
        let currentTime = self.streaming.elapsedtimeValue - 15
        guard currentTime > 0 else { return }
        do {
            try self.streaming.streamer.seek(to: currentTime)
        } catch {
            
        }
    }
    
    
    func buildPlayer() {
        if let u = URL(string: self.url) {
            self.streaming.streamer.url = u
        }
    }
    
    private func audioMetering(buffer:AVAudioPCMBuffer) {
//        buffer.frameLength = 1024
//        let inNumberFrames:UInt = UInt(buffer.frameLength)
//        if buffer.format.channelCount > 0 {
//            let samples = (buffer.floatChannelData![0])
//            var avgValue:Float32 = 0
//            vDSP_meamgv(samples,1 , &avgValue, inNumberFrames)
//            var v:Float = -100
//            if avgValue != 0 {
//                v = 20.0 * log10f(avgValue)
//            }
//            self.averagePowerForChannel0 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel0)
//            self.averagePowerForChannel1 = self.averagePowerForChannel0
//        }
//
//        if buffer.format.channelCount > 1 {
//            let samples = buffer.floatChannelData![1]
//            var avgValue:Float32 = 0
//            vDSP_meamgv(samples, 1, &avgValue, inNumberFrames)
//            var v:Float = -100
//            if avgValue != 0 {
//                v = 20.0 * log10f(avgValue)
//            }
//            self.averagePowerForChannel1 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel1)
//        }
    }
    
    func toggleEQ() {
//        var freq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
//        if eq == true {
//            freq[0] = 1
//        }
//        if let node = SAPlayer.shared.audioModifiers[0] as? AVAudioUnitEQ{
//            for i in 0...(node.bands.count - 1){
//                node.bands[i].gain = Float(freq[i])
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
