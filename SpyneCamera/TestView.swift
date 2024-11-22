//
//  TestView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

@Observable class InVM {
    var int = 10
    
    init() {
        temp()
    }
    
    func temp() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            int = Int.random(in: 0..<1000000)
            //temp()
        }
    }
}

@Observable class VM {
    var inVM: InVM
    
    init(inVM: InVM = InVM()) {
        self.inVM = inVM
    }
    
    func getInt() -> Int {
        let a = inVM.int
        return a
    }
}

@Observable class VM2 {
    var a = 10
    var temp: Int {
        return a
    }
    
    init() {
        Task {
            try? await Task.sleep(for: .seconds(4))
            self.a = 30
        }
    }
}

struct TestView: View {
    @State var temp = false
    
    var body: some View {
        VStack(spacing: 20) {
            if temp {
                Rectangle()
                    .frame(width: 200, height: 100)
                    .foregroundStyle(.red)
                    .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
            }
            Spacer()
            Button("Btn") {
                withAnimation {
                    temp.toggle()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct TestView2: View {
    let int: Int
    var body: some View {
        Text("\(int)")
    }
}

#Preview {
    TestView()
}
