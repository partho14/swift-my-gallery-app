//
//  FullImageViewController.swift
//  mygallery-app
//
//  Created by Partha Pratim on 18/10/23.
//

import UIKit
import Kingfisher

class FullImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    var urlLink: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 0.25
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        let url = URL(string: urlLink)
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 0)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,options: [
            .processor(processor),
            .transition(.fade(1)),
            .cacheOriginalImage])
        mainView.addSubview(scrollView)
        mainView.addSubview(backView!)
        mainView.addSubview(shareView!)
        mainView.addSubview(deleteView!)
        
    }
    
    func viewForZoomingInScrollView(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    @IBAction func downloadBtnPressed(_ sender: Any) {
        
    }
    @IBAction func shareBtnPressed(_ sender: Any) {
        
    }
}

