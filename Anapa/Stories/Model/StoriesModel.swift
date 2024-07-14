//
//  StoriesModel.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 19.04.2022.
//

import Foundation
import PromiseKit
import Photos

struct StoriesModel {
    
    //MARK: get stories
    static func fetchStories(hashtagId: Int?, page: Int?,  userId: Int?, search: String?, isFavorite: Bool?, isSubscriptions: Bool?) -> Promise<StoriesResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/stories/")
        
        if isSubscriptions == true {
            url = url.appendingPathComponent("subscriptions/")
        }
        
        if hashtagId != nil {
            url = url.appending("hashtag_id", value: "\(hashtagId!)")
        }
        if page != nil {
            url = url.appending("page", value: "\(page!)")
        }
        if userId != nil {
            url = url.appending("user_id", value: "\(userId!)")
        }
        if search != nil {
            url = url.appending("search", value: "\(search!)")
        }
        if isFavorite != nil {
            url = url.appending("is_favorite", value: "\(isFavorite!)")
        }
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    
    //MARK: get user stories
    static func fetchUserStories(userId: Int, page: Int) -> Promise<StoriesResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/users/\(userId)/stories/")
        url = url.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    
    //MARK: create story
    static func createStory(hashtags: [String?], text: String?, video: Int?, gallery: [Int?], isPrivate: Bool) -> Promise<OneStoryResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var param: [String: Encodable] = [:]
        param["hashtags"] = hashtags
        param["text"] = text
        param["video"] = video
        param["gallery"] = gallery
        param["is_private"] = isPrivate
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    
    //MARK: edit story
    static func editStory(storyId: Int, hashtags: [String?], text: String?, video: Int?, gallery: [Int?], topic: Int?, isPrivate: Bool) -> Promise<OneStoryResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var param: [String: Encodable] = [:]
        param["hashtags"] = hashtags
        param["text"] = text
        param["video"] = video
        param["gallery"] = gallery
        param["topic"] = topic
        param["is_private"] = isPrivate
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/")
        return CoreNetwork.request(method: .PUT(url: url, body: data!))
    }
    
    //MARK: delete story
    static func deleteStory(storyId: Int) -> Promise<StatusResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/")
        return CoreNetwork.request(method: .DELETE(url: url))
    }
    
    //MARK: add story media
    static func addStoryMedia(attachment: Data, type: MediaAttchmentType) -> Promise<StoryAttachmentResponse>{
                                    
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/v1/stories/attachments/")
        let media = NetCoreMedia(with: attachment, forKey: "attachment", mediaType: type)
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }
    
    //MARK: hug story
    static func hugStory(storyId: Int, hugs: Bool) -> Promise<OneStoryResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "hugs": hugs
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/hugged/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    //MARK: афмщкшеу story
    static func favoriteStory(storyId: Int, favorite: Bool) -> Promise<OneStoryResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "is_favorite": favorite
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/is-favorite/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    //MARK: view story
    static func viewStory(storyId: Int) -> Promise<OneStoryResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/viewed/")
        return CoreNetwork.request(method: .POST(url: url, body: nil))
    }
    
    //MARK: hide story
    static func hideStory(storyId: Int) -> Promise<OneStoryResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "hiding": true
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/is-hidden/")
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }
    
    //MARK: complaint story
    static func complaintStory(storyId: Int, complaint: Int, comment: String) -> Promise<OneStoryResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "reason": complaint,
            "additional_text": comment
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/reports/")
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }
    
    //MARK: get all comments
    static func fetchStoryComments(storyId: Int, page: Int) -> Promise<CommentsResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/comments/")
        url = url.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK: add comment
    static func addComment(storyId: Int, text: String) -> Promise<CommentResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "text": text
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/v1/stories/\(storyId)/comments/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    //MARK: delete comment
    static func deleteComment(commentId: Int) -> Promise<StatusResponse>{
        let url = Constants.baseURL.appendingPathComponent("/api/v1/comments/\(commentId)/")
        return CoreNetwork.request(method: .DELETE(url: url))
    }
    
    
}


// MARK: STORY RESPONSE
struct StoriesResponse: Codable {
    let message: String?
    let meta: MetaPage?
    let errors: [ErrorData?]
    let errorDescription: String?
    var data: [Story?]
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

// MARK: STORY RESPONSE
struct OneStoryResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    var data: Story?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

// MARK: STORY
struct Story: Codable, Hashable {
//    static func == (lhs: Story, rhs: Story) -> Bool {
//        <#code#>
//    }
    
//    static func == (lhs: Story, rhs: Story) -> Bool {
//        return true
//    }
    
    let id, created: Int?
    let user: Profile?
    let text: String?
    let video: StoryMedia?
    let gallery: [StoryMedia?]
    let isPrivate: Bool?
    let hashtags: [Hashtag?]
    let viewsCount: Int?
    let viewed: Bool?
    var hugsCount: Int?
    var hugged: Bool?
    var isFavorite: Bool?
    let commentsCount: Int?
    var fullText: Bool?
}


// MARK: STORY GALLERY
struct StoryMedia: Codable, Hashable {
    let id: Int?
    let mainLink: String?
    let coverLink: String?
    let isImage: Bool?
    let created: Int?
}

// MARK: HASHTAG
struct Hashtag: Codable, Hashable {
    let text: String?
    let id: Int?
    let storiesCount: Int?
    let cover: String?
}



// MARK: STORY ATTACHMENT
struct StoryAttachmentResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: Attachment?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

// MARK: ATTACHMENT
struct Attachment: Codable {
    let id: Int?
    let mainLink: String?
    let coverLink: String?
    let isImage: Bool?
    let created: Int?
}


//MARK: COMMENT RESPONSE
struct CommentsResponse: Codable {
    let message: String?
    let meta: MetaPage?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: [Comment?]

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

//MARK: COMMENT RESPONSE
struct CommentResponse: Codable {
    let message: String?
    let meta: MetaPage?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: Comment?

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

struct Comment: Codable {
    let id: Int?
    let text: String?
    let created: Int?
    let user: Profile?
}
