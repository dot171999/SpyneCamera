//
//  LocalizedError.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 13/11/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case httpsRequestFailed(statusCode: Int)
    case urlRequestTimeout
    case invalidResponse
    case unknown(_ error: Error)
    
    var errorDescription: String? {
        switch self {
        case .httpsRequestFailed(let statusCode):
            return "The HTTP request failed with status code \(statusCode)."
        case .urlRequestTimeout:
            return "The request timed out. Please check your internet connection and try again."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

enum CaptureSessionError: LocalizedError {
    case sessionNotConfigured
    case alreadyConfigured
    case cameraNotFound
    case unableToAddCaptureDevice
    case unableToCreateInputFromCaptureDevice(Error)
    case unableToAddCaptureVideoDataOutput
    case unableToAddCapturePhotoOutput
    
    var errorDescription: String? {
        switch self {
        case .sessionNotConfigured:
            return "The capture session is not configured."
        case .alreadyConfigured:
            return "The capture session is already configured."
        case .cameraNotFound:
            return "No camera was found on the device."
        case .unableToAddCaptureDevice:
            return "Failed to add the capture device to the session."
        case .unableToCreateInputFromCaptureDevice(let underlyingError):
            return "Unable to create input from capture device. \(underlyingError.localizedDescription)"
        case .unableToAddCaptureVideoDataOutput:
            return "Failed to add video data output to the capture session."
        case .unableToAddCapturePhotoOutput:
            return "Failed to add photo output to the capture session."
        }
    }
}

enum PhotoCaptureError: LocalizedError {
    case error(Error)
    case unableToConvertDataToUIImage
    
    var errorDescription: String? {
        switch self {
        case .error(let error):
            return "An error occurred while capturing the photo: \(error.localizedDescription)"
        case .unableToConvertDataToUIImage:
            return "Unable to convert the captured data to an image. Please try again."
        }
    }
}

enum VideoDataOutputError: LocalizedError {
    case sampleToImageBuffer
    case ciToCgImage
    
    var errorDescription: String? {
        switch self {
        case .sampleToImageBuffer:
            return "Failed to convert the sample buffer to an image buffer."
        case .ciToCgImage:
            return "Failed to convert the CIImage to a CGImage."
        }
    }
}

enum PhotoManagerError: LocalizedError {
    case convertingUIImageToJpegData
    case generatingPathUrl
    case loadingPhotoData
    
    var errorDescription: String? {
        switch self {
        case .convertingUIImageToJpegData:
            return "Failed to convert UIImage to JPEG data."
        case .generatingPathUrl:
            return "Unable to generate a valid file path URL."
        case .loadingPhotoData:
            return "Failed to load photo data."
        }
    }
}

enum RealmError: LocalizedError {
    case unabelToAddObject(Error)
    case unableToWriteUpdates(Error)
}

enum DataFileManagerError: LocalizedError {
    case unableToWriteData(Error)
    
    var errorDescription: String? {
        switch self {
        case .unableToWriteData(let error):
            return "Unable to write data to url file path. \(error.localizedDescription)"
        }
    }
}
