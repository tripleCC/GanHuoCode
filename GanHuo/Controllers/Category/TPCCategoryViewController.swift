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
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var selectHeaderView: TPCSelectHeaderView! {
        didSet {
            selectHeaderView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildController()
        navigationBarType = .Line
        setupNav()
    }
    
    private func setupNav() {
        let segmentView = UISegmentedControl(items: ["分类", "收藏"])
        segmentView.addTarget(self, action: "segmenViewOnClicked:", forControlEvents: UIControlEvents.ValueChanged)
        segmentView.frame = CGRect(x: 0, y: 0, width: 150, height: 30)
        segmentView.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
        let titleFont = UIFont(name: TPCConfiguration.themeSFontName, size: 13.0)!
        segmentView.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : titleFont], forState: .Selected)
        segmentView.setTitleTextAttributes([NSFontAttributeName : titleFont], forState: .Normal)
        segmentView.selectedSegmentIndex = 0
        navigationItem.titleView = segmentView
    }
    
    func segmenViewOnClicked(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        favoriteView.hidden = sender.selectedSegmentIndex != 1
        contentScrollView.hidden = !favoriteView.hidden
        headerContainerView.hidden = contentScrollView.hidden
    }

    private func setupChildController() {
        TPCConfiguration.allCategories.filter{ $0 != "福利" }.forEach {
            let subCategoryVc = TPCSubCategoryViewController()
            subCategoryVc.navigationItem.title = $0
            self.addChildViewController(subCategoryVc)
        }
        contentScrollView.contentSize.width = CGFloat(childViewControllers.count) * TPCScreenWidth
        automaticallyAdjustsScrollViewInsets = false
        selectHeaderView.titles = childViewControllers.map{ $0.navigationItem.title! }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectHeaderView.setupSubviewsFrame()
        scrollViewDidEndScrollingAnimation(contentScrollView)
    }
    
    @IBAction func arrowButtonOnClicked(sender: AnyObject) {
        let arrowButton = sender as! UIButton
        let isSelected = arrowButton.selected
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
                arrowButton.imageView!.transform = CGAffineTransformRotate(arrowButton.imageView!.transform, CGFloat(M_PI))
//            if isSelected {
//
//            }
            }) { (finished) -> Void in
                
        }
        arrowButton.selected = !arrowButton.selected
    }
}

extension TPCCategoryViewController : TPCSelectHeaderViewDelegate {
    func selectHeaderView(view: TPCSelectHeaderView, didSelectButton button: UIButton) {
        let contentOffsetX = button.frame.origin.x / button.frame.size.width * contentScrollView.frame.size.width
        contentScrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
        print(contentOffsetX)
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
        let showingVc = childViewControllers[index] as! TPCSubCategoryViewController
        guard !showingVc.isViewLoaded() else { return }
        showingVc.categoryTitle = selectHeaderView.selectedTitle
        showingVc.view.frame = CGRect(origin: CGPoint(x: CGFloat(index) * contentScrollView.frame.size.width, y: 0), size: contentScrollView.frame.size)
        contentScrollView.addSubview(showingVc.tableView)
    }
}