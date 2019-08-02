//
//  Transaction+CoreDataClass.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 7/31/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: CodableManagedObject {
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case uId = "uId"
        case location = "location"
        case account = "account"
    }
    
    @NSManaged public var uId: String?
    @NSManaged public var name: String?
    @NSManaged public var location: String?
    @NSManaged public var account: Account?
    
    public required init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: managedObjectContext) else { fatalError("Failed to decode Transaction") }
        
        super.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
        self.uId = try values.decodeIfPresent(String.self, forKey: .uId)
        self.location = try values.decodeIfPresent(String.self, forKey: .location)
//        self.account = try values.decode(Account.self, forKey: .account)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(uId, forKey: .uId)
        try container.encode(location, forKey: .location)
//        try container.encode(account, forKey: .account)
    }
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
