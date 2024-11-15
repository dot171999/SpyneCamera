//
//  NetworkService.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import Foundation

protocol NetworkProtocol {
    func uploadTask(with request: URLRequest, taskID: String) async -> Result<Data, NetworkError>
}

class NetworkService: NetworkProtocol {
    private let sessionTimeoutInSeconds: TimeInterval = 10
    private weak var sessionDelegate: URLSessionDelegate?
    
    private var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = sessionTimeoutInSeconds
        let session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: .main)
        return session
    }
    
    init(sessionDelegate: URLSessionDelegate? = nil) {
        self.sessionDelegate = sessionDelegate
        print("init: NetworkService")
    }
    
    deinit {
        print("deinit: NetworkService")
    }
    
    func uploadTask(with request: URLRequest, taskID: String = UUID().uuidString) async -> Result<Data, NetworkError> {
        let session = self.session
        do {
            let data: Data, response: URLResponse
            
            (data, response) = try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: (data, response))
                    }
                }
                
                task.taskDescription = taskID
                task.resume()
                session.finishTasksAndInvalidate()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return .failure(.invalidResponse) }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(.httpsRequestFailed(statusCode: httpResponse.statusCode))
            }
            
            print("NetworkService: Uploaded successfully with taskId: ", taskID)
            return .success(data)
        } catch {
            print("NetworkService error: ", error)
            if (error as? URLError)?.code == .timedOut {
                return .failure(.urlRequestTimeout)
            }
            return .failure(.unknown(error))
        }
    }
}

