//
//  Filing.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/23.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import Foundation

public protocol Filing: class {
    
    // MARK: - Properties
    var downloader: Downloading { get }
    
    var localFilePath: String { get }
    
    func getDelegate() -> FilingDelegate?

    func setDelegate(_ delegate: FilingDelegate?)
    
    /// A completion block for when the contents of the file are fully written.
    var completionHandler: ((Error?) -> Void)? { get set }
    
    /// The current progress of the filer. Ranges from 0.0 - 1.0, default is 0.0.
    var progress: Float { get }
    
    /// The current state of the filer. See `FilingState` for the different possible states.
    var state: FilingState { get }
    
    /// A `URL` representing the current URL the downloader is fetching. This is an optional because this protocol is designed to allow classes implementing the `Downloading` protocol to be used as singletons for many different URLS so a common cache can be used to redownloading the same resources.
    var url: URL? { get set }
    
    // MARK: - Methods
    
    /// Starts the downloader
    func start()
    
    /// Pauses the downloader
    func pause()
    
    /// Stops and/or aborts the downloader. This should invalidate all cached data under the hood.
    func stop()
    
    func getData() -> Data?
    
}
