//
//  InfoModel.swift
//  Anapa
//
//  Created by Сергей Майбродский on 22.01.2023.
//

import Foundation
import PromiseKit

struct InfoModel {
    //MARK: get info blocks
    static func fetchInfoBlocks(category: Int?, search: String?, page: Int?) -> Promise<InfoResposne>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/infos/")
        if category != nil {
            url = url.appending("category", value: "\(category ?? 0)")
        }
        if search != nil {
            url = url.appending("search", value: search)
        }
        if page != nil {
            url = url.appending("page", value: "\(page ?? 0)")
        }
        return CoreNetwork.request(method: .GET(url: url))
    }
}

struct InfoResposne: Codable {
    let message: String
    let meta: MetaPage?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: [Info?]
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

// MARK: - Datum
struct Info: Codable, Hashable {
    var id: Int?
    let title, body: String?
    let category, created: Int?
    let image: String?
    var user: Profile?
    var source: String?
}
