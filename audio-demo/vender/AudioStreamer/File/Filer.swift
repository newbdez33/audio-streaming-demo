//
//  Filer.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/23.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import Foundation
import os.log

public class Filer: NSObject, Filing {
    // MARK: - Singleton
    static let logger = OSLog(subsystem: "com.podbean.player", category: "Filer")
    /// A singleton that can be used to perform multiple download requests using a common cache.
    public static var shared: Filer = Filer()
    
    // MARK: - Properties
    
    public lazy var downloader: Downloading = {
        let downloader = Downloader()
        downloader.setDelegate(self)
        return downloader
    }()
    
    public lazy var localFilePath: String = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first?.appendingPathComponent("com.podbean.player.cached")
        return url?.path ?? ""
    }()
    
    public var fileHandler: FileHandle?
    public var fileReader: FileHandle?
    
    // MARK: - Properties (Filing)

    public var completionHandler: ((Error?) -> Void)?
    public var progressHandler: ((Data, Float) -> Void)?
    public var progress: Float = 0
    public var state: FilingState = .notStarted {
        didSet {
            getDelegate()?.file(self, changedState: state)
        }
    }

    public var url: URL? {
        didSet {
            if state == .started {
                stop()
            }
            
            downloader.url = url
        }
    }
    
    private var currentPosition: UInt64 = 0
    
    // MARK: - Methods

    public func getDelegate() -> FilingDelegate? {
        objc_sync_enter(self)
        let delegate = self.delegate
        objc_sync_exit(self)
        return delegate
    }

    public func setDelegate(_ delegate: FilingDelegate?) {
        objc_sync_enter(self)
        self.delegate = delegate
        objc_sync_exit(self)
    }
    
    public func start() {
        downloader.start()
    }
    
    public func pause() {
        downloader.pause()
    }
    
    public func stop() {
        downloader.stop()
        fileHandler?.closeFile()
    }
    
    public func getData() -> Data? {
        guard let fileReader = fileReader else {
            return nil
        }
        
        do {
            let c = 250000
            let offset = try fileReader.offset()
            //print("read offet:\(offset)")
            if offset + UInt64(c) > downloader.totalBytesReceived {
                print("no enough cache")
                return nil
            }
            let data = try fileReader.read(upToCount: c)
            fileReader.seek(toFileOffset: offset + UInt64(c))
            return data
        }catch {
            print("reading file exception")
            return nil
        }
    }

    private weak var delegate: FilingDelegate?
}
