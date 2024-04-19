//
//  SiteReadySurveyView.swift
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
                ComputersSection(viewModel: viewModel)
                PrintersSection(viewModel: viewModel)
                PostersSection(viewModel: viewModel)
                RoomSection(viewModel: viewModel)
                AdditionalCommentsSection(viewModel: viewModel)
            }
            .navigationTitle("Site Ready Survey")
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct ComputersSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Computers")) {
            // Text prompt section for entering counts
            Text("Please enter the following counts:")
            
            // PC Count TextField
            TextField("Enter PC count", value: $viewModel.pcCount, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            
            // Text prompt section for MAC count
            Text("Enter MAC count:")
            
            // MAC Count TextField
            TextField("Enter MAC count", value: $viewModel.macCount, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            
            // Text prompt section for scanner count
            Text("Enter Scanner count:")
            
            // Scanner Count TextField
            TextField("Enter Scanner count", value: $viewModel.scannerCount, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            
            // Text prompt section for chair count
            Text("Enter Chair count:")
            
            // Chair Count TextField
            TextField("Enter Chair count", value: $viewModel.chairCount, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            
            // What computers are the scanners attached to?
            if viewModel.scannerCount > 0 {
                Section(header: Text("What computers are the scanners attached to?")) {
                    // Implement dropdown of all computers in the site
                    // Allow the user to select multiple computers for each scanner
                }
            }
            
            // Text prompt section for computer label replacement
            Text("Please provide details for computers that failed to login:")
            
            // Number of computers that failed to login
            Stepper(value: $viewModel.failedToLoginCount, in: 0...100, step: 1) {
                Text("How many computers failed to login? \(viewModel.failedToLoginCount)")
            }
            
            // Details for each computer that failed to login
            if viewModel.failedToLoginCount > 0 {
                ForEach(0..<viewModel.failedToLoginCount, id: \.self) { index in
                    ComputerFailureView(computerFailure: $viewModel.computerFailures[index])
                }
            }
            
            // Logged Into All Computers Section
            Section(header: Text("Logged Into All Computers")) {
                Toggle(isOn: $viewModel.loggedIntoAllComputers) {
                    Text(viewModel.loggedIntoAllComputers ? "Yes" : "No")
                }
            }
            
            // Cleaned All Computers Section
            Section(header: Text("Cleaned All Computers")) {
                Toggle(isOn: $viewModel.cleanedAllComputers) {
                    Text(viewModel.cleanedAllComputers ? "Yes" : "No")
                }
            }
            
            // Cleaned All Stations Section
            Section(header: Text("Cleaned All Stations")) {
                Toggle(isOn: $viewModel.cleanedAllStations) {
                    Text(viewModel.cleanedAllStations ? "Yes" : "No")
                }
            }
        }
    }
}
struct PrintersSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
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
            if viewModel.bwPrinterCount > 0 || viewModel.colorPrinterCount > 0 {
                Section(header: Text("Top off all printers with paper")) {
                    Toggle(isOn: $viewModel.topOffPrintersWithPaper) {
                        Text(viewModel.topOffPrintersWithPaper ? "Yes" : "No")
                    }
                }
                
                // Do any printer labels need replacement?
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
    }
}


struct PostersSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Posters")) {
            // Mission Statement banner
            Picker("Is the Mission Statement banner on the poster board?", selection: $viewModel.missionStatementBanner) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Reserved Board notification
            Picker("Is the Reserved Board notification on the poster board?", selection: $viewModel.reservedBoardNotification) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Cyber Security Poster
            Picker("Is the Cyber Security Poster displayed?", selection: $viewModel.cyberSecurityPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Adaptive Computing Poster
            Picker("Is the Adaptive Computing Poster displayed?", selection: $viewModel.adaptiveComputingPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Print Smart Printing Info Poster
            Picker("Is the Print Smart Printing Info Poster displayed?", selection: $viewModel.printSmartPrintingInfoPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Need Help Poster
            Picker("Is the Need Help Poster displayed?", selection: $viewModel.needHelpPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Active Shooter Poster
            Picker("Is the Active Shooter Poster displayed?", selection: $viewModel.activeShooterPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Emergency Procedures Poster
            Picker("Is the Emergency Procedures Poster displayed?", selection: $viewModel.emergencyProceduresPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Copyright Wrong Poster
            Picker("Is the Copyright Wrong Poster displayed?", selection: $viewModel.copyRightWrongPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // SAS SPSS Poster
            Picker("Is the SAS SPSS Poster displayed?", selection: $viewModel.sasSpssPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // New Adobe CC Login Poster
            Picker("Is the New Adobe CC Login Poster displayed?", selection: $viewModel.newAdobeCcLoginPoster) {
                ForEach([true, false, nil], id: \.self) { option in
                    Text(option == true ? "Yes" : (option == false ? "Yes, but it is in bad condition." : "No"))
                        .tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            Section(header: Text("Sign Holders Outside Room in Good Condition?")) {
                Toggle(isOn: $viewModel.signHoldersGoodCondition) {
                    Text(viewModel.signHoldersGoodCondition ? "Yes" : "No")
                }
                if !viewModel.signHoldersGoodCondition {
                    Text("Description of Issue:")
                    TextField("Enter description", text: $viewModel.signHoldersIssueDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            Section(header: Text("Is the 11x17\" Sign Holder Outside Room in Good Condition?")) {
                Toggle(isOn: $viewModel.signHolders11x17GoodCondition) {
                    Text(viewModel.signHolders11x17GoodCondition ? "Yes" : "No")
                }
                if !viewModel.signHolders11x17GoodCondition {
                    Text("Description of Issue:")
                    TextField("Enter description", text: $viewModel.signHolders11x17IssueDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            Section(header: Text("Have you removed all old weekly calendars?")) {
                Toggle(isOn: $viewModel.removedOldCalendars) {
                    Text(viewModel.removedOldCalendars ? "Yes" : "No")
                }
            }
        }
    }
}
struct RoomSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Room Section")) {
            // Projector and remote working properly?
            Picker("Projector and remote working properly?", selection: $viewModel.projectorWorkingProperly) {
                ForEach(["Yes", "No", "No projector in the room"], id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            
            // Is the clock working?
            Picker("Is the clock working?", selection: $viewModel.clockWorking) {
                ForEach(["Yes", "No", "No clock in the room"], id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            
            // Cleaned whiteboard?
            Toggle(isOn: $viewModel.cleanedWhiteboard) {
                Text(viewModel.cleanedWhiteboard ? "Yes" : "No")
            }
            
            // Updated Inventory
            Toggle(isOn: $viewModel.updatedInventory) {
                Text(viewModel.updatedInventory ? "Yes" : "No")
            }
            
            // Took out recycling?
            Toggle(isOn: $viewModel.tookOutRecycling) {
                Text(viewModel.tookOutRecycling ? "Yes" : "No")
            }
            
            // Any other issues?
            Text("Any other issues?")
            TextField("Enter number", text: $viewModel.otherIssuesCount)
                .keyboardType(.numberPad)
            
            // Issues dropdown
            if let count = Int(viewModel.otherIssuesCount), count > 0 {
                ForEach(0..<count, id: \.self) { index in
                    HStack {
                        TextField("Enter issue", text: $viewModel.otherIssues[index])
                        TextField("Enter ticket number", text: $viewModel.otherIssueTicketNumbers[index])
                    }
                }
            }
        }
    }
}
struct AdditionalCommentsSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Additional Comments")) {
            Text("Any additional comments?")
            TextEditor(text: $viewModel.additionalComments)
                .frame(height: 100)
                .padding(.horizontal)
        }
    }
}

struct ComputerFailureView: View {
    @Binding var computerFailure: String
    
    var body: some View {
        TextField("Enter computer failure description", text: $computerFailure)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

// Subview for displaying computer labels replacement
struct ComputerLabelReplacementView: View {
    var labelIndex: Int
    @Binding var computerLabel: String
    
    var body: some View {
        TextField("Enter label replacement description", text: $computerLabel)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

// Subview for displaying printer labels replacement
struct PrinterLabelReplacementView: View {
    var labelIndex: Int
    @Binding var printerLabel: String
    
    var body: some View {
        TextField("Enter printer label replacement description", text: $printerLabel)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

// ViewModel for managing state
extension SiteReadySurveyView {
    class ViewModel: ObservableObject {
        // Add @Published properties here to track survey data
        @Published var pcCount: Int = 0
        @Published var macCount: Int = 0
        @Published var scannerCount: Int = 0
        @Published var chairCount: Int = 0
        @Published var loggedIntoAllComputers: Bool = false
        @Published var failedToLoginCount: Int = 0 {
            didSet {
                // Ensure that the computerFailures array matches the count
                while computerFailures.count < failedToLoginCount {
                    computerFailures.append("")
                }
            }
        }
        @Published var computerFailures: [String] = []
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
        
        // Add more @Published properties here as needed
        @Published var missionStatementBanner: Bool? = nil
        @Published var reservedBoardNotification: Bool? = nil
        @Published var cyberSecurityPoster: Bool? = nil
        @Published var adaptiveComputingPoster: Bool? = nil
        @Published var printSmartPrintingInfoPoster: Bool? = nil
        @Published var needHelpPoster: Bool? = nil
        @Published var activeShooterPoster: Bool? = nil
        @Published var emergencyProceduresPoster: Bool? = nil
        @Published var copyRightWrongPoster: Bool? = nil
        @Published var sasSpssPoster: Bool? = nil
        @Published var newAdobeCcLoginPoster: Bool? = nil
        @Published var signHoldersGoodCondition: Bool = true
        @Published var signHoldersIssueDescription: String = ""
        @Published var signHolders11x17GoodCondition: Bool = true
        @Published var signHolders11x17IssueDescription: String = ""
        @Published var removedOldCalendars: Bool = false

        
        @Published var projectorWorkingProperly: String = "Yes"
        @Published var clockWorking: String = "Yes"

        @Published var cleanedWhiteboard: Bool = false
        @Published var updatedInventory: Bool = false
        @Published var tookOutRecycling: Bool = false
        @Published var otherIssuesCount: String = "0"
        @Published var otherIssues: [String] = Array(repeating: "", count: 5)
        @Published var otherIssueTicketNumbers: [String] = Array(repeating: "", count: 5)

        
        @Published var additionalComments: String = ""

        // Scanner computers
        @Published var scannerComputers: [String: [String]] = [:] // Scanner ID: [Computer Names]
        
        // Function to update the showPrinterRelatedSections flag
        private func updateShowPrinterRelatedSections() {
            showPrinterRelatedSections = bwPrinterCount > 0 || colorPrinterCount > 0
        }
    }
}
struct SiteReadySurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SiteReadySurveyView()
    }
}
