//
//  SearchResultApp.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxDataSources

///결과 앱 모델
struct SearchResultApp: Decodable {
    var id: Int
    var name: String
    var artistName: String
    var genre: String
    var artwork: String
    var rating: Double?
    var currentRating: Double?
    var ratingCount: Int?
    var currentRatingCount: Int?
    var screenshots: [String]?
    var contentAdvisoryRating: String?
    var version: String?
    var releaseDate: Date?
    var currentReleaseDate: Date?
    var releaseNotes: String?
    var description: String?
    var sellerName: String
    var fileSize: String?
    var sellerUrl: String?

    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case name = "trackName"
        case artistName = "artistName"
        case genre = "primaryGenreName"
        case artwork = "artworkUrl512"
        case rating = "averageUserRating"
        case currentRating = "averageUserRatingForCurrentVersion"
        case ratingCount = "userRatingCount"
        case currentRatingCount = "userRatingCountForCurrentVersion"
        case screenshots = "screenshotUrls"
        case contentAdvisoryRating = "contentAdvisoryRating"
        case version = "version"
        case releaseDate = "releaseDate"
        case currentReleaseDate = "currentVersionReleaseDate"
        case releaseNotes = "releaseNotes"
        case description = "description"
        case sellerName = "sellerName"
        case sellerUrl = "sellerUrl"
        case fileSize = "fileSizeBytes"
    }
}

extension SearchResultApp: IdentifiableType {
    typealias Identity = Int
    var identity : Identity {
        return self.id
    }
}

extension SearchResultApp: Equatable { }

func == (lhs: SearchResultApp, rhs: SearchResultApp) -> Bool {
    return lhs.id == rhs.id
}
