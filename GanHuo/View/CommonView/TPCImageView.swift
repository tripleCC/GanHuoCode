//
//  TPCImageView.swift
//  TPCPageScrollView
//
//  Created by tripleCC on 15/11/25.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import SDWebImage
import DACircularProgress

class TPCImageView: UIView {
    var imageMode: UIViewContentMode = UIViewContentMode.ScaleAspectFit {
        didSet {
            imageView.contentMode = imageMode
        }
    }
    var oneTapAction: (() -> ())?
    var image: UIImage? {
        return imageView.image
    }
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var progressView: DALabeledCircularProgressView!
    var imageURLString: String! {
        didSet {
            guard imageURLString != oldValue else { return }
            resetSubviews()
            imageView.sd_setImageWithURL(NSURL(string: imageURLString), placeholderImage: UIImage(), options: SDWebImageOptions.RetryFailed, progress: { (receivedSize, expectedSize) -> Void in
                guard CGFloat(receivedSize) / CGFloat(expectedSize) > 0.009 else {
                    self.progressView.progressLabel.text = "0.00"
                    self.progressView.progress = 0
                    return
                }
                
                self.progressView.setProgress(CGFloat(receivedSize) / CGFloat(expectedSize), animated: true)
                self.progressView.progressLabel.text = String(format:"%.2f", self.progressView.progress)
                if receivedSize / expectedSize >= 1 {
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.progressView.alpha = 0
                    })
                }
                }) { (image, error, cacheType, imageURL) -> Void in
                    self.adjustImageViewFrameByImage(image)
                    self.progressView.alpha = 0
            }
        }
    }
    private func adjustImageViewFrameByImage(image: UIImage?) {
        if let image = image {
            if imageView.contentMode == UIViewContentMode.ScaleAspectFit || imageView.contentMode == UIViewContentMode.Center{
                imageView.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                let xScale = self.bounds.size.width / image.size.width;
                let yScale = self.bounds.size.height / image.size.height;
                let minScale = min(xScale, yScale);
                imageView.bounds = CGRect(x: 0, y: 0, width: imageView.bounds.size.width * minScale, height: imageView.bounds.size.height * minScale);
            } else {
                imageView.frame = bounds
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private func resetSubviews() {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
        imageView.transform = CGAffineTransformIdentity
        progressView.alpha = 1
        progressView.progress = 0
        progressView.progressLabel.text = "0.00"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    private func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = bounds
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.blackColor()
        addSubview(scrollView)
        
        imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.addSubview(imageView)
        
        let oneTap = UITapGestureRecognizer(target: self, action: "oneTap")
        oneTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        oneTap.requireGestureRecognizerToFail(doubleTap)
        
        progressView = DALabeledCircularProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        progressView.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        progressView.roundedCorners = Int(true)
        progressView.progressLabel.font = UIFont.systemFontOfSize(10)
        progressView.progressLabel.textColor = UIColor.whiteColor()
        addSubview(progressView)
    }
    
    func doubleTap(gesture: UIGestureRecognizer) {
        debugPrint(__FUNCTION__)
        if scrollView.zoomScale == 1 {
            let point = gesture.locationInView(gesture.view)
            let width = bounds.width / scrollView.maximumZoomScale
            let height = bounds.height / scrollView.maximumZoomScale
            scrollView.zoomToRect(CGRect(x: point.x - width * 0.5, y: point.y - height * 0.5, width: width, height: height), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func oneTap() {
        debugPrint(__FUNCTION__)
        oneTapAction?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let boundsSize = bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.width) * 0.5
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.height) * 0.5
        } else {
            frameToCenter.origin.y = 0
        }
        if !CGRectEqualToRect(imageView.frame, frameToCenter) {
            imageView.frame = frameToCenter
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TPCImageView: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}