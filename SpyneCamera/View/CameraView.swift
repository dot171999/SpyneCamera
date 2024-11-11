//
//  CameraView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI
import AVFoundation
import Foundation
import RealmSwift

@Observable class CameraViewModel {
    var image: UIImage?
    var image2: UIImage?
    
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
    
    @ObservationIgnored lazy var videoBufferDelgate: VideoDataOutputSampleBufferDelegate = {
        let videoBufferDelgate = VideoDataOutputSampleBufferDelegate(completion: { [weak self] image in
            guard let image = image else { return }
            self?.image2 = image
        })
        return videoBufferDelgate
    }()
    
    @ObservationIgnored lazy var photoCaptureDelegate: PhotoCaptureDelegate = {
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: { [weak self] image in
            guard let image = image else { return }
            self?.image = image
            self?.saveImageToDocumentsDirectory(image: image, imageName: UUID().uuidString)
            
        })
        return photoCaptureDelegate
    }()
    
    @ObservationIgnored lazy var captureSessionManager: CaptureSessionManager = { [unowned self] in
        return CaptureSessionManager(videoBufferDelgate: self.videoBufferDelgate)
    }()
    
    func saveToRealm(url: URL, name: String) {
        let photo = Photo()
        photo.captureDate = Date()
        photo.nameWithExtension = name
        photo.urlPath = url.path
        do {
            let realm = try Realm()
            
            // Persist our data with a write
            try realm.write {
                realm.add(photo)
            }
        } catch {
            print("error saving to realm: ", error)
        }
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, imageName: String) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName).appendingPathExtension("jpg") else {
                print("file url not found for doc directory")
                return
            }
            do {
                try data.write(to: fileURL)
                saveToRealm(url: fileURL, name: imageName)
                print("Image saved")
            } catch {
                print("error writing image to documentDic: ", error)
            }
        } else {
            print("unable to load jpeg data from uiimage")
        }
    }
    
    deinit {
        print("007 vm deinit")
    }
    
    func clickPhoto() {
        Task {
            await captureSessionManager.capturePhoto(photoCaptureDelegate: photoCaptureDelegate)
        }
    }

}

struct CameraView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var viewModel = CameraViewModel()
    var body: some View {
        VStack(spacing: 0) {
            CameraPreview(image: viewModel.image2)
            ZStack {
                HStack {
                    GalaryPreview(image: viewModel.image)
                    Spacer()
                }
                ShutterButton {
                    viewModel.clickPhoto()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            print("tsk")
            guard await viewModel.isAuthorized else { return }
            await viewModel.captureSessionManager.configureSession()
            await viewModel.captureSessionManager.startSession()
        }
        .onDisappear {
            print("ondisp")
            Task {
                await viewModel.captureSessionManager.stopSession()
            }
        }
    }
    
    @ViewBuilder
    func CameraPreview(image: UIImage?) -> some View {
        Rectangle()
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
    }
    
    @ViewBuilder
    func GalaryPreview(image: UIImage?) -> some View {
        Rectangle()
            .frame(width: 50, height: 50, alignment: .center)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
    }
    
    @ViewBuilder
    func ShutterButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                        .frame(width: 58, height: 58, alignment: .center)
                )
        }
    }
}

#Preview {
    CameraView()
}
