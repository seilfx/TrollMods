//
//  TrollLockModView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-27.
//

import SwiftUI

private var trollLockVersion = "v0.2";

func TrollLockReplace() {
    trollLockPrepare812();
}

struct TrollLockView: View {
    @State private var showInfo = false;
    
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
        .toolbar {
            Button(action: { showInfo = true }) {
                Image(systemName: "info.circle")
            }
            .alert(isPresented: $showInfo) {
                Alert(
                    title: Text("TrollLock Reborn (\(trollLockVersion))"),
                    message: Text("Made with ♡ by Nathan & haxi0")
                )
            }
        }
    }
}
