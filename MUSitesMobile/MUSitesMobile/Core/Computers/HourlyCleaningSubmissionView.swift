//
//  HourlyCleaningSubmissionView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/18/24.
//

import SwiftUI

@MainActor
final class HourlyCleaningViewModel: ObservableObject {
    // Inventory Entry Default Values
    @Published var inventorySite: InventorySite? = nil // will be passed in from the View
//    @Published var issues: [Issue] = []
    @Published var cleanedComputers: [Computer] = [] // this is only ot hold updated levels
}

struct HourlyCleaningView: View {
    // View Model
    @StateObject private var viewModel = ComputersViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HourlyCleaningView()
}
