//
//  ToastViewModifier.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 16/11/24.
//

import SwiftUI

struct ToastViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var toastManager: ToastManagerProtocol
    
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

