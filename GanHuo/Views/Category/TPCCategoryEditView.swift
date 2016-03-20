//
//  TPCCategoryEditView.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/16.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

let TPCCategoryStoreKey = "TPCCategoryStoreKey"
enum TPCCategoryEditType: Int {
    case Select
    case Edit
}

class TPCCategoryEditView: UIView {
    let reuseIdentifier = "TPCCategoryEditViewCell"
    var selectedAction: ((TPCCategoryEditView) -> Void)?
    var categories = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedCategory: String? {
        didSet {
            tableView.reloadData()
        }
    }
    var type: TPCCategoryEditType = .Select {
        didSet {
            tableView.setEditing(type == .Edit, animated: true)
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerNib(UINib(nibName: String(TPCCategoryEditViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
            tableView.separatorStyle = .None
            tableView.tableFooterView = UIView()
        }
    }
    
    static func editView() -> TPCCategoryEditView {
        return NSBundle.mainBundle().loadNibNamed(String(TPCCategoryEditView.self), owner: nil, options: nil).first as! TPCCategoryEditView
    }
}

extension TPCCategoryEditView: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCCategoryEditViewCell
        cell.categoryLabel.text = categories[indexPath.row]
        cell.type = type
        cell.enable = categories[indexPath.row] == selectedCategory
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return type == .Edit
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let s = categories[sourceIndexPath.row]
        categories.removeAtIndex(sourceIndexPath.row)
        categories.insert(s, atIndex: destinationIndexPath.row)
    }
}

extension TPCCategoryEditView: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if type == .Select {
            selectedCategory = categories[indexPath.row]
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            selectedAction?(self)
        }
    }
}