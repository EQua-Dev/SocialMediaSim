//
//  SocialMediaSimApp.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 27/08/2024.
//

import SwiftUI
import Firebase

@main
struct SocialMediaSimApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
