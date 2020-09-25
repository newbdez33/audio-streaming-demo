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
            let offset = try fileReader.offset()
            var c = 21000  //chunk is 21000
            if ( offset == 0 && getFileType() == "m4a" ) {
                c = 552000  //first chunk for m4a
            }
            //print("read offet:\(offset)")
            if offset + UInt64(c) > downloader.totalBytesReceived { //TODO here we should make sure the downloaded content is written in file already.
                print("audio data is not ready")
                return nil
            }
            guard let data = try fileReader.read(upToCount: c) else {
                return nil
            }
            if ( offset == 0 && getFileType() == "m4a" && foundM4aAtomData(data) == false ) {
                print("detected not optimized m4a file.")
                return nil
            }
            fileReader.seek(toFileOffset: offset + UInt64(c))
            return data
        }catch {
            print("reading file exception")
            return nil
        }
    }
    
    private func getFileType() -> String {
        let t = url?.pathExtension ?? "unknown"
        return t.lowercased()
    }
    
    private func foundM4aAtomData(_ data:Data) -> Bool {
        //First check atom field is filled return true.
        //Otherwise check if data includs atom mdat then return true.
        return true
    }

    private weak var delegate: FilingDelegate?
}
