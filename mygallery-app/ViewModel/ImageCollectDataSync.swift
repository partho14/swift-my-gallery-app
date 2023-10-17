//
//  ImageCollectDataSync.swift
//  mygallery-app
//
//  Created by Partha Pratim on 17/10/23.
//
import UIKit
import Alamofire

class ImageCollectDataSync: NSObject{
    
    var collectionImage: [String]? = []
    var imageDataModel: [Photo] = [Photo]()
    var firstStoreDataModel: [Photo] = [Photo]()
    var imageDataModel2: DataModel?
    
    var is_running : Bool = false
    var currentPage : Int = 1
    
    static let sharedInstance: ImageCollectDataSync = {
        let instance = ImageCollectDataSync()
        return instance
    }()
    
    override init() {
        super.init()
        is_running = false
    }
    
    func alamofireApiRequest() async{

        let url = await URL(string: appDelegate.constants.baseUrl)
        let headers: HTTPHeaders = [
            "Authorization": "eD6fknb6Sp36dUxvnNxlCIZRN4bXsXIVXq4FPxf3bvir7mlnO34qtJUs"
        ]
        
        let parameters: Parameters = [
            "page": currentPage,
            "per_page": "50",
        ]

        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(url!, method: .get,parameters: parameters, headers: headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        do {
            let data = try JSONDecoder().decode(DataModel.self, from: apiRequest.data!)
            Task{
                imageDataModel2 = data
                firstStoreDataModel.removeAll()
                firstStoreDataModel = (imageDataModel2?.photos)!
                self.currentPage = (imageDataModel2?.page)!
                self.imageDataModel.append(contentsOf: firstStoreDataModel)
                //imageDataModel.app = (imageDataModel2?.photos)!
               // await appDelegate.mainViewController?.collectionView.reloadData()
            }
        } catch {
            print("error")
        }
    }
}
