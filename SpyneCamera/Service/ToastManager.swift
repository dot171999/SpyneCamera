//
//  ToastManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 15/11/24.
//

import Foundation
import SwiftUI

@Observable class ToastManager {
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
    func nextToast() async {
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

struct ToastModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if toastManager.showToast {
                Text(toastManager.message)
                    .padding()
                    .background(colorScheme == .dark ? .black.opacity(0.95) : .white.opacity(0.95))
                    .clipShape(.rect(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? .white.opacity(1) : .black.opacity(1), lineWidth: 1)
                    }
                    .padding()
                    .zIndex(1)
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
            }
        }
        .animation(.easeIn, value: toastManager.showToast)
    }
}


