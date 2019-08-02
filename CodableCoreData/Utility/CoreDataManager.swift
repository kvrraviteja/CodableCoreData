//
//  CoreDataManager.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 2/10/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//

import Foundation
import CoreData

public typealias CodableManagedObject = NSManagedObject & Codable

public enum CoreDataError: Error {
    case dataFetchFailed
    case invalidRequest
    case noData
}

final class CoreDataManager {

    static let shared = CoreDataManager()
    
    lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer.init(name: "CodableCoreData")
        container.loadPersistentStores(completionHandler: { [weak self](iDescription, iError) in
            if let storeError = iError {
                print("Error while creting store \(storeError)")
            }
        })
        
        return container
    }()
    
    lazy var viewContext : NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var backgroundContext : NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
    
    func performForegroundTask(_ block : @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }
    
    @discardableResult
    func saveViewContext() -> Bool {
        var saveSuccess = true
        
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
            } catch {
                print("Saving View context Failed with error : \(error)")
                self.viewContext.rollback()
                saveSuccess = false
            }
        }
        return saveSuccess
    }
}

extension CoreDataManager {
    public func persist<T: CodableManagedObject>(_ json: [String: Any],
                                          success: (T) -> Void,
                                          failure: (Error) -> Void) {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context!] = self.viewContext
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let savedObject = try decoder.decode(T.self, from: data)
            self.saveViewContext()
            success(savedObject)
        } catch {
            print("Failed to save objects \(error)")
            failure(error)
        }
    }
}

extension NSManagedObjectContext {
    func fetch<T: CodableManagedObject>(_ entity: NSEntityDescription,
                                   predicate: NSPredicate? = nil,
                                   sort: [NSSortDescriptor]? = nil,
                                   success: ([T]) -> Void,
                                   failure: (Error) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sort
        
        self.performAndWait {
            do {
                guard let response = try self.fetch(fetchRequest) as? [T] else {
                    failure(CoreDataError.dataFetchFailed)
                    return
                }
                
                success(response)
            } catch  {
                print("Error while executing fetch request : \(fetchRequest), error : \(error)")
                failure(error)
            }
        }
    }
    
    func insert<T: CodableManagedObject>(_ entity: NSEntityDescription,
                                    predicate: NSPredicate?,
                                    success: ([T]) -> Void,
                                    failure: (Error) -> Void)  {
        
        guard let predicate = predicate else {
            self.insert(entity, success: success, failure: failure)
            return
        }
        
        self.fetch(entity, predicate: predicate, sort: nil, success: { (fetchedObjs: [T]) in
            if fetchedObjs.isEmpty {
                self.insert(entity, success: success, failure: failure)
            } else {
                success(fetchedObjs)
            }
            
        }, failure: failure)
    }
    
    private func insert<T: CodableManagedObject>(_ entity: NSEntityDescription,
                                            success: ([T]) -> Void,
                                            failure: (Error) -> Void)  {
        guard let name = entity.name,
            let object = NSEntityDescription.insertNewObject(forEntityName: name, into: self) as? T else {
                failure(CoreDataError.dataFetchFailed)
                return
        }
        success([object])
    }

    //Delte records of the entity with the given map / condition.
    func delete<T: CodableManagedObject>(of type: T.Type,
                                    predicate: NSPredicate?,
                                    callBack: (Error) -> ()) {
        
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest.init(fetchRequest: fetchRequest)
        
        do {
            try self.persistentStoreCoordinator?.execute(batchDeleteRequest, with: self)
            try saveContext()
        }
        catch {
            print("Failed to delete the records with map : \(String(describing: predicate)). Type : \(T.self)")
            callBack(error)
        }
    }
    
    //Use this method wisely. This could potentially delete all the records of a Entity.
    func batchDelete<T: CodableManagedObject>(of type: T.Type,
                                          predicate: NSPredicate?,
                                          callBack: (Error) -> ()) {
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest.init(fetchRequest: fetchRequest)
        
        do {
            try self.persistentStoreCoordinator?.execute(batchDeleteRequest, with: self)
            try saveContext()
        }
        catch {
            print("Failed to delete the records with predicate : \(String(describing: predicate)). Type : \(T.self)")
            callBack(error)
        }
    }
    
    //Save the current context
    func saveContext() throws {
        if self.hasChanges {
            do {
                try self.save()
                print("Saved context : \(self)")
            } catch {
                print("Saving context : \(self), failed with error : \(error)")
                throw error
            }
        }
        else {
            print("Context : \(self), has no changes")
        }
    }
    
    func fetch<T: CodableManagedObject>(_ entity : NSEntityDescription?,
               properties: [Any]?,
               predicate : NSPredicate?,
               sortBy : [NSSortDescriptor]?,
               success: ([T]) -> Void,
               failure: (_ error: Error) -> Void) {
        
        guard let entityDescription = entity else {
            failure(CoreDataError.dataFetchFailed)
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortBy
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = properties
        fetchRequest.returnsDistinctResults = true
        
        do {
            guard let resultObjs = try self.fetch(fetchRequest) as? [T] else {
                failure(CoreDataError.dataFetchFailed)
                return
            }
            success(resultObjs)
        } catch  {
            failure(CoreDataError.dataFetchFailed)
        }
    }
}

extension NSPredicate {
    class func predicate(dictionary : [String : Any]?) -> NSPredicate? {
        var predicate : NSPredicate!
        
        if let keys = dictionary?.keys {
            let predicateString = NSMutableString.init()
            for (index, key) in keys.enumerated() {
                if let value = dictionary?[key] {
                    predicateString.append("\(key) = \(value)")
                    
                    if index != keys.count - 1 {
                        predicateString.append(" AND ")
                    }
                }
            }
            predicate = NSPredicate.init(format: predicateString as String, argumentArray: nil)
        }
        return predicate
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}
