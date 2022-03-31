//
//  Created by Anton Spivak
//

import Foundation

extension FileManager {
    
    public enum DirectoryType {
        
        case target
        case group(identifier: String = "group.com.hueton")
    }
    
    public enum StorageType {
        
        case persistent
        case type
        
        internal var searchPathDirectory: FileManager.SearchPathDirectory {
            switch self {
            case .persistent: return .documentDirectory
            case .type: return .cachesDirectory
            }
        }
        
        internal var groupPathComponent: String {
            switch self {
            case .persistent: return "Library/Documents"
            case .type: return "Library/Caches"
            }
        }
    }
    
    /// Returs URL for cpecified directory and storage
    ///
    /// - warning: if `pathComponent` specified directory will be created atomatically
    ///
    /// - parameter directory: an `DirectoryType`
    /// - parameter storage: an `StorageType`
    /// - parameter pathComponent: Additional component for URL
    public func directoryURL(
        with directory: DirectoryType,
        with storage: StorageType,
        pathComponent: String? = nil
    ) -> URL {
        var url: URL
        switch directory {
        case .target:
            url = urls(for: storage.searchPathDirectory, in: .userDomainMask)[0]
        case let .group(identifier):
            guard var _url = containerURL(forSecurityApplicationGroupIdentifier: identifier)
            else {
                fatalError("Could not resolve url for '\(identifier)' application group.")
            }
            
            _url = _url.appendingPathComponent(storage.groupPathComponent)
            guard createDirectoriesWithSubdirectoriesIfNeeded(url: _url) == nil
            else {
                fatalError("Can't create directory for url: \(_url) since it not a directory.")
            }
            
            url = _url
        }
        
        if let pathComponent = pathComponent {
            url = url.appendingPathComponent(pathComponent)
            guard createDirectoriesWithSubdirectoriesIfNeeded(url: url) == nil
            else {
                fatalError("Can't create directory for url: \(url) since it not a directory.")
            }
        }
        
        return url
    }
    
    @discardableResult
    public func createDirectoriesWithSubdirectoriesIfNeeded(url: URL) -> Error? {
        var isDirectory = ObjCBool(false)
        let exists = fileExists(atPath: url.relativePath, isDirectory: &isDirectory)
        if exists && !isDirectory.boolValue {
            return URLError(.fileDoesNotExist)
        } else if !exists {
            do {
                try createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                return error
            }
        }
        return nil
    }
}
