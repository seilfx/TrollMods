//
//  TrollHomeImpl.swift
//  TrollMods
//
//  Created by Chris on 2023-01-03.
//

import Foundation

private var folderFiles = [
        "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderBackground.materialrecipe",
        "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe",
        
        "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedDark.materialrecipe",
        "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedLight.materialrecipe",
]

private var dockFiles = [
    "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe",
    "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"
]

public func removeFolderBackground() {
    DispatchQueue.global(qos: .userInteractive).async {
        folderFiles.forEach { path in
            let _ = nullifyFile(atPath: path)
        }
    }
}

public func removeDockBackground() {
    DispatchQueue.global(qos: .userInteractive).async {
        dockFiles.forEach { path in
            let _ = nullifyFile(atPath: path)
        }
    }
}
