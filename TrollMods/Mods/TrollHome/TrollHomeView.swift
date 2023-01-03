//
//  TrollHomeView.swift
//  TrollMods
//
//  Created by Chris on 2023-01-03.
//

import SwiftUI

private var MOD_VERSION = "v0.1";

func cleanSpringboardHome(hideDock: Bool, hideFolder: Bool) {
    if (hideDock) { removeDockBackground() }
    if (hideFolder) { removeFolderBackground() }
}

struct TrollHomeView: View {
    @State private var showInfo = false;
    
    @AppStorage("TH_HideFolderBackground") private var hideFolderBackground = false;
    @AppStorage("TH_HideDockBackground") private var hideDockBackground = false;
    
    var body: some View {
        VStack {
            Image("")
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
        
        Button("Apply Changes", action: { cleanSpringboardHome(hideDock: hideDockBackground, hideFolder: hideFolderBackground)}  )
            .controlSize(.large)
            .tint(.blue)
            .buttonStyle(.bordered)
    }
}

struct TrollHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TrollHomeView()
    }
}
