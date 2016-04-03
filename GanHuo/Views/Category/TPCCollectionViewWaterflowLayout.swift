//
//  TPCCollectionViewWaterflowLayout.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/3.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

protocol TPCCollectionViewWaterflowLayoutDelegate {
    func commonConfigurationForWaterflowLayout() -> (rowMargin: CGFloat?, columnMargin: CGFloat?, columnCount: Int?, edgeInsets: UIEdgeInsets?)
    func waterflowLayout(waterflowLayout: TPCCollectionViewWaterflowLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat
}

class TPCCollectionViewWaterflowLayout: UICollectionViewLayout {
    var delegate: TPCCollectionViewWaterflowLayoutDelegate?
    struct TPCCollectionViewWaterflowLayoutStatic {
        static let kDefaultColumnCount = Int(2)
        static let kDefaultColumnMargin = CGFloat(10)
        static let kDefaultRawMargin = CGFloat(10)
        static let kDefaultEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    private var attributes = [UICollectionViewLayoutAttributes]()
    private var columnsHeight = [CGFloat]()
    private var contentHeight = CGFloat()
    
    private var rowMargin: CGFloat {
        return delegate?.commonConfigurationForWaterflowLayout().rowMargin ?? TPCCollectionViewWaterflowLayoutStatic.kDefaultRawMargin
    }
    private var columnMargin: CGFloat {
        return delegate?.commonConfigurationForWaterflowLayout().columnMargin ?? TPCCollectionViewWaterflowLayoutStatic.kDefaultColumnMargin
    }
    private var columnCount: Int {
        return delegate?.commonConfigurationForWaterflowLayout().columnCount ?? TPCCollectionViewWaterflowLayoutStatic.kDefaultColumnCount
    }
    private var edgeInsets: UIEdgeInsets {
        return delegate?.commonConfigurationForWaterflowLayout().edgeInsets ?? TPCCollectionViewWaterflowLayoutStatic.kDefaultEdgeInsets
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        contentHeight = 0
        columnsHeight.removeAll()
        for _ in 0 ..< columnCount {
            columnsHeight.append(edgeInsets.top)
        }
        
        attributes.removeAll()
        if let count = collectionView?.numberOfItemsInSection(0) {
            for i in 0 ..< count {
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
                if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
                    attributes.append(attribute)
                }
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        if let collectionWidth = collectionView?.frame.width {
            var width = collectionWidth - edgeInsets.left - edgeInsets.right
            width -= CGFloat(columnCount - 1) * columnMargin / CGFloat(columnCount)
            let height = delegate?.waterflowLayout(self, heightForItemAtIndex: indexPath.item, itemWidth: width) ?? 0
            
            var destColumn = 0
            var minColumnHeight = columnsHeight.first
            for i in 0 ..< columnCount {
                let columnHeight = columnsHeight[i]
                if minColumnHeight > columnHeight {
                    minColumnHeight = columnHeight
                    destColumn = i
                }
            }
            let x = edgeInsets.left + CGFloat(destColumn) * (width + columnMargin)
            var y: CGFloat = minColumnHeight ?? 0
            if y != edgeInsets.top { y += rowMargin }
            attribute.frame = CGRect(x: x, y: y, width: width, height: height)
            columnsHeight[destColumn] = attribute.frame.maxY
            
            contentHeight = max(columnsHeight[destColumn], contentHeight)
        }
        return attribute
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: 0, height: contentHeight + edgeInsets.bottom)
    }
}
