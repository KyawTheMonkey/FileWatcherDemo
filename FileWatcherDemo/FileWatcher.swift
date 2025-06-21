//
//  FileWatcher.swift
//  FileWatcherDemo
//
//  Created by Kyaw Zay Ya Lin Tun on 21/06/2025.
//

import Foundation

final class FileWatcher {
  let path: String
  private let refreshInterval: TimeInterval
  private let queue: DispatchQueue
  private var source: DispatchSourceFileSystemObject?
  
  init(
    path: String,
    refreshInterval: TimeInterval = 1/60,
    queue: DispatchQueue = .main
  ) {
    self.path = path
    self.refreshInterval = refreshInterval
    self.queue = queue
  }
  
  func startObserving(_ callback: @escaping (Data?) -> Void) {
    let url = URL(fileURLWithPath: path)
    
    guard let fileHandle = try? FileHandle(forReadingFrom: url) else {
      return
    }
    
    let source = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: fileHandle.fileDescriptor,
      eventMask: [.delete, .write, .extend, .attrib, .link, .rename, .revoke],
      queue: queue
    )
    self.source = source
    
    source.setEventHandler {
      callback(try? Data(contentsOf: url, options: .uncached))
      self.queue.asyncAfter(deadline: .now() + self.refreshInterval) {
        self.startObserving(callback)
      }
    }
    
    source.setCancelHandler {
      try? fileHandle.close()
    }
    
    source.resume()
  }
  
  deinit {
    source?.cancel()
  }
}
