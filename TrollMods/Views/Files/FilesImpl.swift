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
    public var contents: [File]
}

public struct DirectoryContent {
    public var folders: [Folder]
    public var files: [File]
}

public func loadPath(atPath: String) -> DirectoryContent {
    var directoryContent: DirectoryContent = DirectoryContent(folders: [], files: [])
    
    let enumerator = FileManager.default.enumerator(atPath: atPath)
    while let element = enumerator?.nextObject() as? String {
        // only do the top level files and folders
        if element.contains("/") {
            continue
        }
        let attrs = try! FileManager.default.attributesOfItem(atPath: atPath + element)
        let type = attrs[.type] as! FileAttributeType
        if type == .typeDirectory {
            directoryContent.folders.append(Folder(name: element, contents: []))
        } else if type == .typeRegular {
            let size = attrs[.size] as! UInt64
            let date = attrs[.modificationDate] as! Date
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let dateString = formatter.string(from: date)
            var sizeString = ""
            if size < 1024 {
                sizeString = "\(size) B"
            } else if size < 1024 * 1024 {
                sizeString = "\(size / 1024) KB"
            } else if size < 1024 * 1024 * 1024 {
                sizeString = "\(size / 1024 / 1024) MB"
            } else {
                sizeString = "\(size / 1024 / 1024 / 1024) GB"
            }
            directoryContent.files.append(File(name: element, type: element.components(separatedBy: ".").last!, size: sizeString, date: dateString))
        }
    }
    
    return directoryContent;
}
