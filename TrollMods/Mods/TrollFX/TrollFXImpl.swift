//
//  TrollFXImpl.swift
//  TrollMods
//
//  Created by Chris on 2022-12-29.
//

import Foundation

func OverWriteLockSoundWithFart() {
    DispatchQueue.global(qos: .userInteractive).async {
        let soundData = Bundle.main.path(forResource: "fart", ofType: "caf");
        
        let success = OverwriteFile(newFileData: try! Data(contentsOf: URL.init(fileURLWithPath: soundData!)), targetPath: "/System/Library/Audio/UISounds/connect_power.caf");
    }
}
