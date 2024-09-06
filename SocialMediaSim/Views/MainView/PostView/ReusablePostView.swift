//
//  ReusablePostView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 06/09/2024.
//

import SwiftUI
import FirebaseFirestore

struct ReusablePostView: View {
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    /// - View Properties
    @State private var isFetching: Bool = true
    /// - Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
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
            /// - Scroll to refresh
            /// Disabling Refresh for UID based posts
            guard !basedOnUID else{return}
            
            isFetching = true
            posts = []
            
            /// - Resetting Pagination Doc
            paginationDoc = nil
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
                    posts.removeAll{post.id == $0.id}
                }
            }
            .onAppear{
                /// - When Last Post Appears, Fetch the New Post (If any)
                if post.id == posts.last?.id && paginationDoc != nil{ /// Check for null in case there are no more pages to fetch
                    Task{await fetchPosts()}
                }
            }
            
            Divider().padding(.horizontal,-15)
        }
    }
    
    /// - Fetching Posts
    ///  - Make it reusable to fetched recent on fo a uid
    func fetchPosts()async{
        do{
            var query : Query!
            /// - Implementing pagination
            if let paginationDoc{
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            }else{
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            
            /// - New Query For UID Based Document Fetch
            /// Simply filter the posts which do not belong to the uid
            if basedOnUID{
                query = query.whereField("userUID", isEqualTo: uid)
            }
           
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap{ doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                /// Saving the last fetched document so that it can be used for pagination in the Firestore
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
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
