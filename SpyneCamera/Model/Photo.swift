//
//  Photo.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import RealmSwift

class Photo: Object, Identifiable {
    @Persisted var nameWithExtension: String
    @Persisted var urlPath: String
    @Persisted var captureDate: Date
    @Persisted var isUploaded: Bool = false
}
