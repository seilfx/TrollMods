//
//  FilesView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-31.
//

import SwiftUI

private var folderCache: [String: [Folder]] = [:]
private var fileCache: [String: [File]] = [:]

struct ListItem: View {
    var file: File
    var body: some View {
        HStack {
            Image(systemName: "doc")
                .resizable()
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text(file.name)
                    .font(.headline)
                Text(file.type)
                    .font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(file.size)
                    .font(.subheadline)
                Text(file.date)
                    .font(.subheadline)
            }
        }
    }
}

struct FileList: View {
    @State var path: String = "/"
    @State private var folders: [Folder] = []
    @State private var files: [File] = []
    @State private var directoryIsEmpty: Bool = false;
    @State private var isSearching: Bool = true;
    
    private func loadDirectory(refreshDirectory: Bool) {
        guard (folderCache[path] == nil) || refreshDirectory else {
            print("No need to refresh directory.")
            
            folders = (folderCache[path] ?? [])
            files = (fileCache[path] ?? [])
            
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            isSearching = true
            
            let directoryContent = loadPath(atPath: path)
            
            folderCache[path] = directoryContent.folders
            folders = (folderCache[path] ?? [])
            
            fileCache[path] = directoryContent.files
            files = (fileCache[path] ?? [])
            
            if folders.isEmpty && files.isEmpty {
                directoryIsEmpty = true
            }
            
            isSearching = false
        }
    }
    
    var body: some View {
        if (isSearching && folderCache[path] == nil) {
            VStack {
                Text("Please wait, loading folders.")
            }
            .onAppear(perform: { loadDirectory(refreshDirectory: false) })
        } else {
            List {
                ForEach(folders.sorted(by: { $0.name < $1.name }), id: \.id) { folder in
                    NavigationLink(destination: FileList(path: "\(path)\(folder.name)/")) {
                        HStack {
                            Image(systemName: "folder")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(folder.name)
                                .font(.headline)
                        }
                    }
                }
                
                ForEach(files.sorted(by: { $0.name < $1.name }), id: \.id) { file in
                    Button(action: {
                        // if the file is a plist, open the plist editor
                        if file.type == "plist" || file.type == "strings" {
                            let data = FileManager.default.contents(atPath: path + file.name)
                            let plist = try! PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as! [String: Any]
                            let keys = plist.keys.sorted()
                            var values: [String] = []
                            var types: [String] = []
                            for key in keys {
                                let value = plist[key]!
                                values.append("\(value)")
                                types.append("\(type(of: value))")
                            }
                            /*let vc = UIHostingController(rootView: PlistEditorView(path: path + file.name, plist: plist, keys: keys, values: values, types: types))
                             UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)*/
                        } else {
                            // use TextEditor to edit the file
                            /*let vc = UIHostingController(rootView: TextEditorView(path: path + file.name))
                             UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)*/
                        }
                    }) {
                        ListItem(file: file)
                    }
                }
                
                if (directoryIsEmpty) {
                    Section {
                        Text("This folder is inaccessible by TrollMods.")
                        Text("If you know where you want to go, you may enter the folder path below:")
                    }
                    TextField("Destination path", text: $path)
                    Button("Go!", action: {
                        if path.last != "/" {
                            path = "\(path)/"
                        }
                        
                        loadDirectory(refreshDirectory: false)
                    })
                    .tint(.blue)
                }
            }
            .navigationTitle(path)
            .toolbar {
                if(!isSearching) {
                    Button(action: { loadDirectory(refreshDirectory: true) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear(perform: { loadDirectory(refreshDirectory: false) })
        }
    }
}

struct FilesView: View {
    @State var path: String = "/"
    
    var body: some View {
        NavigationView {
            FileList(path: path)
        }
    }
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView()
    }
}
