//
//  TPCSearchViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/19.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCSearchViewController: TPCViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(UINib(nibName: String(TPCCategoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: resultReuseIdentifier)
        }
    }
    
    var searchBar: UISearchBar!
    let resultReuseIdentifier = "TPCCategoryTableViewCell"
    let historyReuseIdentifier = "TPCSearchHistoryViewCell"
    var searchResults = [GanHuoObject]()
    var searchHistories = [String]()
    var searchDone = false
    var showHistories = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarType = .Line
        setupNav()
        addSearchBar()
        
        doOnceInAppLifeWithKey("TPCSearchViewController.showSearchTip") {
            dispatchSeconds(0.5, action: {
                self.showSearchTip()
            })
        }
        
//        navigationItem.leftBarButtonItem = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.top = TPCNavigationBarHeight + TPCStatusBarHeight
    }
    
    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .Done, target: self, action: #selector(cancel))
    }
    
    func cancel() {
        searchBar.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func addSearchBar() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: TPCScreenWidth - 60, height: TPCNavigationBarHeight))
        searchBar = UISearchBar(frame: CGRect(x: -30.0, y: 0, width: TPCScreenWidth - 60, height: containerView.frame.height))
        searchBar.placeholder = "输入关键字"
        searchBar.delegate = self
        searchBar.tintColor = TPCConfiguration.navigationBarBackColor
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = false
        containerView.addSubview(searchBar)
        navigationItem.titleView = containerView
        removeSearchBarBackgroundColor()
        
        // 只有第一次生效，后续就不生效了。。。
//        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).backgroundColor = UIColor.lightGrayColor()
        // .colorWithAlphaComponent(0.2)
        // private api
        (searchBar.valueForKey("_searchField") as! UITextField).backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.15)
    }
    
    private func removeSearchBarBackgroundColor() {
        for subview in searchBar.subviews where subview.subviews.count > 0 {
            subview.subviews.first?.removeFromSuperview()
            break
        }
    }
    
    private func showSearchTip() {
        let alert = UIAlertController(title: "", message: "这里的搜索都是针对本地缓存，为了搜索的结果尽量全面，需要先在分类中手动加载尽可能多的数据...", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .Default, handler: nil))
        navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func fetchGanHuoByKey(key: String, completion:(([GanHuoObject]) -> Void)){
        TPCCoreDataManager.shareInstance.backgroundManagedObjectContext.performBlock {
            var ganhuos = [GanHuoObject]()
            for i in 0 ..< key.characters.count {
                let fetchResults = GanHuoObject.fetchSearchResultsByKey(key.substringFromIndex(key.startIndex.advancedBy(i)))
                ganhuos.appendContentsOf(fetchResults.filter{ !ganhuos.contains($0) })
            }
            dispatchAMain({
                completion(ganhuos)
            })
        }
    }
}

extension TPCSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showHistories ? searchHistories.count : searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = showHistories ? historyReuseIdentifier : resultReuseIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if showHistories {
            (cell as! TPCSearchHistoryViewCell).history = searchHistories[indexPath.row]
            (cell as! TPCSearchHistoryViewCell).closeAction = { [unowned self] history in
                if let index = self.searchHistories.indexOf(history) {
                    self.searchHistories.removeAtIndex(index)
                    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                    TPCStorageUtil.setObject(self.searchHistories, forKey: TPCSearchHistoriesKey)
                }
            }
        } else {
            (cell as! TPCCategoryTableViewCell).ganhuo = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if showHistories {
            return 44
        } else {
            if let height = searchResults[indexPath.row].cellHeight {
                return CGFloat(height.floatValue)
            }
            return TPCCategoryTableViewCell.cellHeightWithGanHuo(searchResults[indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        guard !searchDone else { return containerView }
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 35))
        let textLabel = UILabel(frame: CGRect(origin: CGPoint(x: 5, y: 0), size: CGSize(width: containerView.frame.width - 5, height: containerView.frame.height)))
        textLabel.text = showHistories ? "搜索记录" : "搜索 \"\(searchBar.text ?? "")\""
        textLabel.font = UIFont.systemFontOfSize(14)
        textLabel.textColor = TPCConfiguration.navigationBarBackColor
        textLabel.backgroundColor = UIColor.whiteColor()
        
        containerView.addSubview(textLabel)
        
        return containerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchDone ? 0.1 : 35
    }
//    
//    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let containerView = UIView()
//        guard !searchDone else { return containerView }
//        containerView.backgroundColor = UIColor.whiteColor()
//        containerView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 35))
//        let textLabel = UILabel(frame: CGRect(origin: CGPoint(x: 5, y: 0), size: CGSize(width: containerView.frame.width - 5, height: containerView.frame.height)))
//        textLabel.text = showHistories ? "搜索记录" : "搜索 \"\(searchBar.text ?? "")\""
//        textLabel.font = UIFont.systemFontOfSize(16)
//        textLabel.textColor = TPCConfiguration.navigationBarBackColor
//        textLabel.backgroundColor = UIColor.whiteColor()
//        
//        containerView.addSubview(textLabel)
//        
//        return containerView
//    }
//    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return showHistories ? 40 : 0.1
        return 0.1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if showHistories {
            searchBar.text = searchHistories[indexPath.row]
            showHistories = false
            searchGanHuoAndRefreshByKey(searchHistories[indexPath.row])
        } else {
            searchBar.endEditing(true)
            // 等键盘隐藏后才push，不然会有瑕疵
            dispatchSeconds(0.3, action: {
                if let url = self.searchResults[indexPath.row].url {
                    self.pushToBrowserViewControllerWithURLString(url, ganhuo: self.searchResults[indexPath.row])
                }
            })
        }
    }
}

extension TPCSearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if !showHistories {
            tableView.contentInset.bottom = 0
            searchBar.endEditing(true)
        } else if searchBar.isFirstResponder() {
            tableView.contentInset.bottom = TPCIphoneKeyboardHeight
        }
    }
}

extension TPCSearchViewController: UISearchBarDelegate {
    private func searchGanHuoAndRefreshByKey(key: String) {
        guard key.characters.count > 0 else { return }
        fetchGanHuoByKey(key, completion: { (ganhuos) in
//            print(ganhuos.flatMap{
//                $0.desc
//                })
            self.searchResults = ganhuos
            self.tableView.reloadData()
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            showHistories = true
            tableView.reloadData()
        } else {
            showHistories = false
            searchGanHuoAndRefreshByKey(searchText)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchDone = true
        searchBar.endEditing(true)
        if let searchKey = searchBar.text {
            if !searchHistories.contains(searchKey) && searchKey.characters.count > 0 {
                searchHistories.insert(searchKey, atIndex: 0)
                TPCStorageUtil.setObject(searchHistories, forKey: TPCSearchHistoriesKey)
                print("save histories")
            }
            searchGanHuoAndRefreshByKey(searchKey)
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // show history
        searchDone = false
        if let histories = TPCStorageUtil.objectForKey(TPCSearchHistoriesKey) as? [String] {
            searchHistories = histories
            tableView.reloadData()
            print("fetch histories")
        }
    }
}
