//
//  SignUpModel.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import Foundation
import PromiseKit

struct RSignUpModel {
    
    //MARK: autorization
    static func fetchLogin(phone: String, code: String) -> Promise<SignUpResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "tel": phone,
            "code": code
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/sign-in/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    
    //MARK: get varification code
    static func fetchVerificationCode(phone: String) -> Promise<VerificationResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data: Data? = try? encoder.encode(["tel": phone])
        let url = Constants.baseURL.appendingPathComponent("/api/v1/verification-codes/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    //MARK: get categories
    static func fetchCategories() -> Promise<AxasAPI<[Category?]>>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/categories/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK: get subcategories
    static func fetchSubcategories(categoryId: Int) -> Promise<AxasAPI<[Category?]>>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/subcategories/")
        url = url.appending("category_id", value: "\(categoryId)")
        return CoreNetwork.request(method: .GET(url: url))
    }

}


// MARK: - VERIFICATION STRUCT
struct VerificationResponse: Codable {
    let message: String
    let meta: Meta?
    let data: VerificationCode?
    let errors: [ErrorData?]
    let errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

struct VerificationCode: Codable {
    let code: String?
}


// MARK: SIGN UP RESPONSE
struct SignUpResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: SignUpData?

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

struct SignUpData: Codable {
    let accessToken: String?
    let user: Profile?
}


// MARK: CATEGORIES RESPONSE
//struct CategoriesResponse: Codable {
////    let message: String
////    let meta: Meta?
//    let errors: [ErrorData?]
////    let errorDescription: String?
//    let category: [Category?]
//
////    enum CodingKeys: String, CodingKey {
////        case message, meta, errors
////        case errorDescription = "description"
////        case data
////    }
//}
struct Category: Codable, Hashable {
    let id: Int?
    let name: String?
}
