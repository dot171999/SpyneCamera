//
//  API.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 13/11/24.
//

import Foundation

struct API {
    static let baseUrl: URL = URL(string: "https://www.clippr.ai")!
    
    static func urlForEndpoint(_ endpoint: APIEndpoint) -> URL {
        return baseUrl.appending(path: endpoint.path)
    }
}

struct UrlRequestBuilder {
    static func buildRequest(url: URL, method: HTTPMethod, mimeType: MIMEType = .none, body: Data? = nil, headers: [HTTPHeaderField: String]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(url.host ?? "", forHTTPHeaderField: HTTPHeaderField.host.rawValue)
        request.setValue(mimeType.stringValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        if let body {
            request.httpBody = body
            request.setValue("\(body.count)", forHTTPHeaderField: HTTPHeaderField.contentLength.rawValue)
        }
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key.rawValue)
            }
        }
        
        return request
    }
    
    static func createHttpBody(mimeType: MIMEType, fileName: String, field: String, data: Data, boundary: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        
        body.append("\(HTTPHeaderField.contentDisposition.rawValue): form-data; name=\"\(field)\"; filename=\"\(fileName)\"\r\n")
        body.append("\(HTTPHeaderField.contentType.rawValue): \(mimeType.stringValue)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        return body
    }
}
