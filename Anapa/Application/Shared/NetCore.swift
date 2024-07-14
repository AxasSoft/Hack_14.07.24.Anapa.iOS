//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import Foundation
import PromiseKit
import PromiseKit.PMKFoundation
import UIKit

enum HTTPMethodConfiguration: URLRequestConvertible {
    case GET(url: URL)
    case PUT(url: URL, body: Data?, additionalHeadersIfNeeded: [String: String]? = nil)
    case POST(url: URL, body: Data?, additionalHeadersIfNeeded: [String: String]? = nil)
    case PATCH(url: URL, body: Data?, additionalHeadersIfNeeded: [String: String]? = nil)
    case DELETE(url: URL, additionalHeadersIfNeeded: [String: String]? = nil)
    
    case MultipartPOST(configuration: MultipartRequestConfiguration)
    case MultipartPUT(configuration: MultipartRequestConfiguration)
    
    var method: String {
        switch self {
        case .GET:             return "GET"
        case .POST:            return "POST"
        case .MultipartPOST:       return "POST"
        case .MultipartPUT:       return "PUT"
        case .PATCH:           return "PATCH"
        case .PUT:             return "PUT"
        case .DELETE:          return "DELETE"
        }
    }
    
    var body: Data? {
        switch self {
        case .PATCH(_, let data, _):               return data
        case .POST(_, let data, _):                return data
        case .PUT(_, let data, _):                 return data
        case .DELETE(_,  _):                 return nil
        case .MultipartPOST(let configuration):     return configuration.dataBody
        case .MultipartPUT(let configuration):     return configuration.dataBody
        default:                                return nil
        }
    }
    
    var url: URL {
        switch self {
        case .GET(let url):                     return url
        case .POST(let url, _, _):              return url
        case .PATCH(let url, _, _):             return url
        case .PUT(let url, _, _):               return url
        case .DELETE(let url, _):                  return url
        case .MultipartPOST(let configuration):     return configuration.url
        case .MultipartPUT(let configuration):     return configuration.url
        }
    }
    
    var additionalHeadersIfExist: [String: String]? {
        switch self {
        case .POST(_, _, let additionalHeadersIfNeeded): return additionalHeadersIfNeeded
        case .PUT(_, _, let additionalHeadersIfNeeded): return additionalHeadersIfNeeded
        case .PATCH(_, _, let additionalHeadersIfNeeded): return additionalHeadersIfNeeded
        case .DELETE(_, let additionalHeadersIfNeeded): return additionalHeadersIfNeeded
        default: return nil
        }
    }
    
    var pmkRequest: URLRequest {
        
        var urlRequest: URLRequest = URLRequest(url: self.url)
        
        if case let .MultipartPOST(configuration) = self {
            
            urlRequest.timeoutInterval = TimeInterval.infinity
            
            urlRequest.allHTTPHeaderFields = [
                "X-User-Agent": "ios",
                "Accept-Language": "en",
                "Accept": "application/json",
                "Content-Type": "multipart/form-data; boundary=\(configuration.boundary)"
            ]
            
        } else if case let .MultipartPUT(configuration) = self {
            
            urlRequest.timeoutInterval = TimeInterval.infinity
            
            urlRequest.allHTTPHeaderFields = [
                "X-User-Agent": "ios",
                "Accept-Language": "en",
                "Accept": "application/json",
                "Content-Type": "multipart/form-data; boundary=\(configuration.boundary)"
            ]
            
        } else {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let additionalHeaders = self.additionalHeadersIfExist {
            for (headerKey, headerValue) in additionalHeaders {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        if let accessToken = Constants.keychain["accessToken"] {
            urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        if UserDefaults.standard.value(forKey: "firebaseToken") as! String != "" {
            urlRequest.addValue("\(UserDefaults.standard.value(forKey: "firebaseToken") ?? "")", forHTTPHeaderField: "x-firebase-token")
        }
        
        urlRequest.httpMethod = self.method
        urlRequest.httpBody = self.body
        return urlRequest
    }
    
    mutating func updateBody(with data: Data) {
        switch self {
        case .PUT(let url, _, let additionalHeaders):
            self = .PUT(url: url, body: data, additionalHeadersIfNeeded: additionalHeaders)
        case .PATCH(let url, _, let additionalHeaders):
            self = .PATCH(url: url, body: data, additionalHeadersIfNeeded: additionalHeaders)
        case .POST(let url, _, let additionalHeaders):
            self = .POST(url: url, body: data, additionalHeadersIfNeeded: additionalHeaders)
        case .DELETE(let url, let additionalHeaders):
            self = .DELETE(url: url, additionalHeadersIfNeeded: additionalHeaders)
        default:
            return
        }
    }
    
    mutating func appending(queryItem: String, value: String?) {
        switch self {
        case .GET(let url):
            self = .GET(url: url.appending(queryItem, value: value))
        case .PUT(let url, let body, let additionalHeaders):
            self = .PUT(url: url.appending(queryItem, value: value), body: body, additionalHeadersIfNeeded: additionalHeaders)
        case .PATCH(let url, let body, let additionalHeaders):
            self = .PATCH(url: url.appending(queryItem, value: value), body: body, additionalHeadersIfNeeded: additionalHeaders)
        case .POST(let url, let body, let additionalHeaders):
            self = .POST(url: url.appending(queryItem, value: value), body: body, additionalHeadersIfNeeded: additionalHeaders)
        case .DELETE(let url, let additionalHeaders):
            self = .DELETE(url: url.appending(queryItem, value: value), additionalHeadersIfNeeded: additionalHeaders)
        case .MultipartPOST(var configuration):
            configuration.modify(
                url: configuration.url.appending(queryItem, value: value)
            )
            self = .MultipartPOST(configuration: configuration)
        case .MultipartPUT(var configuration):
            configuration.modify(
                url: configuration.url.appending(queryItem, value: value)
            )
            self = .MultipartPUT(configuration: configuration)
        }
    }
    
    mutating func append(pathComponent: String) {
        switch self {
        case .GET(let url):
            self = .GET(url: url.appendingPathComponent(pathComponent))
        case .PUT(let url, let body, let additionalHeaders):
            self = .PUT(url: url.appendingPathComponent(pathComponent), body: body, additionalHeadersIfNeeded: additionalHeaders)
        case .PATCH(let url, let body, let additionalHeaders):
            self = .PATCH(url: url.appendingPathComponent(pathComponent), body: body, additionalHeadersIfNeeded: additionalHeaders)
        case .POST(let url, let body, let additionalHeaders):
            self = .POST(url: url.appendingPathComponent(pathComponent), body: body, additionalHeadersIfNeeded: additionalHeaders)
        case .DELETE(let url, let additionalHeaders):
            self = .DELETE(url: url.appendingPathComponent(pathComponent), additionalHeadersIfNeeded: additionalHeaders)
        case .MultipartPOST(var configuration):
            configuration.modify(
                url: url.appendingPathComponent(pathComponent)
            )
            self = .MultipartPOST(configuration: configuration)
        case .MultipartPUT(var configuration):
            configuration.modify(
                url: url.appendingPathComponent(pathComponent)
            )
            self = .MultipartPUT(configuration: configuration)
        }
    }
}

enum RequestError: Error {
    case requestCooldown
    case emptyDataError
    case decodeError
    case parseError
    case authenticationError
    case serverError(statusCode: Int)
    case networkError
    
    var message: String {
        switch self {
        case .networkError: return "не удается получить доступ к серверу. Проверьте подключение и повторите попытку."
        case .serverError: return "Проверьте введенные данные и повторите попытку"
        default: return "Error"
        }
    }
    
    var title: String {
        switch self {
        case .networkError: return "Ошибка"
        case .serverError: return "Ошибка"
        default: return "Error"
        }
    }
}

struct NoResponseRequest: Decodable {
    
    private init() {}
    
    static let instance: NoResponseRequest = NoResponseRequest()
}

class CoreNetwork {
    
    static let jsonDecoder: JSONDecoder = {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
            let integerValue = try container.decode(Int.self)
            return Date(
                timeIntervalSince1970: TimeInterval(integerValue)
            )
        }
        return decoder
    }()
    
    static let cache: NSCache = NSCache<NSString, NSData>()
    
    static func request<Response: Decodable>(method: HTTPMethodConfiguration, isCachingEnabled: Bool = false) -> Promise<Response> {
        
        if isCachingEnabled, let data: NSData = cache.object(forKey: method.url.absoluteString as NSString) {
            if Response.self is Data.Type, let data = data as? Response {
                return Promise.value(data)
            }
            let localData: Data = Data(referencing: data)
            return Promise<Response> { resolver in
                resolver.resolve(try jsonDecoder.decode(Response.self, from: localData), nil)
            }
        }
        
        return firstly {
            URLSession.shared.dataTask(.promise, with: method)
        }.get { data, response in
            
            if isCachingEnabled, case let response as HTTPURLResponse = response, (200...308) ~= response.statusCode {
                cache.setObject(data as NSData, forKey: method.url.absoluteString as NSString)
            } else if isCachingEnabled, case let response as HTTPURLResponse = response, (401...499) ~= response.statusCode {
//                cache.setObject(data as NSData, forKey: method.url.absoluteString as NSString)
            }
            
        }.compactMap { data, response in
            
            
            if let noResponseRequest = NoResponseRequest.instance as? Response {
                return noResponseRequest
            }
            if Response.self is Data.Type, let data = data as? Response {
                return data
            }
            return try self.jsonDecoder.decode(Response.self, from: data)
        }
    }
}



//MARK: MULTIPART
typealias `NetCoreMedia` = MultipartRequestConfiguration.NetCoreMedia

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

enum MediaAttchmentType {
    case video
    case image
}

struct MultipartRequestConfiguration {
    
    private var urlProperty: URL
    private let mediaProperties: [NetCoreMedia]
    private let parameterProperties: [String: String]
    private let boundaryProperty: String = "Boundary-\(UUID().uuidString)"
    
    struct NetCoreMedia {
        let key: String
        let fileName: String
        let data: Data
        let mimeType: String
        
        init(with imageData: Data, forKey key: String, mediaType: MediaAttchmentType) {
            //type - "image/png" |
            if mediaType == .image {
                self.mimeType = "image/png"
                self.fileName = "\(arc4random()).png"
            } else {
                self.mimeType = "video/mp4"
                self.fileName = "\(arc4random()).mp4"
            }
            self.key = key
            self.data = imageData
        }
    }
    
    init(url: URL, media: [NetCoreMedia], parameters: [String: String]) {
        self.urlProperty = url
        self.mediaProperties = media
        self.parameterProperties = parameters
    }
    
    mutating func modify(url: URL) {
        self.urlProperty = url
    }
    
    var url: URL {
        return urlProperty
    }
    
    var boundary: String {
        return boundaryProperty
    }
    
    var dataBody: Data {
        
        let lineBreak: String = "\r\n"
        
        var body: Data = Data()
        
        for (key, value) in parameterProperties {
            body.append("--\(boundaryProperty + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
            body.append("\(value + lineBreak)")
        }
        
        for photo in mediaProperties {
            body.append("--\(boundaryProperty + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
            body.append(photo.data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundaryProperty)--\(lineBreak)")
        
        return body
    }
}

extension URL {
    
    func appending(_ queryItem: String, value: String?) -> URL {
        
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        
        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // Append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems
        
        // Returns the url from new url components
        return urlComponents.url!
    }
}


struct NetCoreStruct {
    
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }
}


struct AxasAPI <T: Codable>: Codable {
    let message: String?
    let meta: Meta?
    let description: String?
    let data: T?
}

extension UIViewController {
    //universal func for network request
        func makeRequest<T>(with: (Promise<AxasAPI<T>>), completion: @escaping (AxasAPI<T>?) -> Void) {
            firstly {
                with
            }.done { [weak self] data in
                if data.message?.lowercased() == "ok" {
                    completion(data)
                } else {
                    self?.view.makeToast(data.description)
                    completion(nil)
                }
            }.catch { [weak self] error in
                self?.view.makeToast("Что-то пошло не так")
                completion(nil)
                print(error.localizedDescription)
            }
        }
}

