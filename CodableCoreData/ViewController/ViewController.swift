//
//  ViewController.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 7/31/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let viewModel = AccountViewModel()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.register(TransactionTableViewCell.self,
                           forCellReuseIdentifier: String(describing: TransactionTableViewCell.self))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        self.title = NSLocalizedString("My Accounts", comment: "")
        
        makeInterface()
        makeConstraints()
        
        let button = UIBarButtonItem.init(title: "Add Account", style: .plain, target: self, action: #selector(addAccount))
        self.navigationItem.rightBarButtonItem = button
        
        viewModel.reloadData()
        self.tableView.reloadData()
        
        addAccount()
    }
}

extension ViewController {
    func makeInterface() {
        self.view.addSubview(tableView)
    }
    
    func makeConstraints() {
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5.0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5.0).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5.0).isActive = true
    }
    
    @objc func addAccount() {
        let jsonString = """
{
    "account": {
        "uId": "ABCD",
        "name": "Ravi Checking",
        "mask": "3434"
    },
    "transactions": [{
            "uId": "1234",
            "name": "Peet's coffee",
            "location": "Fremont"
        },
        {
            "uId": "4545",
            "name": "Apple",
            "location": "Online"
        }
    ]
}
"""
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
                    self.viewModel.persist(data: json) {
                        self.viewModel.reloadData()
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Failed to serialize json \(error)")
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfAccounts()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.account(at: section)?.name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let account = viewModel.account(at: section) else { return 0 }
        return viewModel.numberOfTransactions(of: account)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TransactionTableViewCell.self), for: indexPath) as? TransactionTableViewCell,
            let account = viewModel.account(at: indexPath.section),
            let transaction = viewModel.transaction(of: account, index: indexPath.row) else { return UITableViewCell() }
        
        cell.setup(with: transaction)
        return cell
    }
}
