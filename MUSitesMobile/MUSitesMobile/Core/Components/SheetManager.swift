//
//  SheetManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/2/24.
//

import Foundation

final class SheetManager: ObservableObject {
    
    enum Action {
        case na
        case present
        case dismiss
    }
    
    @Published private(set) var action: Action = .na
    
    func present() {
        // return if sheet is already presented
        guard !action.isPresented else { return }
        self.action = .present
    }
    
    func dismiss() {
        self.action = .dismiss
    }
}

extension SheetManager.Action {
    // isPresented if Action is .present
    var isPresented: Bool { self == .present }
}
