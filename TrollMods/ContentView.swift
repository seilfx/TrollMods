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
                NavigationLink(destination: TrollMods.TrollLockView()) {
                    HStack {
                        Image("TrollLock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                        Text("TrollLock")
                    }
                }
            }
            .navigationTitle("TrollMods")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
