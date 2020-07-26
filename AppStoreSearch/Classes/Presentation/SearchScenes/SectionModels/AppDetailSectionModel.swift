//
//  AppDetailSectionModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxDataSources

///detail section model
enum DetailSection: IdentifiableType, Equatable {
    case header(SearchResultApp)
    case whatsNew(SearchResultApp)
    case preview(SearchResultApp)
    case description(SearchResultApp)
    case information(AppInformationType)
//    case review //- API 정보 제공안됨
//    case supports
//    case more
//    case alsoLike
    
    typealias Identity = String
    var identity : Identity {
        switch self {
        case .header:
            return "header"
        case .whatsNew:
            return "whatsNew"
        case .preview:
            return "preview"
        case .description:
            return "description"
        case .information:
            return "information"
        }
    }
}

func == (lhs: DetailSection, rhs: DetailSection) -> Bool {
    return lhs.identity == rhs.identity
}

///app detail information
struct AppInformationType {
    var subject: String
    var content: String
    var isLink: Bool = false
}

///app detail sectiomodel
struct AppDetailSectionModel {
    var items: [DetailSection]
}

extension AppDetailSectionModel: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = DetailSection
    
    var identity: Identity {
        return items.first!.identity
    }
    
    init(original: AppDetailSectionModel, items: [DetailSection]) {
        self = original
        self.items = items
    }
}

///screenshot section model
struct ScreenshotSectionModel {
    var items: [String]
}

extension ScreenshotSectionModel: SectionModelType {
    typealias Item = String
    
    init(original: ScreenshotSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
