//
//  PostCardView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 06/09/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseStorage

struct PostCardView: View {
    var post: Post
    /// - Callbacks
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    /// - View Properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration? /// for live updates
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6){
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                /// Post Image if any
                if let postImageURL = post.imageURL{
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }.frame(height: 200)
                }
                PostInteraction()
            }
        }
        .hAlign(.leading)
    }
    
    @ViewBuilder
    func PostInteraction()-> some View{
        HStack(spacing: 6){
            Button(action: likePost) {
                /// whenever its either liked or disliked, we will add the user's UID to the post's liked/disliked array.
                /// and if the array contains the user's UID, then we will highlight the thumb to indicate that its already been liked or disliked
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikePost) {
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown" : "hand.thumbsdown")
            }.padding(.leading, 15)
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }.foregroundColor(.black)
            .padding(.vertical,8)
    }
    
    /// - Liking Post
    func likePost() {
        Task{
            /// Remove the user's UID from the relevant array if the post has already received likes; if not, add the user's UID to the array
            guard let postID = post.id else {return}
            if post.likedIDs.contains(userUID){
                print(userUID)
                /// Removing User ID From the Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
                
            }else{
                print(userUID)
                /// Adding User ID to Liked  Array and removing it from Disliked Array (if Added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    /// - Disiking Post
    func dislikePost() {
        Task{
            /// Remove the user's UID from the relevant array if the post has already received likes; if not, add the user's UID to the array
            guard let postID = post.id else {return}
            if post.dislikedIDs.contains(userUID){
                /// Removing User ID From the Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
                
            }else{
                /// Adding User ID to Liked  Array and removing it from Disliked Array (if Added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayUnion([userUID]),
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
}

