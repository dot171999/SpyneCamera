//
//  NetworkService.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import Foundation

enum NetworkManagerError: Error {
    case httpsRequestFailed(statusCode: Int)
    case urlRequestTimeout
    case invalidResponse
    case unknown(_ error: Error)
}

protocol NetworkProtocol {
    func uploadTask(with request: URLRequest, for bodyData: Data, taskID: String) async -> Result<Data, NetworkManagerError>
}

class NetworkService: NetworkProtocol {
    private let sessionTimeoutInSeconds: TimeInterval = 30
    private let session: URLSession
  
    init(session: URLSession = URLSession(configuration: .default)) {
        let configuration = session.configuration
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = sessionTimeoutInSeconds
        self.session = session
        print("init: NetworkService")
    }
    
    deinit {
        print("deinit: NetworkService")
    }
    
    func uploadTask(with request: URLRequest, for bodyData: Data, taskID: String = UUID().uuidString) async -> Result<Data, NetworkManagerError> {
        do {
            let data: Data, response: URLResponse
            
            (data, response) = try await withCheckedThrowingContinuation { continuation in
                let task = session.uploadTask(with: request, from: nil) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: (data, response))
                    }
                }
                
                task.taskDescription = taskID
                task.resume()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return .failure(.invalidResponse) }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(.httpsRequestFailed(statusCode: httpResponse.statusCode))
            }
            
            print("Uploaded successfully with taskId: ", taskID)
            return .success(data)
        } catch {
            print("nm: ", error)
            if (error as? URLError)?.code == .timedOut {
                return .failure(.urlRequestTimeout)
            }
            return .failure(.unknown(error))
        }
    }
    
    func post(photoData: Data, forPhoto photo: PhotoDTO) async -> Result<Data, NetworkManagerError> {
        var request = URLRequest(url: API.urlForEndpoint(.upload))
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(photo.name)", forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        request.setValue(API.host, forHTTPHeaderField: HTTPHeaderField.host.rawValue)
        
        let body = createHttpBody(for: photo, with: photoData)
       
        //request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: HTTPHeaderField.contentLength.rawValue)
        
        do {
            let data: Data
            let response: URLResponse
            
             (data, response) = try await withCheckedThrowingContinuation { continuation in
                let task = session.uploadTask(with: request, from: body) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: (data, response))
                    }
                }
                
                 task.taskDescription = photo.name
                task.resume()
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return .failure(.httpsRequestFailed(statusCode: 0))
            }
            
            print("image uploaded successfully")
            print(String(data: data, encoding: .utf8)!)
            return .success(data)
        } catch {
            print("nm: ", error)
            if (error as? URLError)?.code == .timedOut {
                return .failure(.urlRequestTimeout)
            }
            return .failure(.unknown(error))
        }
    }
}

extension NetworkService {
    func createHttpBody(for photo: PhotoDTO, with data: Data) -> Data {
        let boundary = "\(photo.name)"
        var body = Data()
        
        let fileName = photo.name
        let mimeType = "image/jpeg"
        let fileFieldName = "image"
        
        body.append("--\(boundary)\r\n")
        
        body.append("\(HTTPHeaderField.contentDisposition): form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n")
        //body.append("\(HTTPHeaderField.contentType): \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
}
