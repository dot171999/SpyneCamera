//
//  PhotoCaptureDelegate.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import AVFoundation
import PhotosUI

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<UIImage, PhotoCaptureError>) -> Void
    
    init(completion: @escaping (_ result: Result<UIImage, PhotoCaptureError>) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            completion(.failure(.error(error)))
            return
        }
    
        if let photoData = photo.fileDataRepresentation(), let capturedPhoto = UIImage(data: photoData) {
            completion(.success(capturedPhoto))
        } else {
            completion(.failure(.unableToConvertDataToUIImage))
        }
    }
}
