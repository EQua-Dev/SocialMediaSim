//
//  MainView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 01/09/2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        //MARK: TabView With Recent Posts and Profile Tab
        TabView{
            PostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Posts")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        // Changing Tab Label Tint to Black
        .tint(.black)
    }
}

#Preview {
    ContentView()
}
