//
//  DataTypes.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 16/11/24.
//

import Foundation

enum Tab: String, CaseIterable {
    case photoGallery = "Photo Gallery"
    case camera = "Camera"
}

enum APIEndpoint {
    case upload
    
    var path: String {
        switch self {
        case .upload:
            return "api/upload"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum HTTPHeaderField: String, Hashable {
    case contentType = "Content-Type"
    case host = "Host"
    case contentLength = "Content-Length"
    case contentDisposition = "Content-Disposition"
}

enum MIMEType {
    case multiPart(boundary: String)
    case jpgImage
    case none
    
    var stringValue: String {
        switch self {
        case .multiPart(let boundary):
            return "multipart/form-data; boundary=\(boundary)"
        case .jpgImage:
            return "image/jpeg"
        case .none:
            return ""
        }
    }
}
