//
//  CaptureSessionManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import Foundation
import AVFoundation
import PhotosUI

protocol CaptureSession {
    func configureSession() async throws
    func startSession() async -> Bool
    func stopSession() async
    func capturePhoto(photoCaptureDelegate: AVCapturePhotoCaptureDelegate) async throws
}

actor CaptureSessionManager: CaptureSession {
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var captureDeviceInput: AVCaptureDeviceInput?
    private let capturePhotoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private let captureVideoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
    private weak var videoBufferDelgate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private var isSessionConfiguredSuccessfully: Bool = false
    private(set) var error: CaptureSessionError?
    
    init(videoBufferDelgate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.videoBufferDelgate = videoBufferDelgate
        print("init: CaptureSessionManager")
    }

    deinit {
        print("deinit: CaptureSessionManager")
    }
    
    func configureSession() throws {
        guard !isSessionConfiguredSuccessfully else { return }
        
        captureSession.sessionPreset = .photo
        do {
            try setupCaptureDeviceInput()
            try setupCapturePhotoOutput()
            try setupVideoOutput()
            isSessionConfiguredSuccessfully = true
        } catch let error as CaptureSessionError {
            self.error = error
            throw error
        }
    }
    
    @discardableResult
    func startSession() -> Bool {
        guard isSessionConfiguredSuccessfully, !captureSession.isRunning else { return false }
        captureSession.startRunning()
        return true
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
    
    private func setupCaptureDeviceInput() throws {
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
            throw CaptureSessionError.cameraNotFound
        }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
                captureDeviceInput = deviceInput
            } else {
                throw CaptureSessionError.unableToAddCaptureDevice
            }
        } catch {
            throw CaptureSessionError.unableToCreateInputFromCaptureDevice(error)
        }
    }
    
    private func setupVideoOutput() throws {
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureVideoDataOutput.setSampleBufferDelegate(videoBufferDelgate, queue: DispatchQueue(label: "captureVideoDataOutput.Queue"))
        
        guard captureSession.canAddOutput(captureVideoDataOutput) else {
            throw CaptureSessionError.unableToAddCaptureVideoDataOutput
        }
        captureSession.addOutput(captureVideoDataOutput)
    }

    private func setupCapturePhotoOutput() throws {
        guard captureSession.canAddOutput(capturePhotoOutput) else {
            throw CaptureSessionError.unableToAddCapturePhotoOutput
        }
            
        captureSession.addOutput(capturePhotoOutput)
    }
    
    func capturePhoto(photoCaptureDelegate: AVCapturePhotoCaptureDelegate) throws {
        guard isSessionConfiguredSuccessfully else { throw CaptureSessionError.sessionNotConfigured }
        let capturePhotoSettings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: capturePhotoSettings, delegate: photoCaptureDelegate)
    }
}

