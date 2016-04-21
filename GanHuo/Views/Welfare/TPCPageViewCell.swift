//
//  TPCPageViewCell.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/16.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCPageViewCell: UICollectionViewCell, NTTansitionWaterfallGridViewProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView!

    var imageURLString: String! {
        didSet {
            imageView.alpha = CGFloat(TPCConfiguration.imageAlpha)
            imageView.kf_setImageWithURL(NSURL(string: imageURLString)!, placeholderImage: UIImage(), optionsInfo: []) { (image, error, cacheType, imageURL) in
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let image = imageView.image {
            if image.size.width == 0 { return }
            
            let imageHeight = image.size.height * TPCScreenWidth /  image.size.width
            imageView.frame = CGRectMake(0, 0, TPCScreenWidth, imageHeight)
            imageView.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        }
    }
    
    func snapShotForTransition() -> UIImageView! {
        guard imageView.image != nil else { return UIImageView() }
        let snapShotView = UIImageView(image: imageView.image)
        snapShotView.frame = imageView!.frame
        snapShotView.alpha = CGFloat(TPCConfiguration.imageAlpha)
        snapShotView.contentMode = UIViewContentMode.ScaleAspectFill
        snapShotView.clipsToBounds = true
        return snapShotView
    }
}
