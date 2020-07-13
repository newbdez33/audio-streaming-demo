//
//  ContentView.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/13.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import SwiftUI

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

struct ContentView: View {
    @State private var url = "https://mcdn.podbean.com/mf/download/cw4dtz/Loremen_S3E27.mp3"
    @State private var silences = false
    @State private var eq = false
    var body: some View {
        VStack(alignment: .leading) {
            Text("Audio streaming player Demo")
                .font(.headline)
            HStack {
                TextField("URL", text: $url)
                Button(action: {
                    //
                }) {
                    Text("RESET")
                }
            }
            Toggle(isOn: $silences) {
                Text("Shortens Silences")
            }.toggleStyle(CheckboxToggleStyle())
            Toggle(isOn: $eq) {
                Text("Full Volume Voice EQ")
            }.toggleStyle(CheckboxToggleStyle())
            Button(action: {
                if let u = URL(string: self.url) {
                    if SAPlayer.shared.engine != nil {
                        SAPlayer.shared.togglePlayAndPause()
                    }else {
                        SAPlayer.shared.startRemoteAudio(withRemoteUrl: u)
                        SAPlayer.shared.play()
                    }
                    
                }
            }) {
                Text("PLAY")
                    .font(.title)
            }
            Spacer()
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
