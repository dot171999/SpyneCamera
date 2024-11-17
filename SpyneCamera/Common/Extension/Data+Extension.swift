//
//  Data.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 13/11/24.
//

import Foundation

// Extension to help with appending strings to Data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
