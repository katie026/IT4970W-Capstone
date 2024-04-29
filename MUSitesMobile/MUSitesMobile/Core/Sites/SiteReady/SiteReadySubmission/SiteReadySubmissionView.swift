//
//  SiteReadySurveyView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/11/24.
//
import SwiftUI
import Firebase

struct SiteReadySurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    let site: Site
//    let userId: String
    @State var user: AuthDataResultModel? = nil
    @StateObject var viewModel = ViewModel()
    @State private var showAlert = false

    var body: some View {
        VStack {
            Form {
                ComputersSection(viewModel: viewModel)
                PrintersSection(viewModel: viewModel)
                PostersSection(viewModel: viewModel)
                RoomSection(viewModel: viewModel)
                AdditionalCommentsSection(viewModel: viewModel)
            }
            Spacer()
            Button(action: {
                if let user = user {
                    // Attempt to get the authenticated user and submit the site ready survey data
                    Task {
                        do {
                            let db = Firestore.firestore()
                            
                            // Submitting reported issues
                            await submitReportedIssues(db: db, userId: user.uid) { reportedIssuesUUIDs in
                                // Submitting printer label issues
                                Task {
                                    let printerLabelIssuesUUIDs = await submitPrinterLabelIssues(db: db, userId: user.uid)
                                    // Submitting site ready survey data with reported and printer label issues' UUIDs
                                    try await submitSiteReadySurvey(db: db, reportedIssuesUUIDs: reportedIssuesUUIDs, printerLabelIssuesUUIDs: printerLabelIssuesUUIDs)
                                }
                            }
                            // Submitting label issues
                            Task {
                                await submitLabelIssues(db: db)
                            }
                        } catch {
                            print("Error submitting site ready survey data: \(error)")
                        }
                    }
                } else {
                    print("User is not logged in/authenticated.")
                }
            }) {
                // Button content
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 8)
                    .padding(.top, 3)
            }
        }
        .navigationTitle("Site Ready Survey")
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            Text("Back")
//        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Submission Successful"), message: Text("Your survey has been successfully submitted."), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            Task {
                self.user = try AuthenticationManager.shared.getAuthenticatedUser()
            }
        }
        .toolbar { // this should work like it does on the other submission views, but ti doesn't here...
            ToolbarItem(placement: .keyboard) {
                Button("Done") { // for numpad
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
    

    private func submitSiteReadySurvey(db: Firestore, reportedIssuesUUIDs: [String], printerLabelIssuesUUIDs: [String]) async throws {
        do {
            if let user = user {
                let documentId = try await SiteReadyManager.shared.getNewSiteReadyId()
                let docRef = db.collection("site_ready_entries").document(documentId)
                let timestamp = Timestamp(date: Date())
                
                var data: [String: Any] = [
                    SiteReady.CodingKeys.bwPrinterCount.rawValue: viewModel.bwPrinterCount,
                    SiteReady.CodingKeys.chairCount.rawValue: viewModel.chairCount,
                    // Include reported and printer label issues' UUIDs in the "issues" array
                    SiteReady.CodingKeys.issues.rawValue: reportedIssuesUUIDs + printerLabelIssuesUUIDs,
                    // Other fields...
                    // "computing_site": site.id,
                    SiteReady.CodingKeys.comments.rawValue: viewModel.additionalComments,
                    // "id": documentId,
                    // "mac_count": viewModel.macCount,
                    // "missing_chairs": viewModel.missingChairs,
                    // "pc_count": viewModel.pcCount,
                    // "user": userId,
                    // "timestamp": timestamp
                ]
                
                // Add other data to the dictionary if needed
                
                data["computing_site"] = site.id
                data["id"] = documentId
                data["mac_count"] = viewModel.macCount
                data["missing_chairs"] = viewModel.missingChairs
                data["pc_count"] = viewModel.pcCount
                data["user"] = user.uid
                data["timestamp"] = timestamp
                
                // Write data to Firestore
                docRef.setData(data) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Site ready survey data successfully written!")
                        // Show the alert
                        showAlert = true
                    }
                }
            }
        } catch {
            print("Error submitting site ready: \(error)")
        }
    }

    private func submitReportedIssues(db: Firestore, userId: String, completion: @escaping ([String]) -> Void) async {
        do {
            var reportedIssuesUUIDs: [String] = []
            
            let group = DispatchGroup()
            
            for index in 0..<viewModel.failedToLoginCount {
                group.enter()
                let documentId = try await IssueManager.shared.getNewIssueId()
                let docRef = db.collection("reported_issues").document(documentId)
                let timestamp = Timestamp(date: Date())
                
                let data: [String: Any] = [
                    Issue.CodingKeys.description.rawValue: viewModel.computerFailures[index],
                    Issue.CodingKeys.id.rawValue: documentId,
                    Issue.CodingKeys.issueTypeId.rawValue: "GxFGSkbDySZmdkCFExt9",
                    Issue.CodingKeys.reportId.rawValue: viewModel.reportId,
                    Issue.CodingKeys.reportType.rawValue: "site_ready",
                    Issue.CodingKeys.resolved.rawValue: false,
                    Issue.CodingKeys.siteId.rawValue: site.id,
                    Issue.CodingKeys.ticket.rawValue: viewModel.failedLoginTicketNumbers[index],
                    Issue.CodingKeys.dateCreated.rawValue: timestamp,
                    Issue.CodingKeys.userAssigned.rawValue: "",
                    Issue.CodingKeys.userSubmitted.rawValue: userId
                ]
                
                // Write data to Firestore
                docRef.setData(data) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Reported issue \(index + 1) successfully written!")
                        reportedIssuesUUIDs.append(documentId)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(reportedIssuesUUIDs)
            }
        } catch {
            print("Error submitting issues: \(error)")
            completion([])
        }
    }
    private func submitPrinterLabelIssues(db: Firestore, userId: String) async -> [String] {
        do {
            var reportedIssuesUUIDs: [String] = []
            
            let group = DispatchGroup()
            
            for index in 0..<viewModel.printerLabelsToReplace {
                group.enter()
                let documentId = try await IssueManager.shared.getNewIssueId()
                let docRef = db.collection("reported_issues").document(documentId)
                let timestamp = Timestamp(date: Date())
                
                let data: [String: Any] = [
                    Issue.CodingKeys.description.rawValue: viewModel.printerLabels[index],
                    Issue.CodingKeys.id.rawValue: documentId,
                    Issue.CodingKeys.issueTypeId.rawValue: "PrinterLabelIssue", // Assuming a constant issue type for printer label issues
                    Issue.CodingKeys.reportId.rawValue: viewModel.reportId ?? "", // Ensure reportId is available in the ViewModel
                    Issue.CodingKeys.reportType.rawValue: "site_ready",
                    Issue.CodingKeys.resolved.rawValue: false,
                    Issue.CodingKeys.siteId.rawValue: site.id,
                    Issue.CodingKeys.dateCreated.rawValue: timestamp,
                    Issue.CodingKeys.userAssigned.rawValue: "",
                    Issue.CodingKeys.userSubmitted.rawValue: userId
                ]
                
                // Write data to Firestore
                docRef.setData(data) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Reported printer label issue \(index + 1) successfully written!")
                        reportedIssuesUUIDs.append(documentId)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // No completion handler needed for async function, just return the UUIDs
            }
            return reportedIssuesUUIDs
        } catch {
            print("Error submitting label issues: \(error)")
            return []
        }
    }

    private func submitLabelIssues(db: Firestore) async {
        // Assuming you have access to viewModel.labelIssues array
        for labelIssue in viewModel.labelIssues {
            do {
                // Submit each label issue to Firestore
                try await IssueManager.shared.createIssue(issue: labelIssue)
            } catch {
                print("Error creating label issue: \(error)")
            }
        }
    }
}

struct ComputersSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Computers")) {
            // Text prompt section for entering counts
            Text("Enter PC count:")
            
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
            
            // Number of computers that failed to login
            Stepper(value: $viewModel.failedToLoginCount, in: 0...100, step: 1) {
                Text("How many computers failed to login? \(viewModel.failedToLoginCount)")
            }
            
            // Details for each computer that failed to login
            if viewModel.failedToLoginCount > 0 {
                ForEach(0..<viewModel.failedToLoginCount, id: \.self) { index in
                    VStack {
                        TextField("Enter computer failure description", text: $viewModel.computerFailures[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Enter ticket number", text: Binding(
                            get: {
                                return viewModel.failedLoginTicketNumbers[index] == 0 ? "" : "\(viewModel.failedLoginTicketNumbers[index])"
                            },
                            set: { newValue in
                                viewModel.failedLoginTicketNumbers[index] = Int(newValue) ?? 0
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
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
        Section(header: Text("Room")) {
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
                Text("Cleaned whiteboard?")
            }

            Toggle(isOn: $viewModel.updatedInventory) {
                Text("Updated Inventory")
            }

            Toggle(isOn: $viewModel.tookOutRecycling) {
                Text("Took out recycling?")
            }
            
            // Any other issues?
            Stepper(value: $viewModel.otherIssuesCount, in: 0...100, step: 1) {
                Text("How many other issues? \(viewModel.otherIssuesCount)")
            }
            
            // Issues dropdown
            if viewModel.otherIssuesCount > 0 {
                ForEach(0..<viewModel.otherIssuesCount, id: \.self) { index in
                    HStack {
                        TextField("Enter issue", text: $viewModel.otherIssues[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Enter ticket number", text: $viewModel.otherIssueTicketNumbers[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                // Ensure that the failedLoginTicketNumbers array matches the count
                while failedLoginTicketNumbers.count < failedToLoginCount {
                    failedLoginTicketNumbers.append(0)
                }
            }
        }
        @Published var failedLoginTicketNumbers: [Int] = []
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
        var missingChairs: Int = 0
        
        @Published var projectorWorkingProperly: String = "Yes"
        @Published var clockWorking: String = "Yes"

        @Published var cleanedWhiteboard: Bool = false
        @Published var updatedInventory: Bool = false
        @Published var tookOutRecycling: Bool = false
        @Published var otherIssuesCount: Int = 0 {
            didSet {
                // Ensure that the otherIssues and otherIssueTicketNumbers arrays match the count
                while otherIssues.count < otherIssuesCount {
                    otherIssues.append("")
                    otherIssueTicketNumbers.append("")
                }
            }
        }
        @Published var otherIssues: [String] = []
        @Published var otherIssueTicketNumbers: [String] = []
        @Published var labelIssues: [Issue] = []
        @Published var reportId: String = ""
        


        @Published var additionalComments: String = ""

        // Scanner computers
        @Published var scannerComputers: [String: [String]] = [:] // Scanner ID: [Computer Names]
        
        // Function to update the showPrinterRelatedSections flag
        private func updateShowPrinterRelatedSections() {
            showPrinterRelatedSections = bwPrinterCount > 0 || colorPrinterCount > 0
        }
    }
}

//struct SiteReadySurveyView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Provide a placeholder site.id for preview purposes
//        let placeholderSiteId = "6tYFeMv41IXzfXkwbbh6"
//        return SiteReadySurveyView(siteId: placeholderSiteId, userId: "UP4qMGuLhCP3qHvT5tfNnZlzH4h1")
//    }
//}

#Preview {
    NavigationView {
        SiteReadySurveyView(site: Site(
            id: "BezlCe1ospf57zMdop2z",
            name: "Bluford",
            buildingId: "SvK0cIKPNTGCReVCw7Ln",
            nearestInventoryId: "345",
            chairCounts: [ChairCount(count: 3, type: "physics_black")],
            siteTypeId: "Y3GyB3xhDxKg2CuQcXAA",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: true,
            namePatternMac: "CLARK-MAC-##",
            namePatternPc: "CLARK-PC-##",
            namePatternPrinter: "Clark Printer ##",
            calendarName: "cornell-hall-5-lab"
        ))
    }
}

// Errors
enum SiteReadyError: Error {
    case userNotAuth
}
