//
//  ExpandedPhotoView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import SwiftUI

struct ExpandedPhotoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var isShowingDescriptionSheet: Bool = false
    @State var isHiddenDescButton: Bool = false
    private let photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(colorScheme == .dark ? .black : .white)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                if let image  = UIImage(contentsOfFile: photo.urlPathString) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .containerRelativeFrame(.vertical)
                }
#if targetEnvironment(simulator)
                DummyImage(["Image", "Image1", "Image2"].randomElement()!)
#endif
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .bottom)
            if !isHiddenDescButton {
                ImageDescrptionButton()
            }
        }
#if targetEnvironment(macCatalyst)
        .overlay(alignment: .topLeading, content: {
            DismissButton()
        })
#endif
        .sheet(isPresented: $isShowingDescriptionSheet, content: {
            ImageDescriptionSheet()
        })
        .onTapGesture {
            isHiddenDescButton.toggle()
        }
        .presentationDragIndicator(.visible)
        .animation(.snappy, value: isHiddenDescButton)
    }
}

extension ExpandedPhotoView {
    @ViewBuilder
    func ImageDescriptionSheet() -> some View {
        List {
            Text("Name: \(photo.name)")
            Text("Date: \(photo.captureDate.formatted(.dateTime.month(.wide).year().hour(.defaultDigits(amPM: .abbreviated)).minute()))")
            Text("Upload Status: \(photo.isUploaded)")
            Text("Storage location: \(photo.urlPathString)")
        }
        .presentationDetents([.medium, .height(200)])
    }
    
    @ViewBuilder
    func ImageDescrptionButton() -> some View {
        Button {
            isShowingDescriptionSheet.toggle()
        } label: {
            Image(systemName: "info.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .symbolRenderingMode(.multicolor)
                .shadow(color: .black, radius: 20, x: 0, y: 5)
        }
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
        .zIndex(1) // To make the removal transition work
        .padding(.bottom)
    }
    
    @ViewBuilder
    func DismissButton() -> some View {
        Button(action: {
            dismiss()
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .shadow(color: .black, radius: 5, x: 0, y: 1)
        })
        .padding()
    }
    
    @ViewBuilder
    func DummyImage(_ image: String) -> some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .containerRelativeFrame(.vertical)
    }
}

#Preview {
    ExpandedPhotoView(photo: Photo())
}
