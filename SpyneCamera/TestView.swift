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

struct TestView: View {
    var vm = VM()
    var body: some View {
        TestView2(int: vm.getInt())
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
