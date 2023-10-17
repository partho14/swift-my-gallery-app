//
//  Constants.swift
//  mygallery-app
//
//  Created by Partha Pratim on 17/10/23.
//

import Foundation

class Constants: NSObject{
    
    static let sharedInstance: Constants = {
        let instance = Constants()
        return instance
    }()
    
    
    var baseUrl: String = "https://api.pexels.com/v1/curated"
    var apiKey: String = "eD6fknb6Sp36dUxvnNxlCIZRN4bXsXIVXq4FPxf3bvir7mlnO34qtJUs"
}
