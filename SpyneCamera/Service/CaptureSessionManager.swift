//
//  CaptureSessionManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import Foundation
import AVFoundation
import PhotosUI

actor CaptureSessionManager {
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var captureDeviceInput: AVCaptureDeviceInput?
    private let capturePhotoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private let captureVideoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var observer: NSObjectProtocol?
    private var isSessionConfigured: Bool = false
    private var configuredSessionSuccessfully: Bool = false
    private let videoBufferDelgate: AVCaptureVideoDataOutputSampleBufferDelegate
    
    init(videoBufferDelgate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.videoBufferDelgate = videoBufferDelgate
        Task {
            await setup()
        }
    }
    
    deinit {
        print("007 sessionManager deinit")
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func setup() {
        setupObserver()
    }
    
    private func setupObserver() {
        self.observer = NotificationCenter.default.addObserver(forName: .AVCaptureSessionRuntimeError, object: captureSession, queue: nil) { notification in
            if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError {
                print("CaptureSessionManager: Runtime error: \(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    func configureSession() -> Bool {
        guard !isSessionConfigured else { return false }
        isSessionConfigured = true
        
        captureSession.sessionPreset = .photo
        guard setupCaptureDeviceInput() else { return false }
        guard setupCapturePhotoOutput() else { return false }
        guard setupVideoOutput() else { return false }
        configuredSessionSuccessfully = true
        return true
    }
    
    @discardableResult
    func startSession() -> Bool {
        guard configuredSessionSuccessfully, !captureSession.isRunning else { return false }
        captureSession.startRunning()
        print("CaptureSessionManager: session started")
        return true
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
    
    private func setupCaptureDeviceInput() ->  Bool {
        let camera: AVCaptureDevice?
        
        if #available(macCatalyst 17.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.external, .builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            camera = discoverySession.devices.first
        } else {
            camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        
        guard let camera else {
            print("CaptureSessionManager: CaptureDevice not available.")
            return false
        }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
                captureDeviceInput = deviceInput
            } else {
                print("CaptureSessionManager: Could not add captureDeviceInput to the captureSession.")
                return false
            }
        } catch {
            print("CaptureSessionManager: Could not captureDeviceInput from camera, error: ", error)
            return false
        }
        return true
    }
    
    private func setupVideoOutput() -> Bool {
        // Set pixel format to avoid format mismatches
//        let videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
//        captureVideoDataOutput.videoSettings = videoSettings
        // Add the video output and configure settings
       
        guard captureSession.canAddOutput(captureVideoDataOutput) else { return false }
        captureSession.addOutput(captureVideoDataOutput)
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureVideoDataOutput.setSampleBufferDelegate(videoBufferDelgate, queue: DispatchQueue(label: "videoQueue"))
        
    
        return true
    }

    private func setupCapturePhotoOutput() -> Bool {
        guard captureSession.canAddOutput(capturePhotoOutput) else {
            print("CaptureSessionManager: Could not add capturePhotoOutput to the captureSession.")
            return false
        }
            
        captureSession.addOutput(capturePhotoOutput)
        return true
    }
    
    func capturePhoto(photoCaptureDelegate: PhotoCaptureDelegate) {
        let capturePhotoSettings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: capturePhotoSettings, delegate: photoCaptureDelegate)
    }
}



class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        print("delegate init")
    }
    deinit {
        print("007 delegate deinit")
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("AVCapturePhotoCaptureDelegate: Unable to capture photo: \(error)")
            completion(nil)
            return
        }
        
        if let photoData = photo.fileDataRepresentation(), let capturedPhoto = UIImage(data: photoData) {
            //saveImageToGallery(capturedImage)
            print("about to set photto")
            completion(capturedPhoto)
        } else {
            print("AVCapturePhotoCaptureDelegate: PhotoData error.")
        }
    }
}

class VideoDataOutputSampleBufferDelegate : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        print("video buff delegate init")
    }
    deinit {
        print("007 video buff delegate deinit")
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Convert CMSampleBuffer to CIImage
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        
        // Create a CIContext for rendering the CIImage to a CGImage
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: true])
        
        // Check if the CIImage can be rendered to a CGImage
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            // Convert CGImage to UIImage
            let uiImage = UIImage(cgImage: cgImage)
            
            // Pass the UIImage to the completion handler
            completion(uiImage)
        } else {
            print("Failed to create CGImage from CIImage")
        }
    }
    
}
