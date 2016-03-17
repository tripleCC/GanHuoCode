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
    lazy var categories: [String] = {
        return TPCStorageUtil.objectForKey(TPCCategoryStoreKey) as? [String] ?? [String]()
    }()
    var type: TPCCategoryEditType = .Select
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerNib(UINib(nibName: String(TPCCategoryEditViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    deinit {
        TPCStorageUtil.setObject(categories, forKey: TPCCategoryStoreKey)
    }
}

extension TPCCategoryEditView: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCCategoryEditViewCell
        cell.categoryLabel.text = categories[indexPath.row]
        cell.type = type
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}

extension TPCCategoryEditView: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if type == .Select {
            // TODO 跳转到主界面
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        print(__FUNCTION__)
        return type == .Edit
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        print(__FUNCTION__)
        return .None
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let s = categories[sourceIndexPath.row]
        categories.removeAtIndex(sourceIndexPath.row)
        categories.insert(s, atIndex: destinationIndexPath.row)
        print(__FUNCTION__)
    }
}