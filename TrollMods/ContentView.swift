//
//  ContentView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-27.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("FirstLaunchDisclaimer") var showDisclaimer = true;
    
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
        .alert(isPresented: $showDisclaimer) {
            Alert(
                title: Text("Important!"),
                message: Text("This app should be safe to use, but some users (on iOS 14) have reported not being able to revert changes done with the MacDirtyCow exploit. With that said, The developers shall not be held responsible for any possible damage done to your device. You may continue if you understand the risks and are willing to take them."),
                primaryButton: .default(
                    Text("Cancel"),
                    action: {
                        showDisclaimer = true
                        exit(0)
                    }
                ),
                secondaryButton: .destructive(
                    Text("Continue"),
                    action: {
                        showDisclaimer = false;
                    }
                )
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
