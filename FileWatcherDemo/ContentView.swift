//
//  ContentView.swift
//  FileWatcherDemo
//
//  Created by Kyaw Zay Ya Lin Tun on 21/06/2025.
//

import SwiftUI

struct Profile: Codable {
  var username: String?
  var displayName: String?
  var gender: String?
}

struct ContentView: View {
  private let fileWatcher: FileWatcher
  @State private var profile: Profile?
  
  init() {
    var codePath = #file.components(separatedBy: "/")
    codePath.removeLast(1)
    let json = codePath.joined(separator: "/") + "/Profile.json"
    fileWatcher = .init(path: json)
  }
  
  var body: some View {
    NavigationStack {
      List {
        Text(profile?.username ?? "-")
        Text(profile?.displayName ?? "-")
        Text(profile?.gender ?? "-")
      }
      .navigationTitle("FileWatcherDemo")
      .onAppear {
        fileWatcher.startObserving { data in
          guard let data else { return }
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          self.profile = try? decoder.decode(Profile.self, from: data)
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
