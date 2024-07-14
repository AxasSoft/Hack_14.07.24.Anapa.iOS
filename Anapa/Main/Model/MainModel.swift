//
//  MainModel.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.06.2023.
//

import Foundation
import PromiseKit

struct MainModel {
    //MARK: get subscribtions
    static func fetchSubscriptions() -> Promise<SubscriptionsResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/subscriptions/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK: get subscribtions
    static func fetchSubscribers() -> Promise<SubscriptionsResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/users/me/subscribers/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    static func fetchInfoDigest() -> Promise<InfoResposne>{
        var url = Constants.baseURL.appendingPathComponent("/api/v1/infos/digest/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    static func getWeather() -> Promise<WeatherResponse> {
        var url = URL(string: "http://api.weatherapi.com/v1/current.json?key=517c84005e2c4552a7164414232809&q=Anapa&aqi=no&lang=ru")
        return CoreNetwork.request(method: .GET(url: url!))
    }
}

// MARK: SUBSCRIPTIONS
struct SubscriptionsResponse: Codable {
    let message: String?
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: [Profile?]

    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}


// MARK: WEATHER
struct WeatherResponse: Codable {
//    let location: WeatherLocation?
    let current: CurrentWeather?
}

// MARK: - Current
struct CurrentWeather: Codable {
//    let lastUpdatedEpoch: Int?
//    let lastUpdated: String?
    let tempC: Double?
//    let tempF: Double?
//    let isDay: Int?
    let condition: Condition?
//    let windMph, windKph: Double?
//    let windDegree: Int?
//    let windDir: String?
//    let pressureMb: Int?
//    let pressureIn: Double?
//    let precipMm, precipIn, humidity, cloud: Int?
//    let feelslikeC: Int?
//    let feelslikeF: Double?
//    let visKM, visMiles, uv: Int?
//    let gustMph, gustKph: Double?
}

// MARK: - Condition
struct Condition: Codable {
    let text, icon: String?
    let code: Int?
}

// MARK: - Location
struct WeatherLocation: Codable {
    let name, region, country: String?
    let lat, lon: Double?
    let tzId: String?
    let localtimeEpoch: Int?
    let localtime: String?
}
