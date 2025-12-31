//
//  RamenPost.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import Foundation
import CoreLocation

struct RamenPost: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var restaurantName: String
    var ramenName: String
    var rating: Double // 1-5 scale
    var review: String?
    var imageURL: String?
    var imageData: Data?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var createdAt: Date
    var likes: Int

    // Ramen-specific attributes
    var brothType: BrothType?
    var spiceLevel: SpiceLevel?
    var noodleTexture: NoodleTexture?

    init(id: UUID = UUID(), userId: UUID, restaurantName: String, ramenName: String, rating: Double, review: String? = nil, imageURL: String? = nil, imageData: Data? = nil, latitude: Double? = nil, longitude: Double? = nil, address: String? = nil, createdAt: Date = Date(), likes: Int = 0, brothType: BrothType? = nil, spiceLevel: SpiceLevel? = nil, noodleTexture: NoodleTexture? = nil) {
        self.id = id
        self.userId = userId
        self.restaurantName = restaurantName
        self.ramenName = ramenName
        self.rating = rating
        self.review = review
        self.imageURL = imageURL
        self.imageData = imageData
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.createdAt = createdAt
        self.likes = likes
        self.brothType = brothType
        self.spiceLevel = spiceLevel
        self.noodleTexture = noodleTexture
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

enum BrothType: String, Codable, CaseIterable {
    case tonkotsu = "Tonkotsu"
    case shoyu = "Shoyu"
    case miso = "Miso"
    case shio = "Shio"
    case tantanmen = "Tantanmen"
    case tsukemen = "Tsukemen"
    case other = "Other"
}

enum SpiceLevel: Int, Codable, CaseIterable {
    case none = 0
    case mild = 1
    case medium = 2
    case hot = 3
    case extreme = 4

    var displayName: String {
        switch self {
        case .none: return "Not Spicy"
        case .mild: return "Mild"
        case .medium: return "Medium"
        case .hot: return "Hot"
        case .extreme: return "Extreme"
        }
    }
}

enum NoodleTexture: String, Codable, CaseIterable {
    case soft = "Soft"
    case medium = "Medium"
    case firm = "Firm"
    case extraFirm = "Extra Firm"
}
