//
//  TrollLockModView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-27.
//

import SwiftUI

func TrollLockReplace() {
    trollLockPrepare812();
}

struct TrollLockView: View {
    var body: some View {
        VStack {
            Image("TrollLock")
                .resizable()
                .frame(width: 128.0, height: 128.0)
            Text("TrollLock")
                .font(.title)
                .fontWeight(.bold)
            Button("Start", action: TrollLockReplace)
                .controlSize(.large)
                .tint(.blue)
                .buttonStyle(.bordered)
        }
    }
}
