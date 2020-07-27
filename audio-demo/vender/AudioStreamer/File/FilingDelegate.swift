//
//  FilingDelegate.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/23.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import Foundation

public protocol FilingDelegate: class {
    
    /// Triggered when a `Downloading` instance has changed its `Downloading` state during an existing download operation.
    ///
    /// - Parameters:
    ///   - download: The current `Downloading` instance
    ///   - state: The new `DownloadingState` the `Downloading` has transitioned to
    func file(_ file: Filing, changedState state: FilingState)
    
    /// Triggered when a `Downloading` instance has fully completed its request.
    ///
    /// - Parameters:
    ///   - download: The current `Downloading` instance
    ///   - error: An optional `Error` if the download failed to complete. If there were no errors then this will be nil.
    func file(_ file: Filing, completedWithError error: Error?)
    
    func file(_ file: Filing, didReceiveData data: Data, progress: Float)
}
