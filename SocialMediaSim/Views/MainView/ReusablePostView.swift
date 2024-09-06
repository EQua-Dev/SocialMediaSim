//
//  ReusablePostView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 06/09/2024.
//

import SwiftUI
import FirebaseFirestore

struct ReusablePostView: View {
    @Binding var posts: [Post]
    /// - View Properties
    @State var isFetching: Bool = true
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            /// By using LazyVStack it removes the contents when its moved out of the screen.
            /// allowing us to use onAppear() and onDisAppear() to get notified when its actually entering/ leaving the screen
            LazyVStack{
                if isFetching{
                    ProgressView()
                        .padding(.top,30)
                }else{
                    if posts.isEmpty{
                        /// No posts found on firestore
                        Text("No Posts Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }else{
                        /// - Displaying Posts
                        Posts()
                        
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            isFetching = true
            posts = []
            await fetchPosts()
        }
        .task {
            /// - Fetching for First Time
            guard posts.isEmpty else{return}
            await fetchPosts()
        }
    }
    
    /// - Displaying Fetched Posts
    @ViewBuilder
    func Posts()-> some View{
        ForEach(posts){post in
            PostCardView(post: post){ updatedPost in
                /// Updating the Post in the Array
                if let index = posts.firstIndex(where: {post in
                    post.id == updatedPost.id
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                /// Removing Post From the Array
                withAnimation(.easeInOut(duration: 0.25)){
                    posts.removeAll{post == $0}
                }
            }
            
            Divider().padding(.horizontal,-15)
        }
    }
    
    /// - Fetching Posts
    func fetchPosts()async{
        do{
            var query : Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{ doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
    
}

//#Preview {
//    ReusablePostView()
//}
