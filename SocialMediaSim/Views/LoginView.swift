//
//  LoginView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 27/08/2024.
//

import SwiftUI
import PhotosUI //For Native SwiftUI Image Picker
import FirebaseAuth

struct LoginView: View {
    // MARK: User Details
    
    @State var emailID: String = ""
    @State var password: String = ""
    //MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
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
        
        //MARK: Register View Via Sheet
            .fullScreenCover(isPresented: $createAccount){
                RegisterView()
            }
        
        // MARK: Displaying Alert
            .alert(errorMessage, isPresented: $showError, actions:{})
    }
    
    func loginUser(){
        Task{
            do{
                // with the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
            }catch{
                await setError(error)
            }
        }
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
            
            TextField("Username", text: $emailID).textContentType(.emailAddress).border(1, .gray.opacity(0.5)).padding(.top, 15)
            
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
        }
        
    }
    
    func registerUser(){
        
    }
    
}

#Preview {
    LoginView()
}

//MARK: View Extensions For UI Building
extension View{
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


