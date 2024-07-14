//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//


import Foundation
import KeychainAccess

struct Constants {
//    static let baseURL: URL = URL(string: "http://91.210.168.92:99")! // test
//    static let urlString: String = "http://91.210.168.92:99" // test
    static let baseURL: URL = URL(string: "http://api.krasnodar.axas.ru")!
    static let urlString: String = "http://api.krasnodar.axas.ru"
    static let keychain = Keychain(service: "ru.axas.Anapa")
    static let gender = ["", "Мужской", "Женский"]
    
    
    static let complaints: [Int: String] = [0 :"Спам",
                                            1 :"Изображения обнаженного тела или действий сексуального характера",
                                            2 :"Враждебные высказывания или символы Враждебные высказывания или символы",
                                            3 :"Насилие или опасные организации",
                                            4 :"Травля или преследования",
                                            5 :"Продажа незаконных товаров или товаров, подлежащих правовому регулированию",
                                            6 :"Нарушение прав на интеллектуальную собственность",
                                            7 :"Самоубийство или нанесение себе увечий",
                                            8 :"Расстройство пищевого поведения",
                                            9 :"Мошенничество или обман",
                                            10:"Ложная информация"]
    static let orderType: [Int: String] = [0 :"Услуги очно",
                                           1 :"Услуги круглосуточно",
                                           2 :"Услуги дистанционно",
                                           3 :"Услуги срочно"]
    static let orderStage: [Int: String] = [0 :"Активно",
                                            1 :"Активно",
                                            2 :"Активно",
                                            3 :"Завершено",
                                            4 :"Отменено"]
    
    struct InfoCategory: Codable {
        let id: Int
        let name: String
    }

    static let yandexAppMetricaKey = "99e318c0-0173-4d9e-86a2-cfce9062267d"
    
    static let infoCategory: [InfoCategory] = [InfoCategory(id: 0, name: "Город"),
                                                InfoCategory(id: 1, name: "Интересное"),
                                                InfoCategory(id: 2, name: "Бизнес"),
                                                InfoCategory(id: 3, name: "Медиа"),
                                                InfoCategory(id: 4, name: "Спорт"),
                                                InfoCategory(id: 5, name: "Политика"),
                                                InfoCategory(id: 6, name: "Культура"),
                                                InfoCategory(id: 7, name: "Общество"),
                                                InfoCategory(id: 8, name: "Недвижимость"),
                                                InfoCategory(id: 9, name: "Технологии"),
                                                InfoCategory(id: 10, name: "Наука"),
                                                InfoCategory(id: 11, name: "Авто"),
                                                InfoCategory(id: 12, name: "Проишествия")]
    
    enum coordinateSelector: Int {
        case registration = 0
        case editProfile = 1
        case order = 2
        case event = 3
    }
    
    enum LocationType {
        case currentСoordinates
        case orderCoordinates
    }
}


//MARK: ORDER STATUS
//created = 0 # Заказ создан. Выбираем отклики
//selected = 1 # Выбрали отклик-победитель
//finished = 2 # Работа с откликом завершена. Ожидаем подтверждения
//confirmed = 3 # Работа с откликом подтверждена
//rejected = 4 # Заказ отклонён
