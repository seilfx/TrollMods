//
//  TrollHomeView.swift
//  TrollMods
//
//  Created by Chris on 2023-01-03.
//

import SwiftUI

private var MOD_VERSION = "v0.1";

func cleanSpringboardHome(hideDock: Bool, hideFolder: Bool,hideHomeBar: Bool) {
    if (hideDock) { removeDockBackground() }
    if (hideFolder) { removeFolderBackground() }
    if (hideHomeBar) { removeHomeBarBackground() }
}

struct TrollHomeView: View {
    @State private var showInfo = false;
    
    @AppStorage("TH_HideFolderBackground") private var hideFolderBackground = false;
    @AppStorage("TH_HideDockBackground") private var hideDockBackground = false;
    @AppStorage("TH_HideHomeBar") private var hideHomeBarBackground = false;
    var body: some View {
        VStack {
            Image("TrollHome")
                .resizable()
                .frame(width: 128.0, height: 128.0)
                .cornerRadius(32.0)
            Text("TrollHome")
                .font(.title)
                .fontWeight(.bold)
            List {
                Toggle(isOn: $hideFolderBackground) {
                    Text("Hide folder background")
                }
                
                Toggle(isOn: $hideDockBackground) {
                    Text("Hide dock background")
                }
                Toggle(isOn: $hideHomeBarBackground){
                    Text("Hide HomeBar")
                }
            }
        }
        
        .toolbar {
            Button(action: { showInfo = true }) {
                Image(systemName: "info.circle")
            }
            .alert(isPresented: $showInfo) {
                Alert(
                    title: Text("TrollHome (\(MOD_VERSION))"),
                    message: Text("Developed by Apricot, iSource and Kieran")
                )
            }
        }
        
        Button("Apply Changes", action: { cleanSpringboardHome(hideDock: hideDockBackground, hideFolder: hideFolderBackground, hideHomeBar: hideHomeBarBackground)}  )
            .controlSize(.large)
            .tint(.blue)
            .buttonStyle(.bordered)
        Button("Respring", action: {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                guard let window = UIApplication.shared.windows.first else { return }
                while true {
                    window.snapshotView(afterScreenUpdates: false)
                }
            }
        })
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(.red);
    }
}

struct TrollHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TrollHomeView()
    }
}
