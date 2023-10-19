//
//  FullImageDataSync.swift
//  mygallery-app
//
//  Created by Annanovas IT on 19/10/23.
//

import UIKit
import Photos

class FullImageDataSync: NSObject{
    
    var is_running : Bool = false
    
    static let sharedInstance: FullImageDataSync = {
        let instance = FullImageDataSync()
        return instance
    }()
    
    override init() {
        super.init()
        is_running = false
    }
    
    //download function for image download
    func downloadImage(from url: URL, uniqueId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "com.proyojon.mygallery-app", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            // Get the document directory URL
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // Generate a unique file name for the image
            let uniqueFileName = uniqueId
            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName).appendingPathExtension("jpeg")
            
            do {
                try data.write(to: fileURL)
                completion(.success(fileURL))
            } catch let error {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
