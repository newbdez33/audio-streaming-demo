//
//  Streamer+DownloadingDelegate.swift
//  AudioStreamer
//
//  Created by Syed Haris Ali on 6/5/18.
//  Copyright © 2018 Ausome Apps LLC. All rights reserved.
//

import Foundation
import os.log

extension Streamer: FilingDelegate {
    
    public func file(_ file: Filing, didReceiveData data: Data, progress: Float) {
//        self.preparePackets()
    }
    
    
    public func file(_ download: Filing, completedWithError error: Error?) {
        if let error = error, let url = download.url {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                
                self.delegate?.streamer(self, failedDownloadWithError: error, forURL: url)
            }
        }
    }
    
    public func file(_ download: Filing, changedState downloadState: FilingState) {
        
    }
    
}
