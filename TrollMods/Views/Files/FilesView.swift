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
                            let vc = UIHostingController(rootView: PlistEditorView(path: path + file.name, plist: plist, keys: keys, values: values, types: types))
                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
                        } else {
                            print(path + file.name)
                            let data = FileManager.default.contents(atPath: path + file.name)
                            let dataString = String(decoding: data!, as: UTF8.self)
                            print(dataString)
                            
                            // use TextEditor to edit the file
                            let vc = UIHostingController(rootView: TextEditorView(path: path + file.name))
                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
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

struct PlistEditorView: View {
    @State var path: String
    @State var plist: [String: Any] = [:]
    @State var keys: [String] = []
    @State var values: [String] = []
    @State var types: [String] = []
    @State var newKey: String = ""
    @State var newValue: String = ""
    @State var newType: String = "String"
    @State var showAdd: Bool = false
    @State var showEdit: Bool = false
    @State var editIndex: Int = 0
    @State var showDelete: Bool = false
    @State var deleteIndex: Int = 0
    var body: some View {
        VStack {
            List {
                ForEach(keys.indices, id: \.self) { index in
                    HStack {
                        // check if they're in range
                        if index < keys.count && index < values.count && index < types.count {
                            Text(keys[index])
                                .font(.headline)
                            Spacer()
                            Text(values[index])
                                .font(.subheadline)
                            Text(types[index])
                                .font(.subheadline)
                        }
                    }
                    .onTapGesture {
                        showEdit = true
                        editIndex = index
                    }
                    .contextMenu {
                        Button(action: {
                            showEdit = true
                            editIndex = index
                        }) {
                            Text("Edit")
                        }
                        Button(action: {
                            showDelete = true
                            deleteIndex = index
                        }) {
                            Text("Delete")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                VStack {
                    Text("Add Key")
                        .font(.title)
                    TextField("Key", text: $newKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Value", text: $newValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Picker("Type", selection: $newType) {
                        Text("String").tag("String")
                        Text("Integer").tag("Integer")
                        Text("Boolean").tag("Boolean")
                        Text("Float").tag("Float")
                        Text("Double").tag("Double")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Button(action: {
                        if newKey != "" && newValue != "" {
                            keys.append(newKey)
                            values.append(newValue)
                            types.append(newType)
                            newKey = ""
                            newValue = ""
                            newType = "String"
                            showAdd = false
                        }
                    }) {
                        Text("Add")
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showEdit) {
                VStack {
                    Text("Edit Key")
                        .font(.title)
                    TextField("Key", text: $keys[editIndex])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Value", text: $values[editIndex])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Picker("Type", selection: $types[editIndex]) {
                        Text("String").tag("String")
                        Text("Integer").tag("Integer")
                        Text("Boolean").tag("Boolean")
                        Text("Float").tag("Float")
                        Text("Double").tag("Double")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Button(action: {
                        showEdit = false
                    }) {
                        Text("Done")
                    }
                }
                .padding()
            }
            .alert(isPresented: $showDelete) {
                Alert(title: Text("Delete Key"), message: Text("Are you sure you want to delete the key \(keys[deleteIndex])?"), primaryButton: .destructive(Text("Delete")) {
                    keys.remove(at: deleteIndex)
                    values.remove(at: deleteIndex)
                    types.remove(at: deleteIndex)
                    showDelete = false
                }, secondaryButton: .cancel())
            }
            HStack {
                Button(action: {
                    showAdd = true
                }) {
                    Text("Add")
                }
                Spacer()
                Button(action: {
                    // save the plist
                    for index in keys.indices {
                        if types[index] == "String" {
                            plist[keys[index]] = values[index]
                        } else if types[index] == "Integer" {
                            plist[keys[index]] = Int(values[index])
                        } else if types[index] == "Boolean" {
                            plist[keys[index]] = Bool(values[index])
                        } else if types[index] == "Float" {
                            plist[keys[index]] = Float(values[index])
                        } else if types[index] == "Double" {
                            plist[keys[index]] = Double(values[index])
                        }
                    }
                    let data = try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                    // use the CVE to write the file
                    if (OverwriteFile(newFileData: data, targetPath: path)) {
                        // alert the user that the file was saved
                        let alert = UIAlertController(title: "Success", message: "The file was saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    } else {
                        // alert the user that the file was not saved
                        let alert = UIAlertController(title: "Error", message: "The file was not saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }) {
                    Text("Save")
                }
            }
        }
        .onAppear {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
            for (key, value) in plist {
                keys.append(key)
                if value is String {
                    values.append(value as! String)
                    types.append("String")
                } else if value is Int {
                    values.append(String(value as! Int))
                    types.append("Integer")
                } else if value is Bool {
                    values.append(String(value as! Bool))
                    types.append("Boolean")
                } else if value is Float {
                    values.append(String(value as! Float))
                    types.append("Float")
                } else if value is Double {
                    values.append(String(value as! Double))
                    types.append("Double")
                }
            }
        }
    }
}

// TextEditorView, a view that allows the user to edit a file if it isn't a plist
struct TextEditorView: View {
    @State var path: String
    @State var text: String = ""
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding()
            HStack {
                Spacer()
                Button(action: {
                    // save the file
                    let data = text.data(using: .utf8)!
                    // use the CVE to write the file
                    if (OverwriteFile(newFileData: data, targetPath: path)) {
                        // alert the user that the file was saved
                        let alert = UIAlertController(title: "Success", message: "The file was saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    } else {
                        // alert the user that the file was not saved
                        let alert = UIAlertController(title: "Error", message: "The file was not saved successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }) {
                    Text("Save")
                }
            }
        }
        .onAppear {
            do {
                text = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            } catch {
                let alert = UIAlertController(title: "Error", message: "The file could not be opened.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: {
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                })
            }
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
