//
//  ComputersSectionView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/15/24.
//
/*
import SwiftUI

struct ComputersSectionView: View {
    @Binding var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
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
 /**/*/
