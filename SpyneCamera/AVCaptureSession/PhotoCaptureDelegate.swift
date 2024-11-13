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
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        print("init: PhotoCaptureDelegate")
    }
    
    deinit {
        print("deinit: PhotoCaptureDelegate")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("AVCapturePhotoCaptureDelegate: Unable to capture photo: \(error)")
            completion(nil)
            return
        }
        
        if let photoData = photo.fileDataRepresentation(), let capturedPhoto = UIImage(data: photoData) {
            completion(capturedPhoto)
        } else {
            print("AVCapturePhotoCaptureDelegate: PhotoData error.")
        }
    }
}
