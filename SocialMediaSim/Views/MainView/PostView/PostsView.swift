//
//  PostsView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 05/09/2024.
//

import SwiftUI

struct PostsView: View {
    @State private var recentPosts: [Post] = []
    @State private var createNewPost: Bool = false
    
    var body: some View {
        NavigationStack{
            ReusablePostView(posts: $recentPosts)
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
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing){
                        NavigationLink{
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }
                    }
                })
                .navigationTitle("Posts")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost{ post in
                /// - Adding Created Post at the top of the Recent Posts
                recentPosts.insert(post, at: 0)
                
            }
        }
    }
}

#Preview {
    PostsView()
}
