//
//  FileManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 14/11/24.
//

import Foundation

class DataFileManager {
    func writeData(_ data: Data, atPath pathURL: URL) throws {
        do {
            try data.write(to: pathURL)
        } catch {
            throw DataFileManagerError.unableToWriteData(error)
        }
    }
    
    func generatePathUrl(forFileName name: String, fileExtension: String, in directory: FileManager.SearchPathDirectory) -> URL? {
        return FileManager.default.urls(for: directory, in: .userDomainMask).first?.appendingPathComponent(name).appendingPathExtension(fileExtension)
    }
}
