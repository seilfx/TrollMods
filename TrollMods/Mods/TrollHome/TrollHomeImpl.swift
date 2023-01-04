//
//  TrollHomeImpl.swift
//  TrollMods
//
//  Created by Chris on 2023-01-03.
//

import Foundation

private var folderFiles = [
    "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderBackground.materialrecipe",
    
    "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe",
    "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe",
    
    "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedDark.descendantrecipe",
    "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedLight.descendantrecipe",
]

private var dockFiles = [
    "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe",
    "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"
]

public func removeFolderBackground() {
    folderFiles.forEach { path in
        print("Clearing \(path)...")
        let _ = nullifyFile(atPath: path)
    }
    
    print("Successfully cleared folder backgrounds!")
}

public func removeDockBackground() {
    dockFiles.forEach { path in
        print("Clearing \(path)...")
        let _ = nullifyFile(atPath: path)
    }
    
    print("Successfully cleared dock background!")
}

public func removeHomebar() {
    let success = nullifyFile(atPath: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car")
    
    print("Cleared home bar: \(success)")
}
