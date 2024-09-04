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
    }
    
    //MARK: Post Content To Firebase
    func createPost(){
        
    }
}

#Preview {
    CreateNewPost{_ in
    }
}
