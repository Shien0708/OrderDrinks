//
//  Store.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import Foundation

struct StoreInfo: Decodable {
    let records: [StoreInfoRecord]
    struct StoreInfoRecord: Decodable {
        let fields: StoreInfoFields
        struct StoreInfoFields: Decodable {
            var name: String
            var address: String
            var phone: String
        }
    }
}
