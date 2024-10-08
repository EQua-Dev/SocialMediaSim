//
//  CreateNewPost.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 04/09/2024.
//

import SwiftUI
import PhotosUI //For Native SwiftUI Image Pickerimport FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct CreateNewPost: View {
    // - Callbacks
    var onPost: (Post) -> ()
    //Post Properties
    @State private var postText: String = ""
    @State private var postImageData: Data?
    
    // - Stored User Data From UserDefaults (AppStorage)
    @AppStorage("user_profile_url") private var profileUrl: URL?
    @AppStorage("user_name") private var userNameStored: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    // - View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool
    
    
    var body: some View {
        VStack{
            HStack{
                Menu{
                    Button("Cancel", role: .destructive){
                        dismiss()
                    }
                }label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.black)
                }
                .hAlign(.leading)
                Button(action: createPost){
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal,20)
                        .padding(.vertical,6)
                        .background(.black, in: Capsule())
                }
                .disableWithOpacity(postText == "")
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 15){
                    TextField("What's Happening?", text: $postText, axis: .vertical)
                        .focused($showKeyboard)
                    
                    if let postImageData, let image = UIImage(data: postImageData){
                        GeometryReader{
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            /// - Delete Button
                                .overlay(alignment: .topTrailing){
                                    Button{
                                        withAnimation(.easeInOut(duration: 0.25)){
                                            self.postImageData = nil
                                        }
                                        
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                        
                    }
                    
                }
                .padding(15)
            }
            
            Divider()
            
            HStack{
                Button{
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.black)
                }.hAlign(.leading)
                Button("Done"){
                    showKeyboard = false
                    
                }
            }
            .padding(.vertical,15)
            .padding(.horizontal,10)
        }.vAlign(.top)
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem){ newValue in
                if let newValue{
                    Task{
                        if let rawImageData = try? await newValue.loadTransferable(type: Data.self),let image = UIImage(data: rawImageData), let compressedImage = image.jpegData(compressionQuality: 0.5){
                            ///UI update must be done on Main Thread
                            await MainActor.run(body: {
                                postImageData = compressedImage
                                photoItem = nil
                            })
                        }
                    }
                }
                
            }
            .alert(errorMessage, isPresented: $showError){
                
            }
        /// - Loading View
            .overlay{
                LoadingView(show: $isLoading)
            }
    }
    
    //MARK: Post Content To Firebase
    func createPost(){
        isLoading = true
        showKeyboard = false
        Task{
            do{
                guard let profileUrl = profileUrl else{return}
                /// Step 1: Uploading Image if any
                /// Used to delete the Post ()
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData{
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    /// Step 3: Create Post Object with Image Id And URL
                    let post = Post(text: postText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userNameStored, userUID: userUID, userProfileURL: profileUrl)
                    try await createDocumentAtFirebase(post)
                }else{
                    /// Step 2: Directly Post Text Data to Firebase (Since there is no image present)
                    let post = Post(text: postText, userName: userNameStored, userUID: userUID, userProfileURL: profileUrl)
                    try await createDocumentAtFirebase(post)
                }
            }catch{
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ post: Post) async throws{
        /// - Wrtitng Document to Firebase Firestore
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post, completion: { error in
            if error == nil {
                /// Post successfully stored in Firebase
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
            }
            
        })
    }
    
    // MARK: Displaying Error as Alert
    func setError(_ error: Error) async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

#Preview {
    CreateNewPost{_ in
    }
}
