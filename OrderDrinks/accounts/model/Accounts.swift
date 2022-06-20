//
//  Accounts.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/14.
//

import Foundation


struct Accounts: Codable {
    var records: [AccountsRecord]
    struct AccountsRecord: Codable {
        var fields: AccountsFields
        struct AccountsFields: Codable {
            var account: String
            var password: String
        }
    }
}

var currentAccounts = ("", "")



