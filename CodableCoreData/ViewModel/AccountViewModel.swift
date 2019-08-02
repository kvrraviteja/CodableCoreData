//
//  AccountViewModel.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 7/2/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//

import Foundation

class AccountViewModel {
    var accounts = [Account]()
    var transactions = [Transaction]()
    
    func reloadData() {
        CoreDataManager.shared.viewContext.fetch(Account.entity(), success: { (accounts: [Account]) in
            self.accounts = accounts
        }) { (_) in
            print("Error fetching existing accounts")
        }
        
        CoreDataManager.shared.viewContext.fetch(Transaction.entity(), success: { (transactions: [Transaction]) in
            self.transactions = transactions
        }) { (_) in
            print("Error fetching existing transactions")
        }
    }
}

extension AccountViewModel {
    func persist(data: [String: Any], completion: () -> Void) {
        guard let accountData = data["account"] as? [String: String] else {
            completion()
            return
        }
        
        // Persist account data
        CoreDataManager.shared.persist(accountData, success: { (account: Account) in
            
            guard let transactionsData = data["transactions"] as? [[String: String]] else {
                completion()
                return
            }
            
            for transactionData in transactionsData {
                // Persist transaction and establish relationship between transaction and account.
                CoreDataManager.shared.persist(transactionData, success: { (transaction: Transaction) in
                    transaction.account = account
                }) { (_) in
                    print("Error saving Transaction")
                }
            }
            
            
            // Save the context
            CoreDataManager.shared.saveViewContext()
            completion()
        }) { (_) in
            print("Error saving Account")
            completion()
        }
    }
}

extension AccountViewModel {
    
    func numberOfAccounts() -> Int {
        return accounts.count
    }
    
    func account(at index: Int) -> Account? {
        guard index >= 0 && index < accounts.count else { return nil }
        return accounts[index]
    }
    
    func numberOfTransactions(of type: Account) -> Int {
        return transactions(of: type)?.count ?? 0
    }
    
    func transactions(of type: Account) -> [Transaction]? {
        let filteredTransactions = self.transactions.filter({ $0.account?.uId == type.uId })
        return filteredTransactions
    }
    
    func transaction(of type: Account, index: Int) -> Transaction? {
        guard let transactions = transactions(of: type),
            index >= 0,
            index < transactions.count else { return nil }
        return transactions[index]
    }
}
