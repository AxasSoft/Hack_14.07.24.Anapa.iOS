//
//  ProfileModel.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import Foundation
import PromiseKit

struct ProfileModel {
    
    //MARK:  edit profile
    static func editProfile(firstName: String, lastName: String, patronymic: String, email: String?,tg: String?, isServicer: Bool, gender: Int, birthtime: Int, location: String, serviceCategory: Int?, showTel: Bool, isBusiness: Bool, companyInfo: String?, site: String?, experience: String?, lat: Double?, lon: Double?) -> Promise<ProfileResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var param: [String: Encodable] = [
            "first_name": firstName,
            "patronymic": patronymic,
            "last_name": lastName,
            "email": email,
            "tg": tg,
            "is_servicer": isServicer,
            "birthtime": birthtime,
            "gender": gender,
            "location": location,
            "show_tel": showTel,
            "is_business": isBusiness,
            "company_info": companyInfo,
            "site": site,
            "experience": experience,
            "lat": lat,
            "lon": lon]

        if serviceCategory != nil {
            param["category_id"] = serviceCategory
        }

        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .PUT(url: url, body: data!))
    }
    
    //MARK: change status
    static func changeStatus(status: String) -> Promise<ProfileResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var param: [String: Encodable] = [
            "status": status]

        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .PUT(url: url, body: data!))
    }
    
    

    //MARK:  get profile
    static func fetchProfile() -> Promise<ProfileResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK:  add photo
    static func changeAvatar(image: Data) -> Promise<ProfileResponse>{
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/v1/users/me/avatar/")
        let media = NetCoreMedia(with: image, forKey: "new_avatar", mediaType: .image)
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }
    
    
    //MARK:  add photo
    static func changeCover(image: Data) -> Promise<ProfileResponse>{
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/v1/users/me/profile-cover/")
        let media = NetCoreMedia(with: image, forKey: "new_profile_cover", mediaType: .image)
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }
    
    
    //MARK: fetch user info
    static func fetchUser(userId: Int) -> Promise<UserResponse> {
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    
    //MARK: complaint user
    static func complaintUser(userId: Int, complaint: Int, comment: String) -> Promise<StatusResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "reason": complaint,
            "additional_text": comment
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/reports/")
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }

    //MARK: block user
    static func blockUser(userId: Int, isBlock: Bool) -> Promise<StatusResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "block": isBlock
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/block/")
        return CoreNetwork.request(method: .PUT(url: url, body: data))
    }
    

    
    //MARK: delete profile
    static func deleteProfile() -> Promise<StatusResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/")
        return CoreNetwork.request(method: .DELETE(url: url))
    }
    
    
    //MARK: get notification
    static func fetchNotification() -> Promise<NotificationListResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/notifications/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK: read notification
    static func readNotification(notificationId: Int) -> Promise<NotificationListResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/notifications/\(notificationId)/is-read/")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = ["is_read": true]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        return CoreNetwork.request(method: .PUT(url: url, body: data))
    }
    
    
    //MARK: about author
    static func fetchServiceInfo(slug: String) -> Promise<ServiceInfoResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/service-infos/\(slug)/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    
    //MARK: get feedbacks
    static func fetchFeedbacks(userId: Int) -> Promise<FeedbacksListResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/feedbacks/")
        url = url.appending("about_user_id", value: "\(userId)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK: add feedback
    static func addFeedback(offerId: Int, rating: Int, text: String) -> Promise<OneFeedbackResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "text": text,
            "rate": rating
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/offers/\(offerId)/feedbacks/")
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }
    
    
    
    //MARK: subscribe user
    static func changeSubscribeUser(userId: Int, subscribe: Bool) -> Promise<UserResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "subscribe": subscribe
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/in_subscriptions/")
        return CoreNetwork.request(method: .PUT(url: url, body: data))
    }
    
    
    
    //MARK: search user
    static func searchUser(search: String?, page: Int?, isBusiness: Bool?, distance: Int?, lat: Double?, lon: Double?, categoryIds: [Int?]) -> Promise<SearchResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/users/")
        if search != nil && search != "" {
            url = url.appending("search", value: "\(search!)")
        }
        if page != nil {
            url = url.appending("page", value: "\(page ?? 0)")
        }
        if isBusiness != nil {
            url = url.appending("is_business", value: "\(isBusiness ?? false)")
        }
        if distance != nil {
            url = url.appending("distance", value: "\(distance ?? 0)")
        }
        
        if lat != nil {
            url = url.appending("current_lat", value: "\(lat ?? 0)")
        }
        
        if lon != nil {
            url = url.appending("current_lon", value: "\(lon ?? 0)")
        }
        if categoryIds.count > 0 {
            for category in categoryIds {
                url = url.appending("category_ids", value: "\(category ?? 0)")
            }
        }
        

        
        if (UserDefaults.standard.value(forKey: "searchFilterCategoryId") as? Int) != nil && (UserDefaults.standard.value(forKey: "searchFilterCategoryId") as? Int) != 0 {
            url = url.appending("category_id", value: "\(UserDefaults.standard.integer(forKey: "searchFilterCategoryId"))")
        }
        
        if (UserDefaults.standard.value(forKey: "searchFilterLocation") as? Int) != nil && (UserDefaults.standard.value(forKey: "searchFilterLocation") as? Int) != 0 {
            url = url.appending("location", value: "\(UserDefaults.standard.integer(forKey: "searchFilterLocation"))")
        }
        
        if (UserDefaults.standard.value(forKey: "searchFilterRaiting") as? Int) != nil && (UserDefaults.standard.value(forKey: "searchFilterRaiting") as? Int) != 0 {
            url = url.appending("rating_from", value: "\(UserDefaults.standard.integer(forKey: "searchFilterRaiting") + 1)")
        }
        
        return CoreNetwork.request(method: .GET(url: url))
    }
}



// MARK: PROFILE
struct ProfileResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: Profile?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

    
struct Profile: Codable, Hashable {
    var id: Int
    let email, tel: String?
    let isActive, isSuperuser: Bool?
    let firstName, lastName, patronymic: String?
    let birthtime: Int?
    let avatar: String?
    let gender: Int?
    let location: String?
    let rating: Float?
    let categoryId: Int?
    let category: Category?
    let storiesCount, hugsCount: Int?
    let lastVisited: Int?
    let lastVisitedHuman: String?
    let isOnline, iBlock, blockMe: Bool?
    let createdOrdersCount, completedOrdersCount, myOffersCount: Int?
    let tg: String?
    let isServicer, showTel, inBlacklist, inWhitelist, isBusiness: Bool?
    let companyInfo, site, experience: String?
    var inSubscriptions: Bool?
    let lat: Double?
    let lon: Double?
    let subscribersCount: Int?
    let subscriptionsCount: Int?
    var status: String?
    let profileCover: String?
    let isDatingProfile: Bool?
    let datingProfileId: Int?
}


// MARK: SEARCH USER
struct SearchResponse: Codable {
    let message: String?
    let meta: MetaPage?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: [Profile?]

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}


// MARK: USER
struct UserResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: Profile?

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}


//MARK: NOTIFICATION
struct NotificationListResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: [NotificationInfo?]
}

struct OneNotificationResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: NotificationInfo?
}

struct NotificationInfo: Codable {
    let id: Int?
    let title, body, icon: String?
    let created, orderId, offerId, stage: Int?
    let isRead, hasFeedbackAboutMe: Bool
    let user: Profile
    let secondUser: Profile?
    let orderName: String?
}


//MARK: SERVICE INFO RESPONSE
struct ServiceInfoResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: ServiceInfo?
}

struct ServiceInfo: Codable {
    let id: Int?
    let title, body: String?
    let created, updated: Int?
    let link: String?
    let image: String?
}


// MARK: FEEDBACKS
struct FeedbacksListResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: [Feedback?]
}

struct OneFeedbackResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: Feedback?
}

struct Feedback: Codable {
    let id, created: Int?
    let text: String?
    let rate: Int?
    let user: Profile?
}
