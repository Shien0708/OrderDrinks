//
//  Menu.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/10.
//

import Foundation
import UIKit

var currentURL: URL?
var drinkTypeIndex = 0
var touchedButtonIndex = 0
var totalCustomers = 0
var menuIndices = (0, 0)
let iceNames = ["熱", "常溫", "去冰", "少冰", "正常冰"]
let sugarNames = ["無糖", "微糖", "半糖", "少糖", "正常甜"]
let sizeNames = ["中杯", "大杯"]
let typeNames = ["經典原茶", "香醇奶茶", "炙夏冰沙", "純鮮奶茶", "新鮮果茶"]
let topDrinksIndices = [(0, 4), (3, 8), (4, 4), (0, 7), (3 ,1), (4, 8), (0, 3), (2, 3)]

enum MenuInfo: String {
    case best = "Best Sellers"
    case cold = "Cold Drinks Only"
    case hot = "Hot Drinks Only"
    case limited = "Limited Edition"
}

struct Menu: Codable {
    var records: [MenuRecord]
}

struct MenuRecord: Codable {
    var id: String
    var fields: MenuFields
}

struct MenuFields: Codable {
    var name: String
    var english_name: String
    var image: [MenuImage]
    var medium_price: Int
    var large_price: Int?
    var info: [String]?
}

struct MenuImage: Codable {
    var url: URL
}

func fetchImage(url: URL?, completion: @escaping(UIImage?)->Void){
    if let url = url {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}



let topDrinks = [
    MenuFields(name: "913 茶王", english_name: "913 King's Oolong Tea", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/dgEXPQpc75Cs1o9Jcqbavw/lbFsAGxKg0YJQxoG7IxJvHUO1L8N_5GMFWIxl37ciDpZ-g_aenGsLKXGERi9OC1fzGFYWDGyT7jvJmAnW5YhJg/8Mzvgo314HP9cy_UIbBJbl2NCozZVrAhiN1ZNzaJKHw")!)], medium_price: 50, large_price: 60, info: ["Best Sellers"]),
    MenuFields(name: "珍珠鮮奶茶", english_name: "Black Tea Latte with Pearls", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/f8x2AiGA3lC9Pfkw9MSiDA/xNYoPkT0_eRKnXsAR65GhIhPfiYUk9-C9-ksZA75JNdEtoAIiuVz8TFwHZ9AJ9slgJsAsjpUNL6yQ-88c7qMmw/X8EEQLMkpTVUE8GQ0i2gGIaB1dlqnPjMWVDJWOHrCKg")!)], medium_price: 70, large_price: 90, info: ["Best Sellers"]),
    MenuFields(name: "鮮榨水果綠", english_name: "Green Tea with Fresh Fruit", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/n_53XzsCSEQ6D9shubKogg/v4XRlDSv_5Qy1zljaa66uUCs-q6JvDX0FcEINJ_wfk7doBtAxV0b91IExm_B6qCwPamAJR7vuT97VCJ5zmZZmw/gn2g5onrucxpnObXYXs5vwyujN1omzwKa9lkxeV67V8")!)], medium_price: 90, large_price: 110, info: ["Best Sellers","Cold Drinks Only"]),
    MenuFields(name: "蜂蜜綠茶", english_name: "Honey Green Tea", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/nmD2S2tvhg-9rog9ngyDWQ/TxD4UGMaexdvo4AvJiaypfWQQy9xjxoWKU2S7iLiVX9d86MsUc9ce6rErtGX7eciwHYzKZPlqkfNdBQ5mEYzlA/nUVq3i979zKVGWcu7c14w-NOHgeytjNVp99ODplAU-c")!)], medium_price: 50, large_price: 60, info: ["Best Sellers"]),
    MenuFields(name: "香芋鮮奶茶", english_name: "Taro Green Tea Latte", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/tBP5wj4u3hE4B8tlfg5frg/lAuYWYp5Zze3x8VE9G9zt-cquhCtj6RWO-V10oNsdAxwOHbFofeqP8B-gGGn2K7RDUfCkQ6PsVwSGni7o1WGeg/fv5YbKqAkVhV6VH68bpN_HtIn0q3FgjjoThB_Q-u8Cc")!)], medium_price: 90, large_price: 110, info: ["Best Sellers"]),
    MenuFields(name: "香橙綠茶", english_name: "Orange Green Tea", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/Lu-sO38NhYvOBXJBXZwdqg/9S_DJHvj8p9ORxPX3Dl2miLFRHF7sXePP7JMNx9gpDmgL3dZdqFavd8MmSJe5oizYUD_vc8g3E7qafJrGv8Sug/A2bZkccvbISxvDJz_Zi7BTllHumWDAvk08QJyFEUjxE")!)], medium_price: 70, large_price: 90, info: ["Best Sellers", "Cold Drinks Only"]),
    MenuFields(name: "洛神冰茶", english_name: "Roseelle Green Tea", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/CedwwKsb8v756LT7wB52HA/D0KVtSOJhS76llw6vvtgoKCDiDzD6HdziES5no2YhgwGYtpYoEVBmJLy_hPlPqbrxmaI73rBe8IwnNwNKnErVA/xxyqgd2nTgaM5cIP8BogxoV-PvrJVDcLfag2Zz1xC-c")!)], medium_price: 50, large_price: 60, info: ["Best Sellers", "Cold Drinks Only"]),
    MenuFields(name: "抹茶冰淇凌奶綠", english_name: "Matcha Ice Cream Green Tea", image: [MenuImage(url: URL(string: "https://v5.airtableusercontent.com/v1/4/4/1655942400000/gvBVx2OQ-IeMyYxwf8EG0A/oE67OgkGVGBcuBXvBIwnb-fRmqfz42ensiJ346GJLlMfjvSEpJ14IF2sB1VOjeewe7EXIoafKMvauNCu2wl_xg/WCfi72w_w98u8rBb8pM7B6iRN6hPjymoJ111efJDYOw")!)], medium_price: 90, large_price: nil, info: ["Best Sellers", "Cold Drinks Only", "Limited Edition"])]
