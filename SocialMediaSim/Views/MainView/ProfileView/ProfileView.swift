//
//  ProfileView.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 01/09/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    //MARK: My Profile Data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    //MARK: Error Message
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    
    @State var isLoading: Bool = false
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    ReusableProfileContent(user: myProfile)
                        .refreshable{
                            // MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                        }
                }else{
                    ProgressView()
                }
            }
            
            
            .navigationTitle("My Profile")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu {
                        // MARK: Two Actions
                        // 1. Logout
                        // 2. Delete Account
                        Button("Logout"){
                            logOutUser()
                        }
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay{
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError){}
        .task {
            
            /**
             This Modifier is like onAppear. So, fetching for the first time only
             - Since Task is an alternative to onAppear, which is an async call, whwneve the tab is changed and reopened, it wil be called like onAppear.
             - That's why we're limiting it ti the inital fetch (First Time) only
             */
            if myProfile != nil{return}
            // MARK: Initial Fetch
            await fetchUserData()
        }
    }
    
    //MARK: Fetching User Data
    func fetchUserData()async{
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
        else {return}
        await MainActor.run {
            myProfile = user
        }
    }
    //MARK: Logging User Out
    func logOutUser(){
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    // MARK: Deleting User Entire Account
    func deleteAccount(){
        isLoading = true
        Task{
            do{
                guard let UserUID = Auth.auth().currentUser?.uid else{return}
                // Step 1: First Deleting Profile Image From Storage
                let reference = Storage.storage().reference().child("Profile_Images").child(UserUID)
                try await reference.delete()
                // Step 2: Deleting Firestore User Document
                try await Firestore.firestore().collection("Users").document(UserUID).delete()
                // Final Step: Deleting the Auth Account and Setting Log Status to false
                try await Auth.auth().currentUser?.delete()
                logStatus = false
                
            }catch{
                await setError(error)
            }
            
        }
    }
    
    //MARK: Setting Error
    func setError(_ error: Error) async{
        //MARK: UI Must be run in Main  Thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

#Preview {
    ProfileView()
}
