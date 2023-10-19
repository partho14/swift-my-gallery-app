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
    var uniqueId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(urlLink)
        print(uniqueId)
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
        LoadingIndicatorView.show()
        if let imageUrl = URL(string: urlLink) {
            appDelegate.fullImageDataSync.downloadImage(from: imageUrl, uniqueId: uniqueId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let localFileURL):
                        print("Image downloaded and saved at \(localFileURL)")
                        LoadingIndicatorView.hide()
                        self.showToast(message: "Image downloaded and saved Successfully", seconds: 2, error: false)
                        
                    case .failure(let error):
                        print("Error downloading image: \(error)")
                        LoadingIndicatorView.hide()
                        self.showToast(message: "Download Failed, Please try again", seconds: 2, error: true)
                    }
                }
            }
        }
    }
    @IBAction func shareBtnPressed(_ sender: Any) {
        LoadingIndicatorView.show()
        if let imageUrl = URL(string: urlLink) {
            appDelegate.fullImageDataSync.downloadImage(from: imageUrl, uniqueId: uniqueId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let localFileURL):
                        //if download successful
                        print("Image downloaded and saved at \(localFileURL)")
                        self.shareImage(from: localFileURL)
                        
                    case .failure(let error):
                        //if download failed
                        print("Error downloading image: \(error)")
                        LoadingIndicatorView.hide()
                        self.showToast(message: "Something went wrong", seconds: 2, error: true)
                    }
                }
            }
        }
    }
    
    //this function for shared image
    func shareImage(from localFileURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [localFileURL], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [
                .postToTwitter,
                .postToWeibo,
                .message,
                .print,
                .copyToPasteboard,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .postToVimeo,
                .postToTencentWeibo,
                .airDrop,
                .openInIBooks
            ]
            activityViewController.isModalInPresentation = true
            activityViewController.popoverPresentationController?.sourceView = self.view
            LoadingIndicatorView.hide()
            self.present(activityViewController, animated: true, completion: nil)
        }
    
    //show toast purpose
    func showToast(message : String, seconds: Double, error: Bool){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            alert.view.backgroundColor = error ? .red : .blue
            alert.view.alpha = 0.75
            alert.view.layer.cornerRadius = 15
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                alert.dismiss(animated: true)
            }
        }

}
