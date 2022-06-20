//
//  Tea.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import Foundation

struct Tea: Decodable {
    var records: [TeaRecord]
    struct TeaRecord: Decodable {
        var fields: TeaFields
        struct TeaFields: Decodable {
            let name: String
            let price: Int
            let url: URL
            let image: [TeaImage]
        }
    }
    struct TeaImage: Decodable {
        let url: URL
    }
}
