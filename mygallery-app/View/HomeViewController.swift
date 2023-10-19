//
//  HomeViewController.swift
//  mygallery-app
//
//  Created by Partha Pratim on 17/10/23.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var noImageText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.imageCollectDataSync.imageDataModel.removeAll()
        //appDelegate.imageCollectDataSync.clearSharedPrefsData()
        self.fatchData()
    }
    
    @objc func dataSyncFromApi(){
        DispatchQueue.main.async(execute: {
            appDelegate.imageCollectDataSync.currentPage = 1
            appDelegate.imageCollectDataSync.imageDataModel.removeAll()
            self.imageCollectionView.refreshControl?.endRefreshing()
            self.fatchData()
            
        })
    }
    
    func fatchData() {
        appDelegate.imageCollectDataSync.fetchData{ [weak self] (data, error) in
            if let data = data {
                DispatchQueue.main.async {
                    appDelegate.imageCollectDataSync.isInternetConnected = true
                    self?.imageCollectionView.refreshControl = UIRefreshControl()
                    self?.imageCollectionView.refreshControl?.addTarget(self, action: #selector(self?.dataSyncFromApi), for: .valueChanged)
                    self?.imageCollectionView.reloadData()
                }
            } else if let error = error {
                appDelegate.imageCollectDataSync.isInternetConnected = false
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let data = appDelegate.imageCollectDataSync.fatchCachedData()
                    if(data){
                        print("Total Store Image Count: \(appDelegate.imageCollectDataSync.storePrefsDataModel.count)")
                        self?.imageCollectionView.alpha = 1
                        self?.noImageText.alpha = 0
                        self?.imageCollectionView.reloadData()
                    }else{
                        self?.imageCollectionView.alpha = 0
                        self?.noImageText.alpha = 1
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.imageCollectDataSync.isInternetConnected ? appDelegate.imageCollectDataSync.imageDataModel.count : appDelegate.imageCollectDataSync.storePrefsDataModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        if(appDelegate.imageCollectDataSync.isInternetConnected){
            let info = appDelegate.imageCollectDataSync.imageDataModel[indexPath.row].src?.medium
            let url = URL(string: info!)
            let processor = DownsamplingImageProcessor(size: cell.cellImageView.bounds.size)
                         |> RoundCornerImageProcessor(cornerRadius: 0)
            cell.cellImageView.kf.indicatorType = .activity
            cell.cellImageView.kf.setImage(with: url,options: [
                .processor(processor),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        }else{
            let uniqueFileName = "\(appDelegate.imageCollectDataSync.storePrefsDataModel[indexPath.row].id!)"
            // Get the document directory URL
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName).appendingPathExtension("jpeg")
            print(fileURL);
            // Load the image from the file path
            if let image = UIImage(contentsOfFile: "\(fileURL)") {
                cell.cellImageView.image = image
            } else {
                // Handle the case where the image couldn't be loaded
                print("Failed to load the image from the file path")
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(appDelegate.imageCollectDataSync.isInternetConnected){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let fullImageViewController = storyboard.instantiateViewController(withIdentifier: "FullImageViewController") as? FullImageViewController else {
                print("This means you haven't set your view controller identifier properly.")
                return
            }
            fullImageViewController.urlLink = (appDelegate.imageCollectDataSync.imageDataModel[indexPath.row].src?.large)!
            fullImageViewController.uniqueId = "\((appDelegate.imageCollectDataSync.imageDataModel[indexPath.row].id)!)"
            self.navigationController?.pushViewController(fullImageViewController, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.row == 0){
            return CGSize(width: self.imageCollectionView.frame.size.width, height: 180.0)
        }
        else if(indexPath.row%3 == 0){
            return CGSize(width: self.imageCollectionView.frame.size.width, height: 180.0)
        }else{
            return CGSize(width: (self.imageCollectionView.frame.size.width - 20)/2, height: 180.0)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = imageCollectionView.visibleCells
        if let firstCell = visibleCells.last {
            if let indexPath = imageCollectionView.indexPath(for: firstCell){
                if(appDelegate.imageCollectDataSync.isInternetConnected){
                    if (indexPath.row >= (appDelegate.imageCollectDataSync.imageDataModel.count - 10)){
                        if(appDelegate.imageCollectDataSync.currentPage == 1){
                            appDelegate.imageCollectDataSync.cachedImage()
                        }
                        appDelegate.imageCollectDataSync.currentPage = appDelegate.imageCollectDataSync.currentPage + 1
                        
                        self.fatchData()
                    }
                }
            }
        }
    }
}

