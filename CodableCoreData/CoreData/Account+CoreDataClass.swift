//
//  Account+CoreDataClass.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 7/31/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Account)
public class Account: CodableCoreData {
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case uId = "uId"
        case mask = "mask"
        case transactions = "transactions"
    }
    
    // MARK: - Core Data Managed Object
    @NSManaged public var uId: String?
    @NSManaged public var name: String?
    @NSManaged public var mask: String?
    @NSManaged public var transactions: [Transaction]?

    public required init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext) else { fatalError("Failed to decode Institution") }
        
        super.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
        self.uId = try values.decodeIfPresent(String.self, forKey: .uId)
        self.mask = try values.decodeIfPresent(String.self, forKey: .mask)
//        self.transactions = try [values.decode(Transaction.self, forKey: .transactions)]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(uId, forKey: .uId)
        try container.encode(mask, forKey: .mask)
//        try container.encode(transactions ?? nil, forKey: CodingKeys.transactions)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

// MARK: Generated accessors for accounts
// MARK: Generated accessors for transactions
extension Account {
    
    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)
    
    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)
    
    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)
    
    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)
    
}
