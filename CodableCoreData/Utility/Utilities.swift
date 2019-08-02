//
//  Utilities.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 2/2/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//

import Foundation
import UIKit

public enum DataLoadingState {
    case loading
    case loaded
    case noData
    case error
    case noNetwork
}

public enum CoreDataError: Error {
    case dataFetchFailed
    case invalidRequest
    case noData
}

/// NSPredicate expression keys.
public enum ExpressionKeys: String {
    case name
    case city
    case address
    
    static func allKeys() -> [String] {
        return [ExpressionKeys.name.rawValue, ExpressionKeys.city.rawValue, ExpressionKeys.address.rawValue]
    }
}

public extension String {
    func date(withFormat format: String = "MM/dd/yyyy") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func stationsFilterPredicate() -> NSCompoundPredicate {
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = self.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Build all the "AND" expressions for each value in searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            return searchString.filterPredicate(with: ExpressionKeys.allKeys())
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        return finalCompoundPredicate
    }
    
    func filterPredicate(with matches: [String]) -> NSCompoundPredicate {
        /** Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
         Example if searchItems contains "Gladiolus 51.99 2001":
         name CONTAINS[c] "gladiolus"
         name CONTAINS[c] "gladiolus", yearIntroduced ==[c] 2001, introPrice ==[c] 51.99
         name CONTAINS[c] "ginger", yearIntroduced ==[c] 2007, introPrice ==[c] 49.98
         */
        var searchItemsPredicate = [NSPredicate]()
        
        /** Below we use NSExpression represent expressions in our predicates.
         NSPredicate is made up of smaller, atomic parts:
         two NSExpressions (a left-hand value and a right-hand value).
         */
        let searchStringExpression = NSExpression(forConstantValue: self)

        for key in matches {
            let titleExpression = NSExpression(forKeyPath: key)
            
            let titleSearchComparisonPredicate =
                NSComparisonPredicate(leftExpression: titleExpression,
                                      rightExpression: searchStringExpression,
                                      modifier: .direct,
                                      type: .contains,
                                      options: [.caseInsensitive, .diacriticInsensitive])
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
        }
        
        let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
        return orMatchPredicate
    }
}
