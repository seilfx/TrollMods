//
//  TrollFXView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-29.
//

import SwiftUI

private var MOD_VERSION = "v0.1";

struct TrollFXView: View {
    @State private var showInfo = false;
    
    var body: some View {
        VStack {
            Image("TrollFX")
                .resizable()
                .frame(width: 128.0, height: 128.0)
                .cornerRadius(32.0)
            Text("TrollFX")
                .font(.title)
                .fontWeight(.bold)
            Button("Replace Charge Sound ;D", action: OverWriteLockSoundWithFart)
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
                    title: Text("TrollFX (\(MOD_VERSION))"),
                    message: Text("Developed by Apricot")
                )
            }
        }
    }
}

struct TrollFXView_Previews: PreviewProvider {
    static var previews: some View {
        TrollFXView()
    }
}
