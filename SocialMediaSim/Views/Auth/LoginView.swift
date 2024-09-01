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

#Preview {
    LoginView()
}
