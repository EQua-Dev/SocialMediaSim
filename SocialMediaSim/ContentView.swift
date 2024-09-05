//
//  ContentView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 27/08/2024.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false

    var body: some View {
        //MARK: Redirecting User Based on Log Status
        if logStatus{
            MainView()
        }else{
            LoginView()
        }
        
    }
}

#Preview {
    ContentView()
}
