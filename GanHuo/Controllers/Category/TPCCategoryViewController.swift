//
//  TPCCategoryViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/1.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCategoryViewController: UIViewController {

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var selectHeaderView: TPCSelectHeaderView! {
        didSet {
            selectHeaderView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildController()
    }

    private func setupChildController() {
        TPCConfiguration.allCategories.forEach {
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
        showingVc.view.frame = CGRect(origin: CGPoint(x: CGFloat(index) * contentScrollView.frame.size.width, y: 0), size: contentScrollView.frame.size)
        contentScrollView.addSubview(showingVc.tableView)
    }
}