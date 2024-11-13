//
//  Photo.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import RealmSwift

class Photo: Object, Identifiable {
    @Persisted(primaryKey: true) var name: String
    @Persisted var urlPathString: String
    @Persisted var captureDate: Date
    @Persisted var isUploaded: Bool = false
    
}
