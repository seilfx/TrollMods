//
//  FilesImpl.swift
//  TrollMods
//
//  Created by Chris on 2022-12-31.
//

import Foundation

public struct File: Identifiable {
    public var id = UUID()
    public var name: String
    public var type: String
    public var size: String
    public var date: String
}

public struct Folder: Identifiable {
    public var id = UUID()
    public var name: String
}

public struct DirectoryContent {
    public var folders: [Folder]
    public var files: [File]
}

public func loadPath(atPath: String) -> DirectoryContent {
    var directoryContent: DirectoryContent = DirectoryContent(folders: [], files: [])
    
    print(atPath)
    
    do {
        let directoryContents = try FileManager.default.contentsOfDirectory(atPath: atPath)
        print(directoryContents)
        
        for dirItem in directoryContents {
            print("Processing `\(dirItem)`")
            
            var attrs: [FileAttributeKey : Any] = [:]
            
            do {
                attrs = try FileManager.default.attributesOfItem(atPath: atPath + dirItem)
            } catch {
                print("Error while reading attributes of `\(dirItem)`. Skipping: \(error)")
                continue
            }
            
            let type = attrs[.type] as! FileAttributeType
            
            if (type == .typeDirectory) {
                directoryContent.folders.append(Folder(name: dirItem))
            } else if (type == .typeRegular) {
                let date = attrs[.modificationDate] as! Date
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                let dateString = formatter.string(from: date)
                
                let size = attrs[.size] as! UInt64
                var sizeString = ""
                
                switch size {
                    case 0..<1024:
                        sizeString = "\(size) B"
                    case 1024..<1024 * 1024:
                        sizeString = "\(size / 1024) KB"
                    case 1024 * 1024..<1024 * 1024 * 1024:
                        sizeString = "\(size / 1024 / 1024) MB"
                    default:
                        sizeString = "\(size / 1024 / 1024) GB"
                }
                
                directoryContent.files.append(File(name: dirItem, type: dirItem.components(separatedBy: ".").last!, size: sizeString, date: dateString))
            }
        }
        
    } catch {
        print("Error while reading path: \(error)")
    }
    
    return directoryContent;
}
