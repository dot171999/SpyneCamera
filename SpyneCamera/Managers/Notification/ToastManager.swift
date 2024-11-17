//
//  ToastManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 15/11/24.
//

import Foundation
import SwiftUI

protocol ToastManagerProtocol {
    var message: String { get }
    var defaultDurationInSeconds: Int { get }
    var showToast: Bool { get }
    func show(message: String, durationInSeconds: Int?)
}

extension ToastManagerProtocol {
    func show(message: String) {
        show(message: message, durationInSeconds: nil)
    }
}

@Observable class ToastManager: ToastManagerProtocol {
    static let shared = ToastManager()
    
    private(set) var message: String = ""
    private(set) var defaultDurationInSeconds: Int = 2
    private(set) var showToast: Bool = false
    
    private var toastQueue: [(message: String, duration: Int?)] = []
    private var isShowing: Bool = false
    
    private init() {}
    
    func show(message: String, durationInSeconds: Int? = nil) {
        toastQueue.append((message: message, duration: durationInSeconds))
        
        guard !isShowing else { return }
        isShowing = true
        
        Task {
            await nextToast()
            await MainActor.run {
                isShowing = false
            }
        }
    }
    
    @MainActor
    private func nextToast() async {
        guard !toastQueue.isEmpty else {
            return
        }
        let toast = toastQueue.removeFirst()
        
        message = toast.message
        showToast = true
        do {
            try await Task.sleep(for: .seconds(toast.duration == nil ? defaultDurationInSeconds :  toast.duration!))
        } catch {
            print(error)
        }
        showToast = false
        await nextToast()
    }
}


