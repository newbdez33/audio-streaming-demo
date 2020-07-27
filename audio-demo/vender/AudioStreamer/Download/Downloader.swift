//
//  Downloader.swift
//  AudioStreamer
//
//  Created by Syed Haris Ali on 1/6/18.
//  Copyright © 2018 Ausome Apps LLC. All rights reserved.
//

import Foundation
import os.log

/// The `Downloader` is a concrete implementation of the `Downloading` protocol
/// using `URLSession` as the backing HTTP/HTTPS implementation.
public class Downloader: NSObject, Downloading {
    // MARK: - Singleton
    
    /// A singleton that can be used to perform multiple download requests using a common cache.
    public static var shared: Downloader = Downloader()
    
    // MARK: - Properties
    
    /// A `Bool` indicating whether the session should use the shared URL cache or not. Really useful for testing, but in production environments you probably always want this to `true`. Default is true.
    public var useCache = true {
        didSet {
            session.configuration.urlCache = useCache ? URLCache.shared : nil
        }
    }
    
    /// The `URLSession` currently being used as the HTTP/HTTPS implementation for the downloader.
    fileprivate lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    /// A `URLSessionDataTask` representing the data operation for the current `URL`.
    fileprivate var task: URLSessionDataTask?
    
    /// A `Int64` representing the total amount of bytes received
    public var totalBytesReceived: Int64 = 0
    
    /// A `Int64` representing the total amount of bytes for the entire file
    var totalBytesCount: Int64 = 0
    
    // MARK: - Properties (Downloading)

    public var completionHandler: ((Error?) -> Void)?
    public var progressHandler: ((Data, Float) -> Void)?
    public var progress: Float = 0
    public var state: DownloadingState = .notStarted {
        didSet {
            getDelegate()?.download(self, changedState: state)
        }
    }
    public var url: URL? {
        didSet {
            if state == .started {
                stop()
            }
            
            if let url = url {
                progress = 0.0
                state = .notStarted
                totalBytesCount = 0
                totalBytesReceived = 0
                task = session.dataTask(with: url)
            } else {
                task = nil
            }
        }
    }
    
    // MARK: - Methods

    public func getDelegate() -> DownloadingDelegate? {
        objc_sync_enter(self)
        let delegate = self.delegate
        objc_sync_exit(self)
        return delegate
    }

    public func setDelegate(_ delegate: DownloadingDelegate?) {
        objc_sync_enter(self)
        self.delegate = delegate
        objc_sync_exit(self)
    }
    
    public func start() {        
        guard let task = task else {
            return
        }
        
        switch state {
        case .completed, .started:
            return
        default:
            state = .started
            task.resume()
        }
    }
    
    public func pause() {
        guard let task = task else {
            return
        }
        
        guard state == .started else {
            return
        }
        
        state = .paused
        task.suspend()
    }
    
    public func stop() {
        guard let task = task else {
            return
        }
        
        guard state == .started else {
            return
        }
        
        state = .stopped
        task.cancel()
    }

    private weak var delegate: DownloadingDelegate?
}
