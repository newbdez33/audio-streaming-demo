//
//  Filer+DownloadingDelegate.swift
//  audio-demo
//
//  Created by Jacky on 2020/07/23.
//  Copyright © 2020 salmonapps. All rights reserved.
//

import Foundation
import os.log

extension Filer: DownloadingDelegate {
    
    public func download(_ download: Downloading, completedWithError error: Error?) {
        self.getDelegate()?.file(self, completedWithError: error)
    }
    
    public func download(_ download: Downloading, changedState downloadState: DownloadingState) {
        print("download state changed: \(downloadState)")
    }
    
    public func download(_ download: Downloading, didReceiveData data: Data, progress: Float) {
        
        //TODO take care of range request
        
        //TODO write received data to file
        if FileManager.default.fileExists(atPath: localFilePath) {
            fileHandler?.write(data)
            print("\(fileHandler?.offsetInFile ?? 0), \(progress)")
            
            getDelegate()?.file(self, didReceiveData: data, progress: progress)
        }else {
            os_log("cache file not found", log: Filer.logger, type: .error)
            self.stop()
        }
        
    }
    
    public func download(_ download: Downloading, expectedContentLength: Int64) {
        do {
            if FileManager.default.fileExists(atPath: localFilePath) {
                try FileManager.default.removeItem(atPath: localFilePath)
            }
            let ret = FileManager.default.createFile(atPath: localFilePath, contents: Data(), attributes: nil)
            if ret != true {
                os_log("cannot create cache file", log: Filer.logger, type: .error)
                downloader.stop()
                return
            }
            fileHandler = FileHandle(forUpdatingAtPath: localFilePath)
            fileHandler?.seek(toFileOffset: UInt64(expectedContentLength - 4))
            fileHandler?.write(Data(hexString: "000000")!)   //TODO writeabilityHandler with a downloaded data queue
            fileHandler?.seek(toFileOffset: 0)
            
            fileReader = FileHandle(forReadingAtPath: localFilePath)
            print("download excepted content length:\(expectedContentLength)")
        }catch {
            self.stop()
            os_log("create cache file failed", log: Filer.logger, type: .error)
        }
    }
    
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
