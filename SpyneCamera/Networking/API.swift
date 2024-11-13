//
//  API.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 13/11/24.
//

import Foundation

struct API {
    static let host: String = "www.clippr.ai"
    static let baseUrl: URL = URL(string: "https://\(host)")!
    
    enum Endpoint: String {
        case upload = "upload"
    }
    
    static func urlForEndpoint(_ endpoint: Endpoint) -> URL {
        switch endpoint {
        case .upload:
            return API.baseUrl.appending(path: Endpoint.upload.rawValue)
        }
    }
}

enum HTTPHeaderField: String, Hashable {
    case contentType = "Content-Type"
    case host = "Host"
    case contentLength = "Content-Length"
    case contentDisposition = "Content-Disposition"
}

enum HTTPMethod: String {
    case post = "POST"
}
