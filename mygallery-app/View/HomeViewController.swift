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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.imageCollectDataSync.imageDataModel.removeAll()
        self.fatchData()
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl?.addTarget(self, action: #selector(dataSyncFromApi), for: .valueChanged)
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
        Task {
            await appDelegate.imageCollectDataSync.alamofireApiRequest()
            self.imageCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.imageCollectDataSync.imageDataModel.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
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
        return cell
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
                print(indexPath.row)
                if (indexPath.row >= (appDelegate.imageCollectDataSync.imageDataModel.count - 10)){
                    appDelegate.imageCollectDataSync.currentPage = appDelegate.imageCollectDataSync.currentPage + 1
                    self.fatchData()
                }
            }
        }
    }
}
