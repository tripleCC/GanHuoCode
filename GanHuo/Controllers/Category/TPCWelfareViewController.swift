//
//  TPCWelfareViewController.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/3.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCWelfareViewController: UIViewController {
    private let reuseIndentifier = "reuseIndentifier"
    private var colletionView: TPCCollectionView!
    var dataSource: TPCCategoryDataSource!
    
    override func loadView() {
        let layout = TPCCollectionViewWaterflowLayout()
        layout.delegate = self
        view = TPCCollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colletionView = view as! TPCCollectionView
        colletionView.backgroundColor = UIColor.whiteColor()
        dataSource = TPCCategoryDataSource(collectionView: colletionView, reuseIdentifier: reuseIndentifier)
        dataSource.delegate = self
        dataSource.categoryTitle = "福利"
        colletionView.dataSource = dataSource
        colletionView.registerNib(UINib(nibName: String(TPCWelfareCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIndentifier)
    }
}

extension TPCWelfareViewController: TPCCollectionViewWaterflowLayoutDelegate {
    func waterflowLayout(waterflowLayout: TPCCollectionViewWaterflowLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        return 0
    }
    
    func commonConfigurationForWaterflowLayout() -> (rowMargin: CGFloat?, columnMargin: CGFloat?, columnCount: Int?, edgeInsets: UIEdgeInsets?) {
        return (nil, nil, nil, nil)
    }
}

extension TPCWelfareViewController: TPCCategoryDataSourceDelegate {
    func renderCell(cell: UIView, withObject object: AnyObject?) {
        if let o = object as? GanHuoObject {
            let cell = cell as! TPCWelfareCollectionViewCell
            cell.imageURLString = o.url
        }

    }
}