//
//  PhotoDTO.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 12/11/24.
//

import Foundation

struct PhotoDTO {
    let name: String
    let urlPathString: String
    let captureDate: Date
    
    init(from photo: Photo) {
        self.name = photo.name
        self.urlPathString = photo.urlPathString
        self.captureDate = photo.captureDate
    }
}
