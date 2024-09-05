//
//  PostsView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 05/09/2024.
//

import SwiftUI

struct PostsView: View {
    @State private var createNewPost: Bool = false
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .hAlign(.center).vAlign(.center)
            .overlay(alignment: .bottomTrailing){
                Button{
                    createNewPost.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(13)
                        .background(.black,in: Circle())
                }
                .padding(15)
            }
            .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPost{ post in
                    
                }
            }
    }
}

#Preview {
    PostsView()
}
