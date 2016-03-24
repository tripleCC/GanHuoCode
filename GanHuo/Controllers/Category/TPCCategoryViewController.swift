//
//  TPCCategoryViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/1.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCategoryViewController: TPCViewController {
    
    @IBOutlet weak var favoriteView: TPCFavoriteGanHuoView! {
        didSet {
            favoriteView.hidden = true
        }
    }
    @IBOutlet weak var tipButton: UIButton! {
        didSet {
//            tipButton.
        }
    }
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var selectHeaderView: TPCSelectHeaderView! {
        didSet {
            selectHeaderView.delegate = self
        }
    }
    @IBOutlet weak var editHeaderView: UIView!
    var childControllers = [TPCSubCategoryViewController]()
    var editView = TPCCategoryEditView.editView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildController()
        navigationBarType = .Line
        setupNav()
        view.insertSubview(editView, belowSubview: headerContainerView)
        editView.selectedAction = { editView in
            self.arrowButtonOnClicked(self.arrowButton)
            // 有可能调整顺序后，还没有加载的页面刚好在当前页面，所以UIScrollView的代理方法不会被调用，也就不会主动加载数据
            self.loadControllerView()
        }
    }
    
    private func setupNav() {
        let segmentView = UISegmentedControl(items: ["分类", "收藏"])
        segmentView.addTarget(self, action: #selector(TPCCategoryViewController.segmenViewOnClicked(_:)), forControlEvents: UIControlEvents.ValueChanged)
        segmentView.frame = CGRect(x: 0, y: 0, width: 150, height: 30)
        segmentView.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
        let titleFont = UIFont(name: TPCConfiguration.themeSFontName, size: 13.0)!
        segmentView.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : titleFont], forState: .Selected)
        segmentView.setTitleTextAttributes([NSFontAttributeName : titleFont], forState: .Normal)
        segmentView.selectedSegmentIndex = 0
        navigationItem.titleView = segmentView
    }
    
    func segmenViewOnClicked(sender: UISegmentedControl) {
        debugPrint(sender.selectedSegmentIndex)
        favoriteView.hidden = sender.selectedSegmentIndex != 1
        contentScrollView.hidden = !favoriteView.hidden
        headerContainerView.hidden = contentScrollView.hidden
        editHeaderView.hidden = contentScrollView.hidden
        editView.hidden = editHeaderView.hidden
        if sender.selectedSegmentIndex == 1 {
            doOnceInAppLifeWithKey("TPCCategoryViewController.showFavoriteTip", action: {
                self.showFavoriteTip()
            })
        }
    }
    
    private func showFavoriteTip() {
        let alert = UIAlertController(title: "", message: "收藏的文章会在App升级或者删除时清空，所以要记得及时阅读哦~", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .Default, handler: nil))
        navigationController?.presentViewController(alert, animated: true, completion: nil)
    }

    private func setupChildController() {
        let titles = TPCStorageUtil.objectForKey(TPCCategoryStoreKey) as? [String] ?? TPCConfiguration.allCategories
        titles.filter{ $0 != "福利" }.forEach {
            let subCategoryVc = TPCSubCategoryViewController()
            subCategoryVc.title = $0
            addChildViewController(subCategoryVc)
            childControllers.append(subCategoryVc)
        }
        contentScrollView.contentSize.width = CGFloat(childViewControllers.count) * TPCScreenWidth
        automaticallyAdjustsScrollViewInsets = false
        selectHeaderView.titles =  childViewControllers.map{ $0.title! }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectHeaderView.setupSubviewsFrame()
        if !arrowButton.selected {
            scrollViewDidEndScrollingAnimation(contentScrollView)
            editView.frame = contentScrollView.frame
            editView.frame.origin.y = headerContainerView.frame.maxY - contentScrollView.frame.height
        }
    }
    
    @IBAction func arrowButtonOnClicked(sender: AnyObject) {
        let arrowButton = sender as! UIButton
        arrowButton.selected = !arrowButton.selected
        let isSelected = arrowButton.selected
        debugPrint(isSelected)
        if !isSelected {
            TPCStorageUtil.setObject(editView.categories, forKey: TPCCategoryStoreKey)
            adjustChildControllersViewFrame()
            selectHeaderView.titles = editView.categories
            selectHeaderView.selectedTitle = editView.selectedCategory
            adjustContentViewOffsetByDisableButton(selectHeaderView.disabledButton!)
        } else {
            editView.categories = selectHeaderView.titles
            editView.selectedCategory = selectHeaderView.selectedTitle
        }
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            arrowButton.imageView!.transform = CGAffineTransformRotate(arrowButton.imageView!.transform, CGFloat(M_PI))
            self.editHeaderView.alpha = isSelected ? 1 : 0
            if isSelected {
                self.editView.transform = CGAffineTransformMakeTranslation(0, self.editView.bounds.height)
            } else {
                self.editView.transform = CGAffineTransformIdentity
            }
            }) { (finished) -> Void in
                if !isSelected {
                    self.editView.type = .Select
                    self.sortButton.selected = false
                    self.tipButton.selected = false
                }
        }
    }
    
    private func adjustChildControllersViewFrame() {
        // 根据调整的分类顺序排序子控制器
        var childControllersTemp = [TPCSubCategoryViewController]()
        for category in editView.categories {
            for vc in childControllers {
                if category == vc.title {
                    childControllersTemp.append(vc)
                }
            }
        }
        childControllers = childControllersTemp
        
        // 调整已显示的子控制器view的坐标
        childControllers.forEach{
            if let title = $0.categoryTitle {
                if let index = editView.categories.indexOf(title) {
                    $0.view.frame = CGRect(origin: CGPoint(x: CGFloat(index) * contentScrollView.frame.size.width, y: 0), size: contentScrollView.frame.size)
                }
            }
        }
        debugPrint(childControllers.map{ $0.categoryTitle }, childControllers.map{ $0.title })
    }
    
    @IBAction func sortButtonOnClicked(sender: UIButton) {
        if sender.selected {
            sender.titleLabel?.text = "调整顺序"
            tipButton.titleLabel?.text = "选择分类"
            editView.type = .Select
        } else {
            sender.titleLabel?.text = "完成"
            tipButton.titleLabel?.text = "按住右边的按钮拖动排序"
            editView.type = .Edit
        }
        sender.selected = !sender.selected
        tipButton.selected = sender.selected
    }
}

extension TPCCategoryViewController : TPCSelectHeaderViewDelegate {
    func selectHeaderView(view: TPCSelectHeaderView, didSelectButton button: UIButton) {
        adjustContentViewOffsetByDisableButton(button)
    }
    
    private func adjustContentViewOffsetByDisableButton(button: UIButton, animate: Bool = true) {
        let contentOffsetX = button.frame.origin.x / button.frame.size.width * contentScrollView.frame.size.width
        contentScrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
    }
}

extension TPCCategoryViewController : UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let idx = scrollView.contentOffset.x / scrollView.frame.size.width
        let centerX = selectHeaderView.centerXOfButtonIndex(Int(idx))
        var headerViewOffsetX = centerX - selectHeaderView.frame.size.width * 0.5
        headerViewOffsetX = min(max(0, headerViewOffsetX), selectHeaderView.contentSize.width - selectHeaderView.frame.size.width)
        selectHeaderView.contentOffset = CGPoint(x: headerViewOffsetX, y: 0)
        selectHeaderView.setDisabledButtonWithButtonIndex(Int(idx))
        loadControllerViewByIndex(Int(idx))
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    private func loadControllerViewByIndex(index: Int) {
        let showingVc = childControllers[index]
        debugPrint(#function, showingVc.title, showingVc.isViewLoaded())
        guard !showingVc.isViewLoaded() else { return }
        showingVc.categoryTitle = selectHeaderView.selectedTitle
        showingVc.view.frame = CGRect(origin: CGPoint(x: CGFloat(index) * contentScrollView.frame.size.width, y: 0), size: contentScrollView.frame.size)
        contentScrollView.addSubview(showingVc.tableView)
    }
    
    private func loadControllerView() {
        let index = contentScrollView.contentOffset.x / contentScrollView.frame.size.width
        loadControllerViewByIndex(Int(index))
    }
}