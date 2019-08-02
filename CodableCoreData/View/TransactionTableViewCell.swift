//
//  AccountTableViewCell.swift
//  CodableCoreData
//
//  Created by Ravi Karnatakam on 7/11/19.
//  Copyright © 2019 Ravi Karnatakam. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.font = UIFont(name: "Helvetica-Bold", size: 15.0)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor.gray
        label.font = UIFont(name: "Helvetica-Light", size: 15.0)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.font = UIFont(name: "Helvetica", size: 15.0)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.alignment = .leading
        stack.distribution = .fill
        stack.axis = .vertical
        stack.addArrangedSubview(self.nameLabel)
        stack.addArrangedSubview(self.dateLabel)
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeInterface()
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeInterface() {
        self.contentView.addSubview(stackView)
        self.contentView.addSubview(amountLabel)
    }
    
    func makeConstraints() {
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15.0).isActive = true
        
        amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0).isActive = true
        amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0).isActive = true
        amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15.0).isActive = true
        
        stackView.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: 10.0).isActive = true
    }
    
    func setup(with transaction: Transaction) {
        self.nameLabel.text = transaction.name
        self.amountLabel.text = transaction.location
        self.dateLabel.text = transaction.uId
    }
}
