//
//  VideoDataOutputSampleBufferDelegate.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import AVFoundation
import PhotosUI

class VideoDataOutputSampleBufferDelegate : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let completion: (Result<UIImage, VideoDataOutputError>) -> Void
    
    init(completion: @escaping (_ result: Result<UIImage, VideoDataOutputError>) -> Void) {
        self.completion = completion
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { 
            completion(.failure(.sampleToImageBuffer))
            return
        }
        
        // Convert CMSampleBuffer to CIImage
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        
        // Create a CIContext for rendering the CIImage to a CGImage
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: true])
        
        // Check if the CIImage can be rendered to a CGImage
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            // Convert CGImage to UIImage
            let uiImage = UIImage(cgImage: cgImage)
            
            // Pass the UIImage to the completion handler
            completion(.success(uiImage))
        } else {
            completion(.failure(.ciToCgImage))
        }
    }
}
