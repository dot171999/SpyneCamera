//
//  View.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 15/11/24.
//

import Foundation
import SwiftUI

extension View {
    func toast(_ toastManager: ToastManagerProtocol) -> some View {
        modifier(ToastViewModifier(toastManager: toastManager))
    }
}
