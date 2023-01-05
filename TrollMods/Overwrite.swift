//
//  Overwrite.swift
//  TrollMods
//
//  Created by Chris on 2022-12-29.
//

import Foundation

public func OverwriteFile(newFileData: Data, targetPath: String) -> Bool {
    let fd = open(targetPath, O_RDONLY | O_CLOEXEC);
    guard fd != -1 else {
        print("Failed to read target path");
        return false;
    }
    defer { close(fd) }
    
    let originalFileSize = lseek(fd, 0, SEEK_END);
    guard originalFileSize >= newFileData.count else {
        print("New file is too large (O:\(originalFileSize) N:\(newFileData.count)");
        return false;
    }
    lseek(fd, 0, SEEK_SET);
    
    let fileMap = mmap(nil, newFileData.count, PROT_READ, MAP_SHARED, fd, 0);
    guard fileMap != MAP_FAILED else {
        print("Map failed");
        return false;
    }
    
    guard mlock(fileMap, newFileData.count) == 0 else {
        print("Mlock failed");
        return false;
    }
    
    for chunkOff in stride(from: 0, to: newFileData.count, by: 0x4000) {
        let dataChunk = newFileData[chunkOff..<min(newFileData.count, chunkOff + 0x3fff)];
        var overwroteOne = false;
        for _ in 0..<2 {
            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                print(dataChunkBytes.count);
                return unaligned_copy_switch_race(
                    fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count);
            }
            if overwriteSucceeded {
                overwroteOne = true;
                break;
            }
            print("Retrying...");
            sleep(1);
        }
        guard overwroteOne else {
            print("Failed to overwrite")
            return false
        }
    }
    print("Success");
    return true;
}

public func nullifyFile(atPath: String) -> Bool {
    let targetFileLength: Int = FileManager.default.contents(atPath: atPath)?.count ?? -1
    
    guard targetFileLength != -1 else {
        print("Something went wrong while reading length of \(atPath).")
        return false
    }
    
    let data: Data = Data(count: targetFileLength)
    
    return OverwriteFile(newFileData: data, targetPath: atPath)
}
