//
//  View.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 15/11/24.
//

import Foundation
import SwiftUI

extension View {
    func toast(_ toastManager: ToastManager) -> some View {
        modifier(ToastModifier(toastManager: toastManager))
    }
}
