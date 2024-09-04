//
//  Post.swift
//  SocialMediaSim
//
//  Created by Richard Uzor on 04/09/2024.
//

import Foundation
import FirebaseFirestore


//MARK: Post Model

struct Post: Identifiable, Codable{
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var disliked: [String] = []
    //MARK: User Basic Info
    var userName: String
    var userUID: String
    var userProfileURL: String
    
    
    enum CodingKeys: CodingKey{
        case id
        case text
        case imageURL
        case imageReferenceID //Used for deletion
        case publishedDate
        case likedIDs
        case disliked
        case userName
        case userUID
        case userProfileURL
        
    }
    
}
