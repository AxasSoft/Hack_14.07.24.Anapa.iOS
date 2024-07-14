//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import Foundation
import UIKit

extension UIViewController{
    func updateProfileData(profile: Profile){
        
        UserDefaults.standard.set(profile.id, forKey: "id")
        UserDefaults.standard.set(profile.email, forKey: "email")
        UserDefaults.standard.set(profile.tel, forKey: "tel")
        UserDefaults.standard.set(profile.firstName, forKey: "firstName")
        UserDefaults.standard.set(profile.lastName, forKey: "lastName")
        UserDefaults.standard.set(profile.patronymic, forKey: "patronymic")
        UserDefaults.standard.set(profile.birthtime, forKey: "birthtime")
        UserDefaults.standard.set(profile.gender, forKey: "gender")
        UserDefaults.standard.set(profile.avatar, forKey: "avatar")
        UserDefaults.standard.set(profile.location, forKey: "location")
        UserDefaults.standard.set(profile.rating, forKey: "rating")
        UserDefaults.standard.set(profile.categoryId, forKey: "categoryId")
        UserDefaults.standard.set(try? PropertyListEncoder().encode(profile.category), forKey: "category")
        UserDefaults.standard.set(profile.lastVisited, forKey: "lastVisited")
        UserDefaults.standard.set(profile.lastVisitedHuman, forKey: "lastVisitedHuman")
        UserDefaults.standard.set(profile.isActive, forKey: "isActive")
        UserDefaults.standard.set(profile.isSuperuser, forKey: "isSuperuser")
        
        UserDefaults.standard.set(profile.storiesCount, forKey: "storiesCount")
        UserDefaults.standard.set(profile.hugsCount, forKey: "hugsCount")
        UserDefaults.standard.set(profile.isOnline, forKey: "isOnline")
        UserDefaults.standard.set(profile.iBlock, forKey: "iBlock")
        UserDefaults.standard.set(profile.blockMe, forKey: "blockMe")
        
        UserDefaults.standard.set(profile.createdOrdersCount, forKey: "createdOrdersCount")
        UserDefaults.standard.set(profile.completedOrdersCount, forKey: "completedOrdersCount")
        UserDefaults.standard.set(profile.myOffersCount, forKey: "myOffersCount")
        
        UserDefaults.standard.set(profile.tg, forKey: "tg")
        
        UserDefaults.standard.set(profile.isServicer, forKey: "isServicer")
        UserDefaults.standard.set(profile.showTel, forKey: "showTel")
        UserDefaults.standard.set(profile.inBlacklist, forKey: "inBlacklist")
        UserDefaults.standard.set(profile.inWhitelist, forKey: "inWhitelist")
        UserDefaults.standard.set(profile.isBusiness, forKey: "isBusiness")
        UserDefaults.standard.set(profile.companyInfo, forKey: "companyInfo")
        UserDefaults.standard.set(profile.site, forKey: "site")
        UserDefaults.standard.set(profile.experience, forKey: "experience")
        UserDefaults.standard.set(profile.lat, forKey: "latitude")
        UserDefaults.standard.set(profile.lon, forKey: "longitude")
        UserDefaults.standard.set(profile.status, forKey: "status")
        UserDefaults.standard.set(profile.subscribersCount, forKey: "subscribersCount")
        UserDefaults.standard.set(profile.subscriptionsCount, forKey: "subscriptionsCount")
        UserDefaults.standard.set(profile.profileCover, forKey: "profileCover")
        UserDefaults.standard.set(profile.isDatingProfile, forKey: "isDatingProfile")
        UserDefaults.standard.set(profile.datingProfileId, forKey: "datingProfileId")
    }
    
    func getProfile() -> Profile!{
        var category: Category?
        if let data = UserDefaults.standard.value(forKey:"category") as? Data {
            if data.count > 0 {
                category = try! PropertyListDecoder().decode(Category.self, from: data)
            }
        }
        
        return Profile(id: UserDefaults.standard.integer(forKey: "id"),
                       email: UserDefaults.standard.string(forKey: "email"),
                       tel: UserDefaults.standard.string(forKey: "tel"),
                       isActive: UserDefaults.standard.bool(forKey: "isActive"),
                       isSuperuser: UserDefaults.standard.bool(forKey: "isSuperuser"),
                       firstName: UserDefaults.standard.string(forKey: "firstName"),
                       lastName: UserDefaults.standard.string(forKey: "lastName"),
                       patronymic: UserDefaults.standard.string(forKey: "patronymic"),
                       birthtime: UserDefaults.standard.integer(forKey: "birthtime"),
                       avatar: UserDefaults.standard.string(forKey: "avatar"),
                       gender: UserDefaults.standard.integer(forKey: "gender"),
                       location: UserDefaults.standard.string(forKey: "location"),
                       rating: UserDefaults.standard.float(forKey: "rating"),
                       categoryId: UserDefaults.standard.integer(forKey: "categoryId"),
                       category: category,
                       storiesCount: UserDefaults.standard.integer(forKey: "storiesCount"),
                       hugsCount: UserDefaults.standard.integer(forKey: "hugsCount"),
                       lastVisited: UserDefaults.standard.integer(forKey: "lastVisited"),
                       lastVisitedHuman: UserDefaults.standard.string(forKey: "lastVisitedHuman"),
                       isOnline: UserDefaults.standard.bool(forKey: "isOnline"),
                       iBlock: UserDefaults.standard.bool(forKey: "iBlock"),
                       blockMe: UserDefaults.standard.bool(forKey: "blockMe"),
                       createdOrdersCount: UserDefaults.standard.integer(forKey: "createdOrdersCount"),
                       completedOrdersCount: UserDefaults.standard.integer(forKey: "completedOrdersCount"),
                       myOffersCount: UserDefaults.standard.integer(forKey: "myOffersCount"),
                       tg: UserDefaults.standard.string(forKey: "tg"),
                       isServicer: UserDefaults.standard.bool(forKey: "isServicer"),
                       showTel: UserDefaults.standard.bool(forKey: "showTel"),
                       inBlacklist: UserDefaults.standard.bool(forKey: "inBlacklist"),
                       inWhitelist: UserDefaults.standard.bool(forKey: "inWhitelist"),
                       isBusiness: UserDefaults.standard.bool(forKey: "isBusiness"),
                       companyInfo: UserDefaults.standard.string(forKey: "companyInfo"),
                       site: UserDefaults.standard.string(forKey: "site"),
                       experience: UserDefaults.standard.string(forKey: "experience"),
                       inSubscriptions: false,
                       lat: UserDefaults.standard.double(forKey: "latitude"),
                       lon: UserDefaults.standard.double(forKey: "longitude"),
                       subscribersCount: UserDefaults.standard.integer(forKey: "subscribersCount"),
                       subscriptionsCount: UserDefaults.standard.integer(forKey: "subscriptionsCount"),
                       status: UserDefaults.standard.string(forKey: "status"),
                       profileCover: UserDefaults.standard.string(forKey: "profileCover"),
                       isDatingProfile: UserDefaults.standard.bool(forKey: "isDatingProfile"),
                       datingProfileId: UserDefaults.standard.integer(forKey: "datingProfileId")
        )
    }
}
