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
            tableView.registerNib(UINib(nibName: String(TPCCategoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    var searchBar: UISearchBar!
    let reuseIdentifier = "TPCCategoryTableViewCell"
    var searchResults = [GanHuoObject]()
    var searchHistories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        addSearchBar()
        
        doOnceInAppLifeWithKey(String(TPCSearchViewController.showSearchTip)) {
            dispatchSeconds(0.5, action: {
                self.showSearchTip()
            })
        }
        
//        fetchGanHuoByKey("swift", completion: { (ganhuos) in
//            print(ganhuos.flatMap{
//                $0.desc
//                })
//        })
        
//        navigationItem.leftBarButtonItem = nil
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
        (searchBar.valueForKey("_searchField") as! UITextField).backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
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
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TPCCategoryTableViewCell
        cell.ganhuo = searchResults[indexPath.row]
        return cell
    }
}

extension TPCSearchViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print(#function)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print(#function)
    }
}
