//
//  AddNewDrinks.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/12.
//

import Foundation


var allGroups = ["無群組"]
struct AddNewGroup: Codable {
    var records: [AddGroupRecord]
    struct AddGroupRecord: Codable {
        var id: String
        var fields: AddGroupFields
    }
    struct AddGroupFields: Codable {
        var group: String?
        var groupHost: String?
        var priority: Int
    }
}

struct UpdateDrinks: Codable {
    var records: [UpdateDrinksRecord]
    struct UpdateDrinksRecord: Codable {
        var id: String
        var fields: UpdateDrinksFields
        }
    struct UpdateDrinksFields: Codable {
        var name: String?
        var counts: Int?
        var size: String?
        var drink: String?
        var ice: String?
        var sugar: String?
        var per_price: Int?
        var total_price: Int?
        var pearls: Bool?
        var honey: Bool?
        var grass_jelly: Bool?
        var image: [NewDrinksImage?]
        var group: String?
        var groupHost: String?
        var priority: Int
        var account_name: String
        var type_index: Int?
        var item_index: Int?
        struct NewDrinksImage: Codable {
            var url: URL?
        }
    }
    
}

struct NewDrinks: Codable {
    var records: [NewDrinksRecord]
    struct NewDrinksRecord: Codable{
        var fields: NewDrinksFields
        struct NewDrinksFields: Codable {
            var name: String?
            var counts: Int?
            var size: String?
            var drink: String?
            var ice: String?
            var sugar: String?
            var per_price: Int?
            var total_price: Int?
            var pearls: Bool?
            var honey: Bool?
            var grass_jelly: Bool?
            var image: [NewDrinksImage?]
            var group: String?
            var groupHost: String?
            var priority: Int
            var account_name: String
            var type_index: Int?
            var item_index: Int?
            struct NewDrinksImage: Codable {
                var url: URL?
            }
        }
    }
}
