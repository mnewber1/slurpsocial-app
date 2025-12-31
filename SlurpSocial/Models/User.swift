//
//  User.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var bio: String?
    var joinDate: Date
    var ramenCount: Int

    init(id: UUID = UUID(), username: String, email: String, displayName: String, profileImageURL: String? = nil, bio: String? = nil, joinDate: Date = Date(), ramenCount: Int = 0) {
        self.id = id
        self.username = username
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.joinDate = joinDate
        self.ramenCount = ramenCount
    }
}
