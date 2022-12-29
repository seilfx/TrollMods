//
//  ContentView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                // TODO: Move to a for loop.
                /*NavigationLink(destination: TrollMods.TrollLockView()) {
                    HStack {
                        Image("TrollLock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                            .cornerRadius(8)
                        Text("TrollLock")
                    }
                }*/
                
                NavigationLink(destination: TrollMods.TrollFXView()) {
                    HStack {
                        Image("TrollFX")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                            .cornerRadius(8)
                        Text("TrollFX")
                    }
                }
            }
            .navigationTitle("TrollMods")
            
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
