//
//  ContentView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ModsView()
                .tabItem {
                    Label("Mods", systemImage: "paintbrush")
                }
            FilesView()
                .tabItem {
                    Label("File Browser", systemImage: "folder")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
