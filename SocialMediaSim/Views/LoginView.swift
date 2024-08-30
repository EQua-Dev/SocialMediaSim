//
//  LoginView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 27/08/2024.
//

import SwiftUI
import PhotosUI //For Native SwiftUI Image Picker
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    // MARK: User Details
    
    @State var emailID: String = ""
    @State var password: String = ""
    //MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    //MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileUrl: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    
    var body: some View {
        VStack(spacing: 10){
            Text("Let's Sign You In").font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back,\nYou have been missed").font(.title3).hAlign(.leading)
            
            VStack(spacing: 12){
                TextField("Email", text: $emailID).textContentType(.emailAddress).border(1, .gray.opacity(0.5)).padding(.top, 15)
                
                SecureField("Password", text: $password).textContentType(.emailAddress).border(1, .gray.opacity(0.5))
                
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button{
                    loginUser()
                } label: {
                    //MARK: Login Button
                    Text("Login").foregroundColor(.white).hAlign(.center)
                        .fillView(.black)
                }  .padding(.top, 10)
            }
            
            //MARK: Register Button
            HStack{
                Text("Don't have an account?").foregroundColor(.gray)
                
                Button("Register Now"){
                    createAccount.toggle()
                }.fontWeight(.bold).foregroundColor(.black)
            }.font(.callout)
                .vAlign(.bottom)
            
            
        }.vAlign(.top)
            .padding(15)
            .overlay(content: {
                LoadingView(show: $isLoading)
            })
        
        //MARK: Register View Via Sheet
            .fullScreenCover(isPresented: $createAccount){
                RegisterView()
            }
        
        // MARK: Displaying Alert
            .alert(errorMessage, isPresented: $showError, actions:{})
    }
    
    func loginUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                // with the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: If User is Found, Then Fetch User Data from Firestore
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
    
        //MARK: UI Updating Must be Run on Main Thread
        await MainActor.run(body: {
            // Setting UserDefaults data and Changing App's Auth Status
            userNameStored = user.username
            self.userUID = userUID
            profileUrl = user.userProfileURL
            logStatus = true
            
        })
    }
    
    func resetPassword(){
        Task{
            do{
                // with the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error) async {
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
}

// MARK: Register View
struct RegisterView: View{
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var username: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    
    //MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    //MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileUrl: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    
    var body: some View{
        
        VStack(spacing: 10){
            
            Text("Let's Register\nAccount").font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello User, have a wonderful journey").font(.title3).hAlign(.leading)
            
            // MARK: For Smaller Size Optimization
            /**
             Why ViewThatFits: It automatically enables scrolling on smaller screen sizes
             */
            ViewThatFits{
                ScrollView(.vertical, showsIndicators: false){
                    HelperView()
                }
                HelperView()
            }
            
            
            //MARK: Register Button
            HStack{
                Text("Already have an account?").foregroundColor(.gray)
                
                Button("Login Now"){
                    dismiss()
                }.fontWeight(.bold).foregroundColor(.black)
            }.font(.callout)
                .vAlign(.bottom)
            
            
        }.vAlign(.top)
            .padding(15)
            .overlay(content: {
                LoadingView(show: $isLoading)
            })
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem){ newValue in
                // MARK: Extracting UIImage from PhotoItem
                if let newValue{
                    Task{
                        do{
                            guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                            
                            // MARK: UI Must Be Updated on Main Thread
                            await MainActor.run(body: {userProfilePicData = imageData})
                        }
                    }
                }
            }
        //MARK: Displaying Alert
            .alert(errorMessage, isPresented: $showError, actions: {})
    }
    @ViewBuilder
    func HelperView()->some View{
        VStack(spacing: 12){
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else{
                    Image(systemName:"person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            
            TextField("Username", text: $username).textContentType(.emailAddress).border(1, .gray.opacity(0.5)).padding(.top, 15)
            
            TextField("Email", text: $emailID).textContentType(.emailAddress).border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password).textContentType(.emailAddress).border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical).frame(minHeight: 100, alignment: .top).textContentType(.emailAddress).border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional", text: $userBioLink).textContentType(.emailAddress).border(1, .gray.opacity(0.5))
            
            Button{
                registerUser()
            } label: {
                //MARK: Login Button
                Text("Sign Up").foregroundColor(.white).hAlign(.center)
                    .fillView(.black)
            }  .padding(.top, 10)
                .disableWithOpacity(username == "" || emailID == "" || password == "" || userBio == "" || userProfilePicData == nil)
        }
        
    }
    
    func registerUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                // Step 1: Creating Firebase Account
                
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                //Step 2: Uploading Profile Photo Into Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                guard let imageData = userProfilePicData else{return}
                let storageref = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageref.putDataAsync(imageData)
                //Step 3: Downloading Photo URL
                let downloadUrl = try await storageref.downloadURL()
                //Step 4: Creating a User Firestore Object
                let user = User(username: username, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadUrl)
                //Step 5: Saving User Doc into Firebase Database
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil{
                        // MARK: Print Saved Successfully
                        print("Saved Successfully")
                        userNameStored = username
                        self.userUID = userUID
                        profileUrl = downloadUrl
                        logStatus = true
                        //resetFields()
                    }
                })
                
            }catch{
                // MARK: Deleting Created User In Case of Error
//                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    //MARK: Reset Fields
    func resetFields(){
        emailID = ""
        password = ""
        username = ""
        userBio = ""
        userBioLink = ""
        userProfilePicData = nil
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error) async {
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

#Preview {
    LoginView()
}

//MARK: View Extensions For UI Building
extension View{
    
    // Closing all active keyboards
    func closeKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: Disabling with opacity
    func disableWithOpacity(_ condition: Bool)-> some View{
        self.disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ alignment: Alignment)->some View{
        self.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: alignment)
    }
    func vAlign(_ alignment: Alignment)-> some View{
        self.frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: alignment)
    }
    
    //MARK: Custom Border View With Padding
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .stroke(color, lineWidth: width)
                
            }
    }
    
    //MARK: Custom Background View With Padding
    func fillView( _ color: Color) -> some View {
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .fill(color)
                
            }
    }
}


