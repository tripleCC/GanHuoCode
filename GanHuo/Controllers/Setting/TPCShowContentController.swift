//
//  TPCShowContentController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCShowContentController: TPCViewController {
    private let reuseIdentifier = "TPCSettingSubCell"
    private let testStringArray = ["Swift 中枚举高级用法及实践\n", "专访YYKit作者郭曜源：开源大牛是怎样炼成的\n", "YYDispatchQueuePool 源码阅读笔记\n", "Announcing Revert\n", "SCCatWaitingHUD的Objc代码实现\n", "在通知中心一键启用VPN\n", "简洁又美好的 OS X 下北理校园网登陆客户端\n", "一个弹性侧滑菜单\n"]
    private let rules = TPCConfiguration.allRules
    var selectedRows = [TPCRuleType]()
    var callAction: ((items: [TPCRuleType]) -> ())?
    @IBOutlet weak var ruleImageView: UIImageView! {
        didSet {
            ruleImageView.layer.borderWidth = 1.0
            ruleImageView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2).CGColor
        }
    }
    @IBOutlet weak var ruleContainter: UIView! {
        didSet {
            ruleContainter.layer.shadowColor = UIColor.lightGrayColor().CGColor
            ruleContainter.layer.shadowRadius = 3
            ruleContainter.layer.shadowOpacity = 1
            ruleContainter.layer.shadowOffset = CGSize(width: 4, height: 4)
        }
    }
    @IBOutlet weak var ruleLabel: TPCGradientLabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = TPCConfiguration.settingCellHeight
            tableView.contentInset = UIEdgeInsets(top: TPCNavigationBarHeight + TPCStatusBarHeight, left: 0, bottom: 0, right: 0)
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 15))
            tableView.tableFooterView = UIView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustRulelabel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        callAction?(items: selectedRows)
        postReloadTableView()
    }
    
    private func getFinalString() -> String {
        var validDescCount = 0
        var destString: String = ""
        for testString in testStringArray {
            if (selectedRows.contains(TPCRuleType.Two) && selectedRows.contains(TPCRuleType.Three)) {
                if testString.ruleLabelBoundingRect().width < ruleLabel.bounds.width {
                    validDescCount += 1
                    if validDescCount < TPCConfiguration.technicalCellShowTextLineMax {
                        destString += testString
                    }
                }
            } else if (selectedRows.contains(TPCRuleType.Two)) {
                if testString.ruleLabelBoundingRect().width < ruleLabel.bounds.width {
                    destString += testString
                }
            } else if (selectedRows.contains(TPCRuleType.Three)) {
                validDescCount += 1
                if validDescCount < TPCConfiguration.technicalCellShowTextLineMax {
                    destString += testString
                }
            } else if (selectedRows.contains(TPCRuleType.Four)) {
                destString += testString
            }
        }
        if destString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            destString = destString.substringToIndex(destString.endIndex.advancedBy(-1))
        }
        return destString
    }
}
extension TPCShowContentController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rules.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCSettingSubCell
        cell.textLabel?.text = rules[indexPath.row].rawValue
        cell.selectedButton.enable = ruleRouter(rules[indexPath.row])
        
        return cell
    }
    
    func ruleRouter(rule: TPCRuleType) -> Bool {
        switch rule {
            case .One:
                if selectedRows.contains(TPCRuleType.Two) || selectedRows.contains(TPCRuleType.Three) {
                        return false
                } else {
                    return selectedRows.contains(TPCRuleType.One)
                }
            case .Two:
                if selectedRows.contains(TPCRuleType.One) {
                    return false
                } else {
                    return selectedRows.contains(TPCRuleType.Two)
                }
            case .Three:
                if selectedRows.contains(TPCRuleType.One) {
                    return false
                } else {
                    return selectedRows.contains(TPCRuleType.Three)
                }
            case .Four:
                if selectedRows.contains(TPCRuleType.Two) || selectedRows.contains(TPCRuleType.Three) || selectedRows.contains(TPCRuleType.One) {
                    return false
                } else {
                   return selectedRows.contains(TPCRuleType.Four)
            }
        }
    }
}

extension TPCShowContentController: UITableViewDelegate {
    private func adjustSelectRowsByIndexPath(indexPath: NSIndexPath) {
        if selectedRows.contains(rules[indexPath.row]) {
            if rules[indexPath.row] != TPCRuleType.One {
                selectedRows.removeAtIndex(selectedRows.indexOf(rules[indexPath.row])!)
                if selectedRows.count == 0 {
                    selectedRows.append(TPCRuleType.One)
                }
            }
        } else {
            if rules[indexPath.row] == TPCRuleType.One {
                selectedRows.removeAll()
            } else if rules[indexPath.row] == TPCRuleType.Three || rules[indexPath.row] == TPCRuleType.Two {
                if !selectedRows.contains(TPCRuleType.Two) && !selectedRows.contains(TPCRuleType.Three) {
                    selectedRows.removeAll()
                }
            } else if rules[indexPath.row] == TPCRuleType.Four {
                selectedRows.removeAll()
            }
            selectedRows.append(rules[indexPath.row])
        }
    }
    
    private func adjustRulelabel() {
        ruleLabel.text = getFinalString()
        ruleLabel.layoutIfNeeded()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        debugPrint(selectedRows)
        adjustSelectRowsByIndexPath(indexPath)
        adjustRulelabel()
        tableView.reloadData()
    }
}
