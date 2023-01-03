//
//  TrollLockModView.swift
//  TrollMods
//
//  Created by Chris on 2022-12-27.
//

import SwiftUI
import Zip

private let trollLockVersion: String = "v1.0";
private let globalLockPaths: [String] = [
	"3x-d73",
	"3x-896h",
	"3x-812h",
	"2x-896h",
	"2x-812h",
];
private let deviceLockPath: [String: String] = [
	"iPhone15,3": "3x-d73", // iPhone 14 Pro Max
	"iPhone15,2": "3x-d73", // iPhone 14 Pro
	"iPhone14,7": "3x-812h", // iPhone 14
	
	"iPhone14,3": "3x-812h", // iPhone 13 Pro Max
	"iPhone14,2": "3x-812h", // iPhone 13 Pro
	"iPhone14,5": "3x-812h", // iPhone 13
	"iPhone14,4": "3x-812h", // iPhone 13 Mini
	
	"iPhone13,4": "3x-896h", // iPhone 12 Pro Max
	"iPhone13,3": "3x-812h", // iPhone 12 Pro
	"iPhone13,2": "3x-812h", // iPhone 12
	"iPhone13,1": "3x-812h", // iPhone 12 Mini
	
	"iPhone12,5": "3x-812h", // iPhone 11 Pro Max
	"iPhone12,3": "2x-896h", // iPhone 11 Pro
	"iPhone12,1": "2x-812h", // iPhone 11
	
	"iPhone11,8": "2x-812h", // iPhone XR
	"iPhone11,4": "3x-896h", // iPhone XS Max (China)
	"iPhone11,6": "3x-896h", // iPhone XS Max
	"iPhone11,2": "3x-812h", // iPhone XS
	
	"iPhone10,3": "3x-812h", // iPhone X (GSM)
	"iPhone10,6": "3x-812h", // iPhone X (Global)
];

// Thank you StackOverflow!!
extension UIDevice {
	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		return identifier
	}
}

func TrollLockReplace(path: URL, targetLockPath: String) {
	DispatchQueue.global(qos: .userInteractive).async {
		// /var/mobile/Containers/Data/Application//Documents/TrollLock/main.caml
		let sourceFilePath = path.appendingPathComponent("main.caml");
		print(sourceFilePath);
		
		let targetPath = "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@\(targetLockPath).ca/main.caml";
		debugPrint(targetPath);
		
		do {
			let files = try FileManager.default.contentsOfDirectory(atPath: "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@\(targetLockPath).ca/");
			debugPrint(files);
			
			let mainCamlContents = try String(contentsOf: URL.init(fileURLWithPath: targetPath), encoding: .utf8);
			
			print("-- start old --");
			print(mainCamlContents);
			print("--- end old ---")
		} catch {
			print(error);
		}
		
		
		/* TODO: Load custom animation file from lockpack.zip
		 var lockPackCamlContents: Data;
		 
		 do {
		 lockPackCamlContents = try Data(contentsOf: path.appendingPathComponent("main.caml"));
		 } catch {
		 lockPackCamlContents = mainCaml.data(using: .utf8)!
		 }
		 */
		
		
		let lockPackCamlContents = TrollLockInjectIntoAnimation(lockPack: path);
		
		do {
			try lockPackCamlContents.write(to: sourceFilePath, atomically: true, encoding: .utf8);
			print("Written lock pack contents to \(sourceFilePath.absoluteString)");
		} catch {
			print("Failed to write lock pack main.caml to documents directory: \(error)");
		}
		
		let success = OverwriteFile(newFileData: lockPackCamlContents.data(using: .utf8)!, targetPath: targetPath);
		print("Success: \(success)");
		
		do {
			let files = try FileManager.default.contentsOfDirectory(atPath: "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@\(targetLockPath).ca/");
			debugPrint(files);
			
			let mainCamlContents = try String(contentsOf: URL.init(fileURLWithPath: targetPath), encoding: .utf8);
			
			print("-- start new --");
			print(mainCamlContents);
			print("--- end new ---");
			print("size new: \(mainCamlContents.count)");
		} catch {
			print(error);
		}
	}
}

func TrollLockInjectIntoAnimation(lockPack: URL) -> String {
	var xCaml: String = "";
	do {
		let defaultAnimation = Bundle.main.url(forResource: "baseLockAnimation", withExtension: "caml")!;
		xCaml = try String(contentsOf: defaultAnimation, encoding: .utf8); //.replacingOccurrences(of: "\\B\\s+|\\s+\\B", with: "", options: .regularExpression);
	} catch {
		print("Failed to load default lock animation: \(error)");
	}
	
	for i in 1...40 {
		let trollFile = lockPack.appendingPathComponent("trollformation\(i).png").absoluteString.replacingOccurrences(of: "file://", with: "");
		print(trollFile);
		xCaml = xCaml.replacingOccurrences(of: "trolling\(i)x", with: trollFile);
	}
	
	return xCaml;
}

func TrollLockLoadAndReplace(url: String, targetLockPath: String) {
	let task = URLSession.shared.downloadTask(with: URL(string: url)!) { data, response, error in
		if let data = data {
			debugPrint(data);
			
			// /var/mobile/Containers/Data/Application//Documents
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
			debugPrint(documentsDirectory);
			
			// /var/mobile/Containers/Data/Application//Documents/TrollLock
			let filePath = documentsDirectory.appendingPathComponent("TrollLock");
			debugPrint(filePath);
			
			do {
				// /private/var/mobile/Containers/Data/Application//tmp/CFNetworkDownload_6yxAQa.tmp.zip
				let dataZip = data.appendingPathExtension("zip");
				try FileManager.default.moveItem(at: data, to: dataZip);
				debugPrint(dataZip);
				
				// -> /var/mobile/Containers/Data/Application//Documents/TrollLock
				try Zip.unzipFile(dataZip, destination: filePath, overwrite: true, password: nil);
				print("Unzipped!");
				
				TrollLockReplace(path: filePath, targetLockPath: targetLockPath);
			} catch {
				debugPrint("Failed to move or unzip file: \(error)");
			}
		} else if let error = error {
			debugPrint("Error loading data from provided url: \(error)");
		}
	}
	task.resume();
}

struct TrollLockView: View {
	@State private var showInfoPrompt = false;
	@State private var showTweakPrompt = false;
	@State private var showFolderPrompt = false;
	@State private var showCustomPackPrompt = false;
	@State private var showLoadCustomPackPrompt = false;
	
	@State private var customPackURL = "https://github.com/Gluki0/icons-for-TrollLock/releases/download/icons/windowshello.zip";
	
	@State private var targetLockPath = "";
	
	private let lockPathRecommendation = deviceLockPath[UIDevice.current.modelName];
	
	var body: some View {
		VStack {
			Image("TrollLock")
				.resizable()
				.frame(width: 128.0, height: 128.0)
			Text("TrollLock")
				.font(.title)
				.fontWeight(.bold)
			Button("Start", action: { showTweakPrompt = true })
				.controlSize(.large)
				.tint(.blue)
				.buttonStyle(.bordered)
				.alert(isPresented: $showTweakPrompt) {
					Alert(
						title: Text("Warning!"),
						message: Text("The developers shall not be held responsible for any possible damage done to your device. Press Begin if you understand the risks and are willing to take them."),
						primaryButton: .default(
							Text("Cancel"),
							action: {}
						),
						secondaryButton: .destructive(
							Text("Begin"),
							action: {
								showFolderPrompt = true;
							}
						)
					)
				}
				.confirmationDialog("Devices have multiple lock folders, but only one must be modified. Based on your device the best choice is \(lockPathRecommendation ?? "unknown. Try each folder and respring between each try until you find the one that works for you").",
									isPresented: $showFolderPrompt,
									titleVisibility: .visible,
									actions: {
					ForEach(globalLockPaths, id: \.self) { folder in
						Button(folder, action: {
							targetLockPath = folder;
							showCustomPackPrompt = true;
						});
					}
				})
				.alert("Which lock pack to use?", isPresented: $showCustomPackPrompt) {
					//Button("Use last", action: { showCustomPackPrompt = false })
					Button("Use custom from URL", action: { showLoadCustomPackPrompt = true })
					Button("Use default (Trollface)", action: { TrollLockReplace(path: Bundle.main.resourceURL!, targetLockPath: targetLockPath) })
				}
				.alert("Load lock pack from URL", isPresented: $showLoadCustomPackPrompt, actions: {
					TextField("Pack URL", text: $customPackURL)
					Button("Load", action: { TrollLockLoadAndReplace(url: customPackURL, targetLockPath: targetLockPath) })
					Button("Cancel", role: .cancel, action: {})
				})
		}
		.toolbar {
			Button(action: { showInfoPrompt = true }) {
				Image(systemName: "info.circle")
			}
			.alert(isPresented: $showInfoPrompt) {
				Alert(
					title: Text("TrollLock Reborn (\(trollLockVersion))"),
					message: Text("Made with ♡ by Nathan & haxi0")
				)
			}
		}
	}
}
