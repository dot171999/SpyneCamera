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
        print("init: CaptureSessionManager")
    }

    deinit {
        print("deinit: CaptureSessionManager")
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
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureVideoDataOutput.setSampleBufferDelegate(videoBufferDelgate, queue: DispatchQueue(label: "captureVideoDataOutput.Queue"))
        
        guard captureSession.canAddOutput(captureVideoDataOutput) else { return false }
        captureSession.addOutput(captureVideoDataOutput)
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

