//
//  TPCWelfareCollectionViewCell.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/3.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCWelfareCollectionViewCell: UICollectionViewCell {
    var imageURLString: String? {
        didSet {
            let _ = imageURLString.flatMap{ NSURL(string: $0) }.flatMap{
                contentImageView.kf_setImageWithURL($0, placeholderImage: UIImage(), optionsInfo: [.Transition(.Fade(0.5))])
            }
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension TPCWelfareCollectionViewCell: NTTansitionWaterfallGridViewProtocol {
    func snapShotForTransition() -> UIImageView! {
        guard contentImageView.image != nil else { return UIImageView() }
        let snapShotView = UIImageView(image: contentImageView.image)
        snapShotView.frame = contentImageView.frame
        snapShotView.contentMode = UIViewContentMode.ScaleAspectFill
        snapShotView.clipsToBounds = true
        return snapShotView
    }
}
