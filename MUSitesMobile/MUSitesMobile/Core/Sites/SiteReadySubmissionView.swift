//
//  SiteReadySubmissionView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/11/24.
//

import SwiftUI

struct SiteReadySurveyView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                
                // Computers Section
                Section(header: Text("Computers")) {
                    // PCs
                    Section(header: Text("PCs")) {
                        TextField("Enter PC count", value: $viewModel.pcCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    // MACs
                    Section(header: Text("MACs")) {
                        TextField("Enter MAC count", value: $viewModel.macCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    // Scanners
                    Section(header: Text("Scanners")) {
                        TextField("Enter Scanner count", value: $viewModel.scannerCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    // Chairs
                    Section(header: Text("Chairs")) {
                        TextField("Enter Chair count", value: $viewModel.chairCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    // Logged Into All Computers
                    Section(header: Text("Logged Into All Computers")) {
                        Toggle(isOn: $viewModel.loggedIntoAllComputers) {
                            Text(viewModel.loggedIntoAllComputers ? "Yes" : "No")
                        }
                        if !viewModel.loggedIntoAllComputers {
                            VStack {
                                Stepper(value: $viewModel.failedToLoginCount, in: 0...100, step: 1) {
                                    Text("How many computers failed to login? \(viewModel.failedToLoginCount)")
                                }
                                
                                if viewModel.failedToLoginCount > 0 {
                                    ForEach(0..<viewModel.failedToLoginCount, id: \.self) { index in
                                        ComputerFailureView(computerFailure: $viewModel.computerFailures[index])
                                    }
                                }
                            }
                        }
                    }
                    
                    // Cleaned All Computers
                    Section(header: Text("Cleaned All Computers")) {
                        Toggle(isOn: $viewModel.cleanedAllComputers) {
                            Text(viewModel.cleanedAllComputers ? "Yes" : "No")
                        }
                    }
                    
                    // Cleaned All Stations
                    if viewModel.cleanedAllComputers {
                        Section(header: Text("Cleaned All Stations")) {
                            Toggle(isOn: $viewModel.cleanedAllStations) {
                                Text(viewModel.cleanedAllStations ? "Yes" : "No")
                            }
                        }
                    }
                    
                    // Do any computer labels need replacement?
                    if viewModel.cleanedAllStations && viewModel.cleanedAllComputers {
                        Section(header: Text("Do any computer labels need replacement?")) {
                            Toggle(isOn: $viewModel.needLabelReplacement) {
                                Text(viewModel.needLabelReplacement ? "Yes" : "No")
                            }
                            if viewModel.needLabelReplacement {
                                VStack {
                                    Stepper(value: $viewModel.labelsToReplace, in: 0...100, step: 1) {
                                        Text("How many labels need to be replaced? \(viewModel.labelsToReplace)")
                                    }
                                    
                                    if viewModel.labelsToReplace > 0 {
                                        ForEach(0..<viewModel.labelsToReplace, id: \.self) { index in
                                            ComputerLabelReplacementView(labelIndex: index, computerLabel: $viewModel.computerLabels[index])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Printers Section
                Section(header: Text("Printers")) {
                    // How many B&W printers are there?
                    Section(header: Text("How many B&W printers are there?")) {
                        TextField("Enter B&W printer count", value: $viewModel.bwPrinterCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    // How many color printers are there?
                    Section(header: Text("How many color printers are there?")) {
                        TextField("Enter color printer count", value: $viewModel.colorPrinterCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    // Top off all printers with paper
                    if viewModel.showPrinterRelatedSections {
                        Section(header: Text("Top off all printers with paper")) {
                            Toggle(isOn: $viewModel.topOffPrintersWithPaper) {
                                Text(viewModel.topOffPrintersWithPaper ? "Yes" : "No")
                            }
                        }
                    }
                    
                    // Do any printer labels need replacement?
                    if viewModel.showPrinterRelatedSections && viewModel.topOffPrintersWithPaper {
                        Section(header: Text("Do any printer labels need replacement?")) {
                            Toggle(isOn: $viewModel.needPrinterLabelReplacement) {
                                Text(viewModel.needPrinterLabelReplacement ? "Yes" : "No")
                            }
                            if viewModel.needPrinterLabelReplacement {
                                VStack {
                                    Stepper(value: $viewModel.printerLabelsToReplace, in: 0...100, step: 1) {
                                        Text("How many printer labels need to be replaced? \(viewModel.printerLabelsToReplace)")
                                    }
                                    
                                    if viewModel.printerLabelsToReplace > 0 {
                                        ForEach(0..<viewModel.printerLabelsToReplace, id: \.self) { index in
                                            PrinterLabelReplacementView(labelIndex: index, printerLabel: $viewModel.printerLabels[index])
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Did you test print a page for each printer?
                        Section(header: Text("Did you test print a page for each printer?")) {
                            Toggle(isOn: $viewModel.testPrintedForPrinters) {
                                Text(viewModel.testPrintedForPrinters ? "Yes" : "No")
                            }
                        }
                        
                        // Did you wipe down each printer?
                        Section(header: Text("Did you wipe down each printer?")) {
                            Toggle(isOn: $viewModel.wipedDownPrinters) {
                                Text(viewModel.wipedDownPrinters ? "Yes" : "No")
                            }
                        }
                    }
                }
                
                // Add your next section here
            }
            .navigationTitle("Site Ready Survey")
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct ComputerFailureView: View {
    @Binding var computerFailure: SiteReadySurveyView.ViewModel.ComputerFailure
    
    var body: some View {
        HStack {
            TextField("Computer Name", text: $computerFailure.computerName)
            TextField("Ticket Number", text: $computerFailure.ticketNumber)
        }
    }
}

struct ComputerLabelReplacementView: View {
    var labelIndex: Int
    @Binding var computerLabel: String
    
    var body: some View {
        HStack {
            Text("Label \(labelIndex + 1):")
            TextField("Enter Label Name", text: $computerLabel)
        }
    }
}

struct PrinterLabelReplacementView: View {
    var labelIndex: Int
    @Binding var printerLabel: String
    
    var body: some View {
        HStack {
            Text("Label \(labelIndex + 1):")
            TextField("Enter Label Name", text: $printerLabel)
        }
    }
}

struct SiteReadySurveyView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SiteReadySurveyView.ViewModel()
        viewModel.failedToLoginCount = 2 // Set an appropriate value for testing
        
        return SiteReadySurveyView()
            .environmentObject(viewModel)
    }
}

extension SiteReadySurveyView {
    class ViewModel: ObservableObject {
        @Published var pcCount: Int = 0
        @Published var macCount: Int = 0
        @Published var scannerCount: Int = 0
        @Published var chairCount: Int = 0
        @Published var loggedIntoAllComputers: Bool = false
        @Published var failedToLoginCount: Int = 0 {
            didSet {
                // Ensure that the computerFailures array matches the count
                while computerFailures.count < failedToLoginCount {
                    computerFailures.append(ComputerFailure())
                }
            }
        }
        @Published var computerFailures: [ComputerFailure] = []
        @Published var cleanedAllComputers: Bool = false
        @Published var cleanedAllStations: Bool = false
        @Published var needLabelReplacement: Bool = false
        @Published var labelsToReplace: Int = 0 {
            didSet {
                // Ensure that the computerLabels array matches the count
                while computerLabels.count < labelsToReplace {
                    computerLabels.append("")
                }
            }
        }
        @Published var computerLabels: [String] = []
        @Published var needPrinterLabelReplacement: Bool = false
        @Published var printerLabelsToReplace: Int = 0 {
            didSet {
                // Ensure that the printerLabels array matches the count
                while printerLabels.count < printerLabelsToReplace {
                    printerLabels.append("")
                }
            }
        }
        @Published var printerLabels: [String] = []
        @Published var bwPrinterCount: Int = 0 {
            didSet {
                // Update the computed property value
                updateShowPrinterRelatedSections()
            }
        }
        @Published var colorPrinterCount: Int = 0 {
            didSet {
                // Update the computed property value
                updateShowPrinterRelatedSections()
            }
        }
        @Published var topOffPrintersWithPaper: Bool = false
        @Published var testPrintedForPrinters: Bool = false
        @Published var wipedDownPrinters: Bool = false
        
        // Computed property to determine if printer-related sections should be shown
        @Published var showPrinterRelatedSections: Bool = false
        
        // Function to update the showPrinterRelatedSections flag
        private func updateShowPrinterRelatedSections() {
            showPrinterRelatedSections = bwPrinterCount > 0 || colorPrinterCount > 0
        }
       
        struct ComputerFailure {
            var computerName: String = ""
            var ticketNumber: String = ""
        }
    }
}
