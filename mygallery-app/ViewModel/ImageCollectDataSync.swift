//
//  ImageCollectDataSync.swift
//  mygallery-app
//
//  Created by Partha Pratim on 17/10/23.
//
import Foundation
import UIKit
import Alamofire

class ImageCollectDataSync: NSObject{
    
    var collectionImage: [String]? = []
    var imageDataModel: [Photo] = [Photo]()
    var firstStoreDataModel: [Photo] = [Photo]()
    var storePrefsDataModel: [Photo] = [Photo]()
    var imageDataModel2: DataModel?
    var cachedDataModel: DataModel?
    
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
                if(currentPage == 1){
                    await clearSharedPrefsData()
                    UserDefaults.standard.set(data, forKey: "apiResponse")
                    for value in firstStoreDataModel{
                        if let imageUrl = URL(string: (value.src?.medium)!) {
                            await appDelegate.fullImageDataSync.downloadImage(from: imageUrl, uniqueId: "\(value.id)") { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let localFileURL):
                                        //if download successful
                                        print("Image downloaded and saved at \(localFileURL)")
                                        
                                    case .failure(let error):
                                        //if download failed
                                        print("Error downloading image: \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("error")
        }
    }
    
    func fatchCachedData(){
        imageDataModel2 = UserDefaults.standard.auth(forKey: "apiResponse")
        storePrefsDataModel.removeAll()
        storePrefsDataModel = (imageDataModel2?.photos)!
        print("===================Shared Prefs Response===============")
        print(storePrefsDataModel)
    }
    
    func clearSharedPrefsData() async{
        imageDataModel2 = UserDefaults.standard.auth(forKey: "apiResponse")
        storePrefsDataModel.removeAll()
        storePrefsDataModel = (imageDataModel2?.photos)!
        for value in storePrefsDataModel{
            let uniqueFileName = "\(value.id!)"
            // Get the document directory URL
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName).appendingPathExtension("jpeg")
            do {
                
                let fileManager = FileManager.default
                try fileManager.removeItem(at: URL(fileURLWithPath: "\(fileURL)"))
        
                print("Cache folder cleared.")
            } catch {
                print("Error clearing cache: \(error)")
            }
        
        }
    }
}

extension UserDefaults {
    func auth(forKey defaultName: String) -> DataModel? {
        guard let data = data(forKey: defaultName) else { return nil }
        do {
            return try JSONDecoder().decode(DataModel.self, from: data)
        } catch { print(error); return nil }
    }

    func set(_ value: DataModel, forKey defaultName: String) {
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: defaultName)
    }
}
