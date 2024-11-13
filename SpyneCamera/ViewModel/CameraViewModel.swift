//
//  CameraViewModel.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import RealmSwift
import PhotosUI

@Observable class CameraViewModel {
    private(set) var cameraPreviewFrameImage: UIImage?
    private(set) var capturedImage: UIImage?
    
    private let photoService: PhotoService = PhotoService()
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    init() {
        print("init: CameraViewModel")
    }
    
    deinit {
        print("deinit: CameraViewModel")
    }
    
    @ObservationIgnored lazy private var videoBufferDelgate: VideoDataOutputSampleBufferDelegate = {
        let videoBufferDelgate = VideoDataOutputSampleBufferDelegate(completion: { [unowned self] image in
            guard let image = image else { return }
            self.capturedImage = image
        })
        return videoBufferDelgate
    }()
    
    @ObservationIgnored lazy private var photoCaptureDelegate: PhotoCaptureDelegate = {
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: { [unowned self] image in
            guard let image = image else { return }
            self.cameraPreviewFrameImage = image
            self.photoService.savePhoto(image)
            
        })
        return photoCaptureDelegate
    }()
    
    @ObservationIgnored lazy private(set) var captureSessionManager: CaptureSessionManager = { [unowned self] in
        return CaptureSessionManager(videoBufferDelgate: self.videoBufferDelgate)
    }()
    
    func clickPhoto() {
        Task {
            await captureSessionManager.capturePhoto(photoCaptureDelegate: photoCaptureDelegate)
        }
    }
}
