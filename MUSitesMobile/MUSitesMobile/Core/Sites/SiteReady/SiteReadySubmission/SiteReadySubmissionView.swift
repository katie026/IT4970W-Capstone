

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
            header
            Form {
                ComputersSection(viewModel: viewModel)
                PrintersSection(viewModel: viewModel)
                PostersSection(viewModel: viewModel)
                RoomSection(viewModel: viewModel)
                AdditionalCommentsSection(viewModel: viewModel)
            }
            Spacer()
            submitButton
        }
        .navigationTitle("Site Ready Survey")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Submission Successful"), message: Text("Your survey has been successfully submitted."), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            Task {
                self.user = try AuthenticationManager.shared.getAuthenticatedUser()
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") { // for numpad
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
    
    private var header: some View {
        // Subtitle
        HStack {
            Text("\(site.name ?? "N/A")")
                .font(.title2)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
    }
    
    private var submitButton: some View {
        Button(action: {
            if user != nil {
//                printFormData()
                submitForm()
//                // Attempt to get the authenticated user and submit the site ready survey data
//                Task {
//                    let db = Firestore.firestore()
//                    
//                    // Submitting reported issues
//                    await submitReportedIssues(db: db, userId: user.uid) { reportedIssuesUUIDs in
//                        // Submitting printer label issues
//                        Task {
//                            let printerLabelIssuesUUIDs = await submitPrinterLabelIssues(db: db, userId: user.uid)
//                            // Submitting site ready survey data with reported and printer label issues' UUIDs
//                            try await submitSiteReadySurvey(db: db, reportedIssuesUUIDs: reportedIssuesUUIDs, printerLabelIssuesUUIDs: printerLabelIssuesUUIDs, otherIssues: viewModel.otherIssues)
//                        }
//                    }
//                    // Submitting label issues
//                    Task {
//                        await submitLabelIssues(db: db)
//                    }
//                }
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
    
    private func submitForm() {
        printFormData()
        Task {
            do {
                if let user = user {
                    //TODO: update all computers .lastCleaned
                    
                    // create empty SiteCaptain document and get id
                    let siteReadyId = try await SiteReadyManager.shared.getNewSiteReadyId()
                    
                    // POSTERS
                    var posterReports: [PosterReport] = []
                    posterReports.append(PosterReport(posterType: "missionStatementBanner", status: viewModel.missionStatementBanner))
                    posterReports.append(PosterReport(posterType: "reservedBoardNotification", status: viewModel.reservedBoardNotification))
                    posterReports.append(PosterReport(posterType: "cyberSecurityPoster", status: viewModel.cyberSecurityPoster))
                    posterReports.append(PosterReport(posterType: "adaptiveComputingPoster", status: viewModel.adaptiveComputingPoster))
                    posterReports.append(PosterReport(posterType: "printSmartPrintingInfoPoster", status: viewModel.printSmartPrintingInfoPoster))
                    posterReports.append(PosterReport(posterType: "needHelpPoster", status: viewModel.needHelpPoster))
                    posterReports.append(PosterReport(posterType: "activeShooterPoster", status: viewModel.activeShooterPoster))
                    posterReports.append(PosterReport(posterType: "emergencyProceduresPoster", status: viewModel.emergencyProceduresPoster))
                    posterReports.append(PosterReport(posterType: "copyRightWrongPoster", status: viewModel.copyRightWrongPoster))
                    posterReports.append(PosterReport(posterType: "sasSpssPoster", status: viewModel.sasSpssPoster))
                    posterReports.append(PosterReport(posterType: "newAdobeCcLoginPoster", status: viewModel.newAdobeCcLoginPoster))
                    
                    // ISSUES
                    var issues: [Issue] = []
                    // sign holder issues
                    if !viewModel.signHoldersGoodCondition {
                        // get an ID from Firestore
                        let issueId = try await IssueManager.shared.getNewIssueId()
                        issues.append(Issue(id: issueId, description: viewModel.signHoldersIssueDescription, dateCreated: Date(), dateResolved: nil, issueTypeId: "wYJWtaj33rx4EIh6v9RY", resolved: false, ticket: nil, reportId: siteReadyId, reportType: "site_ready", siteId: site.id, userSubmitted: user.uid, userAssigned: nil))
                    }
                    if !viewModel.signHolders11x17GoodCondition {
                        // get an ID from Firestore
                        let issueId = try await IssueManager.shared.getNewIssueId()
                        issues.append(Issue(id: issueId, description: viewModel.signHolders11x17IssueDescription, dateCreated: Date(), dateResolved: nil, issueTypeId: "wYJWtaj33rx4EIh6v9RY", resolved: false, ticket: nil, reportId: siteReadyId, reportType: "site_ready", siteId: site.id, userSubmitted: user.uid, userAssigned: nil))
                    }
                    // SitesTech issues
                    if viewModel.failedToLoginCount > 0 {
                        for index in 0...(viewModel.failedToLoginCount-1) {
                            // get an ID from Firestore
                            let issueId = try await IssueManager.shared.getNewIssueId()
                            issues.append(Issue(id: issueId, description: viewModel.computerFailures[index], dateCreated: Date(), dateResolved: nil, issueTypeId: "r6jx5SXc0x2OC7bM8XNN", resolved: false, ticket: viewModel.failedLoginTicketNumbers[index], reportId: siteReadyId, reportType: "site_ready", siteId: site.id, userSubmitted: user.uid, userAssigned: nil))
                        }
                    }
                    // label issues
                    if viewModel.labelsToReplace > 0 {
                        for index in 0...(viewModel.labelsToReplace-1) {
                            // get an ID from Firestore
                            let issueId = try await IssueManager.shared.getNewIssueId()
                            issues.append(Issue(id: issueId, description: viewModel.computerLabels[index], dateCreated: Date(), dateResolved: nil, issueTypeId: "GxFGSkbDySZmdkCFExt9", resolved: false, ticket: nil, reportId: siteReadyId, reportType: "site_ready", siteId: site.id, userSubmitted: user.uid, userAssigned: nil))
                        }
                    }
                    if viewModel.printerLabelsToReplace > 0 {
                        for index in 0...(viewModel.printerLabelsToReplace-1) {
                            // get an ID from Firestore
                            let issueId = try await IssueManager.shared.getNewIssueId()
                            issues.append(Issue(id: issueId, description: viewModel.printerLabels[index], dateCreated: Date(), dateResolved: nil, issueTypeId: "GxFGSkbDySZmdkCFExt9", resolved: false, ticket: nil, reportId: siteReadyId, reportType: "site_ready", siteId: site.id, userSubmitted: user.uid, userAssigned: nil))
                        }
                    }
                    // other issues
                    if viewModel.otherIssuesCount > 0 {
                        for index in 0...(viewModel.otherIssuesCount-1) {
                            // get an ID from Firestore
                            let issueId = try await IssueManager.shared.getNewIssueId()
                            issues.append(Issue(id: issueId, description: viewModel.otherIssues[index], dateCreated: Date(), dateResolved: nil, issueTypeId: viewModel.otherIssueTypes[index], resolved: false, ticket: viewModel.otherIssueTicketNumbers[index], reportId: siteReadyId, reportType: "site_ready", siteId: site.id, userSubmitted: user.uid, userAssigned: nil))
                        }
                    }
                    // update empty issue documents in Firestore
                    try await IssueManager.shared.updateIssues(issues)
                    
                    // SITE READY
                    let siteReady = SiteReady(
                        id: user.uid,
                        timestamp: Date(),
                        user: user.uid,
                        siteId: siteReadyId,
                        macCount: viewModel.macCount,
                        pcCount: viewModel.pcCount,
                        scannerCount: viewModel.scannerCount,
                        scannerComputers: viewModel.scannerComputers,
                        bwPrinterCount: viewModel.bwPrinterCount,
                        colorPrinterCount: viewModel.colorPrinterCount,
                        chairCount: viewModel.chairCount,
                        missingChairs: nil, //TODO: would have to pull current chair count and calculate
                        updatedInventory: viewModel.updatedInventory,
                        posters: posterReports,
                        supplyRequests: nil, //TODO: to be implemented later
                        equipmentStatuses: nil, //TODO: to be implemented later
                        issues: issues.map { $0.id },
                        comments: viewModel.additionalComments
                    )
                    // update siteCaptain document in Firestore
                    try await SiteReadyManager.shared.updateSiteReady(siteReady)
                    
                    print("Submitted issues \(issues.map { $0.id })")
                    print("Submitted site ready \(siteReady.id)")
                    // dismiss the current view
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("Error submitting issues and site ready: \(error)")
            }
        }
    }
    
    private func printFormData() {
        if let user = user {
            print("User: \(user.uid)")
            print("SiteId: \(site.id)")
            print("MacCount: \(viewModel.macCount)")
            print("PcCount: \(viewModel.pcCount)")
            print("ScannerCount: \(viewModel.scannerCount)")
            print("ScannerComputers: \(viewModel.scannerComputers)")
            print("bwPrinterCount: \(viewModel.bwPrinterCount)")
            print("colorPrinterCount: \(viewModel.colorPrinterCount)")
            print("ChairCount: \(viewModel.chairCount)")
            print("MissingChairs: \(viewModel.missingChairs)")
            print("UpdatedInventory: \(viewModel.updatedInventory)")
            
            print("Posters:")
            print("missionStatementBanner = \(viewModel.missionStatementBanner)")
            print("reservedBoardNotification = \(viewModel.reservedBoardNotification)")
            print("cyberSecurityPoster = \(viewModel.cyberSecurityPoster)")
            print("adaptiveComputingPoster = \(viewModel.adaptiveComputingPoster)")
            print("printSmartPrintingInfoPoster = \(viewModel.printSmartPrintingInfoPoster)")
            print("needHelpPoster = \(viewModel.needHelpPoster)")
            print("activeShooterPoster = \(viewModel.activeShooterPoster)")
            print("emergencyProceduresPoster = \(viewModel.emergencyProceduresPoster)")
            print("copyRightWrongPoster = \(viewModel.copyRightWrongPoster)")
            print("sasSpssPoster = \(viewModel.sasSpssPoster)")
            print("newAdobeCcLoginPoster = \(viewModel.newAdobeCcLoginPoster)")
            print("signHoldersGoodCondition = \(viewModel.signHoldersGoodCondition)")
            print("signHolders11x17GoodCondition = \(viewModel.signHolders11x17GoodCondition)")
            
            print("Tickets:")
            print("signHoldersIssueDescription = \(viewModel.signHoldersIssueDescription)")
            print("signHolders11x17IssueDescription = \(viewModel.signHolders11x17IssueDescription)")
            print("Failed Login Tickets: \(viewModel.failedLoginTicketNumbers)")
            print("Failed Login Descriptions: \(viewModel.computerFailures)")
            print("ComputerLabels: \(viewModel.computerLabels)")
            print("PrinterLabels: \(viewModel.printerLabels)")
            print("Other Issue Tickets: \(viewModel.otherIssueTicketNumbers)")
            print("Other Issue Types: \(viewModel.otherIssueTypes)")
            print("Other Issue Descrips: \(viewModel.otherIssues)")
            print("Comments: \(viewModel.additionalComments)")
        }
    }
    
    private func submitSiteReadySurvey(db: Firestore,
                                       reportedIssuesUUIDs: [String],
                                       printerLabelIssuesUUIDs: [String],
                                       otherIssues: [String]) async throws {
        do {
            if let user = user {
                let documentId = try await SiteReadyManager.shared.getNewSiteReadyId()
                let docRef = db.collection("site_ready_entries").document(documentId)
                let timestamp = Timestamp(date: Date())
                
                // Combine reported issues and printer label issues' UUIDs into a single array
                let allIssues = reportedIssuesUUIDs + printerLabelIssuesUUIDs
                
                let data: [String: Any] = [
                    // Include all issues UUIDs in the "issues" array
                    SiteReady.CodingKeys.issues.rawValue: allIssues,
                    // Other fields...
                    SiteReady.CodingKeys.comments.rawValue: viewModel.additionalComments,
                    "computing_site": site.id,
                    "id": documentId,
                    "mac_count": viewModel.macCount,
                    "missing_chairs": viewModel.missingChairs,
                    "pc_count": viewModel.pcCount,
                    "user": user.uid,
                    "timestamp": timestamp
                ]
                
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
                
                // Print otherIssues for debugging
                print("Other Issues: \(otherIssues)")
                
                // Submit other issues to reported_issues
                try await submitOtherIssues(db: db, userId: user.uid, otherIssues: otherIssues)
            }
        } catch {
            print("Error submitting site ready: \(error)")
        }
    }
    private func submitOtherIssues(db: Firestore, userId: String, otherIssues: [String]) async throws {
        do {
            let group = DispatchGroup()
            
            for index in 0..<otherIssues.count {
                group.enter()
                let documentId = try await IssueManager.shared.getNewIssueId()
                let docRef = db.collection("reported_issues").document(documentId)
                let timestamp = Timestamp(date: Date())
                
                let data: [String: Any] = [
                    "description": otherIssues[index], // Include the description field
                    "id": documentId,
                    "issue_type": "GxFGSkbDySZmdkCFExt9", // Adjust as needed
                    "report_type": "site_ready",
                    "resolved": false,
                    "site": site.id,
                    "ticket": viewModel.otherIssueTicketNumbers[index],
                    "date_created": timestamp,
                    "user_submitted": userId
                ]
                
                // Write data to Firestore
                docRef.setData(data) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Reported other issue \(index + 1) successfully written!")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                print("All other issues submitted successfully")
            }
        } catch {
            print("Error submitting other issues: \(error)")
        }
    }
    private func submitReportedIssues(db: Firestore, userId: String, completion: @escaping ([String]) -> Void) async {
        do {
            var reportedIssuesUUIDs: [String] = []
            
            let group = DispatchGroup()
            
            // Write issues from computerFailures
            for index in 0..<viewModel.failedToLoginCount {
                group.enter()
                do {
                    let documentId = try await IssueManager.shared.getNewIssueId()
                    let docRef = db.collection("reported_issues").document(documentId)
                    let timestamp = Timestamp(date: Date())
                    
                    let data: [String: Any] = [
                        Issue.CodingKeys.id.rawValue: documentId,
                        Issue.CodingKeys.issueTypeId.rawValue: "GxFGSkbDySZmdkCFExt9",
                        Issue.CodingKeys.reportId.rawValue: viewModel.reportId,
                        Issue.CodingKeys.reportType.rawValue: "site_ready",
                        Issue.CodingKeys.resolved.rawValue: false,
                        Issue.CodingKeys.siteId.rawValue: site.id,
                        Issue.CodingKeys.ticket.rawValue: viewModel.failedLoginTicketNumbers[index],
                        Issue.CodingKeys.dateCreated.rawValue: timestamp,
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
                } catch {
                    print("Error getting new issue ID: \(error)")
                    group.leave()
                }
            }
            
            // Write issues from otherIssues
            for index in 0..<viewModel.otherIssuesCount {
                group.enter()
                do {
                    let documentId = try await IssueManager.shared.getNewIssueId()
                    let docRef = db.collection("reported_issues").document(documentId)
                    let timestamp = Timestamp(date: Date())
                    
                    let data: [String: Any] = [
                        Issue.CodingKeys.id.rawValue: documentId,
                        
                        Issue.CodingKeys.issueTypeId.rawValue: "",
                        Issue.CodingKeys.reportId.rawValue: viewModel.reportId,
                        Issue.CodingKeys.reportType.rawValue: "site_ready",
                        Issue.CodingKeys.resolved.rawValue: false,
                        Issue.CodingKeys.siteId.rawValue: site.id,
                        Issue.CodingKeys.description.rawValue: viewModel.otherIssues[index],
                        Issue.CodingKeys.ticket.rawValue: viewModel.otherIssueTicketNumbers[index],
                        Issue.CodingKeys.dateCreated.rawValue: timestamp,
                        Issue.CodingKeys.userSubmitted.rawValue: userId
                    ]
                    
                    // Write data to Firestore
                    docRef.setData(data) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            print("Reported other issue successfully written!")
                            reportedIssuesUUIDs.append(documentId)
                        }
                        group.leave()
                    }
                } catch {
                    print("Error getting new issue ID: \(error)")
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
                    Issue.CodingKeys.reportId.rawValue: viewModel.reportId,
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
            HStack {
                // Text prompt section for entering counts
                Text("Enter PC count:").frame(width: 200, alignment: .leading)
                Spacer()
                // PC Count TextField
                TextField("PC count", value: $viewModel.pcCount, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
            }
            HStack {
                // Text prompt section for MAC count
                Text("Enter MAC count:").frame(width: 200, alignment: .leading)
                Spacer()
                // MAC Count TextField
                TextField("MAC count", value: $viewModel.macCount, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
            }
            VStack {
                HStack {
                    // Text prompt section for scanner count
                    Text("Enter Scanner count:").frame(width: 200, alignment: .leading)
                    Spacer()
                    // Scanner Count TextField
                    TextField("Scanner count", value: $viewModel.scannerCount, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                }
                // What computers are the scanners attached to?
                if viewModel.scannerCount > 0 {
                    HStack {
                        Text("What computers are the scanners attached to?").frame( alignment: .leading)
                        Spacer()
                    }
                    //TODO: Implement dropdown of all computers in the site
                    ForEach(0..<viewModel.scannerCount, id: \.self) { index in
                        TextField("Computer Name", text: $viewModel.scannerComputers[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            HStack {
                // Text prompt section for chair count
                Text("Enter Chair count:").frame(width: 200, alignment: .leading)
                Spacer()
                // Chair Count TextField
                TextField("Chair count", value: $viewModel.chairCount, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
            }
            
            // Logged Into All Computers Section
            HStack {
                Text("Logged into all computers:").frame(width: 205, alignment: .leading)
                Spacer()
                Text(viewModel.loggedIntoAllComputers ? "Yes" : "No").frame(alignment: .trailing)
                Toggle(isOn: $viewModel.loggedIntoAllComputers){}.labelsHidden()
            }
            // Number of computers that failed to login
            if (viewModel.loggedIntoAllComputers == false) {
                VStack {
                    
                    Stepper(value: $viewModel.failedToLoginCount, in: 0...100, step: 1) {
                        Text("How many computers failed to login?")
                    }
                    // Details for each computer that failed to login
                    if (viewModel.failedToLoginCount > 0) {
                        ForEach(0..<viewModel.failedToLoginCount, id: \.self) { index in
                            ScrollView(.horizontal) {
                                HStack {
                                    TextField("Ticket", text: Binding(
                                        get: {
                                            return viewModel.failedLoginTicketNumbers[index] == 0 ? "" : "\(viewModel.failedLoginTicketNumbers[index])"
                                        },
                                        set: { newValue in
                                            viewModel.failedLoginTicketNumbers[index] = Int(newValue) ?? 0
                                        }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    
                                    TextField("Computer failure description", text: $viewModel.computerFailures[index])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                    }
                }
            }
            
            // Cleaned All Computers Section
            HStack {
                Text("Cleaned all computers:").frame(width: 205, alignment: .leading)
                Spacer()
                Text(viewModel.cleanedAllComputers ? "Yes" : "No").frame(alignment: .trailing)
                Toggle(isOn: $viewModel.cleanedAllComputers){}.labelsHidden()
            }
            
            // Cleaned All Stations Section
            HStack {
                Text("Cleaned all stations:").frame(width: 205, alignment: .leading)
                Spacer()
                Text(viewModel.cleanedAllStations ? "Yes" : "No").frame(alignment: .trailing)
                Toggle(isOn: $viewModel.cleanedAllStations){}.labelsHidden()
            }
        }
    }
}
struct PrintersSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    
    var body: some View {
        Section(header: Text("Printers")) {
            // How many B&W printers are there?
            HStack {
                // Text prompt section for scanner count
                Text("How many B&W printers are there?").frame(width: 270, alignment: .leading)
                Spacer()
                // Count TextField
                TextField("B&W Printer Count", value: $viewModel.bwPrinterCount, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
            }
            
            // How many color printers are there?
            HStack {
                // Text prompt section for scanner count
                Text("How many Color printers are there?").frame(width: 270, alignment: .leading)
                Spacer()
                // Count TextField
                TextField("Color Printer Count", value: $viewModel.colorPrinterCount, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
            }
            
            // Top off all printers with paper
            if viewModel.bwPrinterCount > 0 || viewModel.colorPrinterCount > 0 {
                Text("")
                HStack {
                    Text("Top off all printers with paper:").frame(width: 230, alignment: .leading)
                    Spacer()
                    Text(viewModel.topOffPrintersWithPaper ? "Yes" : "No").frame(alignment: .trailing)
                    Toggle(isOn: $viewModel.topOffPrintersWithPaper){}.labelsHidden()
                }
                
                // Did you test print a page for each printer?
                HStack {
                    Text("Did you test print a page for each printer?").frame(width: 230, alignment: .leading)
                    Spacer()
                    Text(viewModel.testPrintedForPrinters ? "Yes" : "No").frame(alignment: .trailing)
                    Toggle(isOn: $viewModel.testPrintedForPrinters){}.labelsHidden()
                }
                
                // Did you wipe down each printer?
                HStack {
                    Text("Did you wipe down each printer?").frame(width: 230, alignment: .leading)
                    Spacer()
                    Text(viewModel.wipedDownPrinters ? "Yes" : "No").frame(alignment: .trailing)
                    Toggle(isOn: $viewModel.wipedDownPrinters){}.labelsHidden()
                }
                
                // Do any printer labels need replacement?
                HStack {
                    Text("Do any printer labels need replacement?").frame(width: 230, alignment: .leading)
                    Spacer()
                    Text(viewModel.needPrinterLabelReplacement ? "Yes" : "No").frame(alignment: .trailing)
                    Toggle(isOn: $viewModel.needPrinterLabelReplacement){}.labelsHidden()
                }
                if viewModel.needPrinterLabelReplacement {
                    VStack {
                        Stepper(value: $viewModel.printerLabelsToReplace, in: 0...100, step: 1) {
                            Text("How many printer labels need to be replaced?")
                        }
                        if viewModel.printerLabelsToReplace > 0 {
                            ForEach(0..<viewModel.printerLabelsToReplace, id: \.self) { index in
                                PrinterLabelReplacementView(labelIndex: index, printerLabel: $viewModel.printerLabels[index])
                            }
                        }
                    }
                }
            }
        }
    }
}
struct PostersSection: View {
    @ObservedObject var viewModel: SiteReadySurveyView.ViewModel
    let options = ["No", "Yes", "Yes, but it is in bad condition."]
    
    var body: some View {
        Section(header: Text("Posters")) {
            // Mission Statement banner
            Picker("Is the Mission Statement banner on the poster board?", selection: $viewModel.missionStatementBanner) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Reserved Board notification
            Picker("Is the Reserved Board notification on the poster board?", selection: $viewModel.reservedBoardNotification) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Cyber Security Poster
            Picker("Is the Cyber Security Poster displayed?", selection: $viewModel.cyberSecurityPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Adaptive Computing Poster
            Picker("Is the Adaptive Computing Poster displayed?", selection: $viewModel.adaptiveComputingPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Print Smart Printing Info Poster
            Picker("Is the Print Smart Printing Info Poster displayed?", selection: $viewModel.printSmartPrintingInfoPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Need Help Poster
            Picker("Is the Need Help Poster displayed?", selection: $viewModel.needHelpPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Active Shooter Poster
            Picker("Is the Active Shooter Poster displayed?", selection: $viewModel.activeShooterPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Emergency Procedures Poster
            Picker("Is the Emergency Procedures Poster displayed?", selection: $viewModel.emergencyProceduresPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // Copyright Wrong Poster
            Picker("Is the Copyright Wrong Poster displayed?", selection: $viewModel.copyRightWrongPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // SAS SPSS Poster
            Picker("Is the SAS SPSS Poster displayed?", selection: $viewModel.sasSpssPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // New Adobe CC Login Poster
            Picker("Is the New Adobe CC Login Poster displayed?", selection: $viewModel.newAdobeCcLoginPoster) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }.pickerStyle(DefaultPickerStyle())
            
            // 8.5x11" Sign Holders
            VStack {
                HStack {
                    Text("Are the 8.5x11\" Sign Holders in Good Condition?").frame(width: 230, alignment: .leading)
                    Spacer()
                    Text(viewModel.signHoldersGoodCondition ? "Yes" : "No").frame(alignment: .trailing)
                    Toggle(isOn: $viewModel.signHoldersGoodCondition){}.labelsHidden()
                }
                if !viewModel.signHoldersGoodCondition {
                    TextField("Description of Issue", text: $viewModel.signHoldersIssueDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // 11x17" Sign Holders
            VStack {
                HStack {
                    Text("Is the 11x17\" Sign Holder in Good Condition?").frame(width: 230, alignment: .leading)
                    Spacer()
                    Text(viewModel.signHolders11x17GoodCondition ? "Yes" : "No").frame(alignment: .trailing)
                    Toggle(isOn: $viewModel.signHolders11x17GoodCondition){}.labelsHidden()
                }
                if !viewModel.signHolders11x17GoodCondition {
                    TextField("Description of Issue", text: $viewModel.signHolders11x17IssueDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // Removed old calendars
            HStack {
                Text("Have you removed all old weekly calendars?").frame(width: 230, alignment: .leading)
                Spacer()
                Text(viewModel.removedOldCalendars ? "Yes" : "No").frame(alignment: .trailing)
                Toggle(isOn: $viewModel.removedOldCalendars){}.labelsHidden()
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
            VStack {
                Stepper(value: $viewModel.otherIssuesCount, in: 0...100, step: 1) {
                    Text("How many other issues?")
                }
                // Issues dropdown
//                ForEach(0..<viewModel.otherIssuesCount, id: \.self) { index in
//                    if index < viewModel.otherIssueTypes.count {
//                        IssueRow(issueType: $viewModel.otherIssueTypes[index],
//                                 issueDescription: $viewModel.otherIssues[index],
//                                 ticketNumber: $viewModel.otherIssueTicketNumbers[index])
//                    }
//                }
                // Details for each computer that failed to login
                if (viewModel.otherIssuesCount > 0) {
                    ForEach(0..<viewModel.otherIssuesCount, id: \.self) { index in
                        issueRow(index: index)
                    }
                }
            }
        }
    }
    
    private func issueRow(index: Int) -> some View {
        let issueTypesNoTickets = ["FldaGVfpPdQ57H7XsGOO" /*chair*/,
                                   "GxFGSkbDySZmdkCFExt9" /*label*/,
                                   "wYJWtaj33rx4EIh6v9RY" /*poster*/]
        
        var requiresTicketNumber: Bool {
            // Check if the selected issue type requires a ticket number
            // If the issue type is in issueTypesNoTickets, then ticket number is not required
            return !issueTypesNoTickets.contains(viewModel.otherIssueTypes[index])
        }
        
        return VStack {
            HStack {
                // Issue Type Picker
                Picker("Issue Type", selection: $viewModel.otherIssueTypes[index]) {
                    Text("Choose Type").tag("")
                    ForEach(IssueTypeManager.shared.issueTypes, id: \.id) { issueType in
                        Text(issueType.name).tag(issueType.id)
                    }
                }
                .multilineTextAlignment(.leading)
                .pickerStyle(DefaultPickerStyle())
                .labelsHidden()
                
                // Conditionally show the Ticket Number field based on the requirement
                if requiresTicketNumber {
                    // Ticket Number
                    TextField("Ticket", text: Binding(
                        get: {
                            return viewModel.otherIssueTicketNumbers[index] == 0 ? "" : "\(viewModel.otherIssueTicketNumbers[index])"
                        },
                        set: { newValue in
                            viewModel.otherIssueTicketNumbers[index] = Int(newValue) ?? 0
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                }
                Spacer()
            }
            
            // Issue Description
            TextField("Description", text: $viewModel.otherIssues[index])
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}
//struct IssueRow: View {
//    @Binding var issueType: String
//    @Binding var issueDescription: String
//    @Binding var ticketNumber: String
//    
//    let issueTypesNoTickets = ["FldaGVfpPdQ57H7XsGOO" /*chair*/,
//                               "GxFGSkbDySZmdkCFExt9" /*label*/,
//                               "wYJWtaj33rx4EIh6v9RY" /*poster*/]
//    
//    var requiresTicketNumber: Bool {
//        // Check if the selected issue type requires a ticket number
//        // If the issue type is in issueTypesNoTickets, then ticket number is not required
//        return !issueTypesNoTickets.contains(issueType)
//    }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                // Issue Type Picker
//                Picker("Issue Type", selection: $issueType) {
//                    ForEach(IssueTypeManager.shared.issueTypes, id: \.id) { issueType in
//                        Text(issueType.name).tag(issueType.id)
//                    }
//                }
//                .multilineTextAlignment(.leading)
//                .pickerStyle(DefaultPickerStyle())
//                .labelsHidden()
//                
//                // Conditionally show the Ticket Number field based on the requirement
//                if requiresTicketNumber {
//                    // Ticket Number
////                    TextField("Ticket", text: $ticketNumber)
////                        .textFieldStyle(RoundedBorderTextFieldStyle())
////                        .keyboardType(.numberPad)
//                    TextField("Ticket", text: Binding(
//                        get: {
//                            return ticketNumber == 0 ? "" : "\(ticketNumber)"
//                        },
//                        set: { newValue in
//                            ticketNumber = Int(newValue) ?? 0
//                        }
//                    ))
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .keyboardType(.numberPad)
//                }
//                Spacer()
//            }
//            
//            // Issue Description
//            TextField("Description", text: $issueDescription)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//        }.padding(.leading, 8)
//    }
//}

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
        TextField("Printer label name", text: $printerLabel)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
extension SiteReadySurveyView {
    class ViewModel: ObservableObject {
        // Survey Data
        @Published var pcCount: Int = 0
        @Published var macCount: Int = 0
        @Published var scannerCount: Int = 0 {
            didSet {
                ensureArraysMatchCount()
            }
        }
        
        @Published var chairCount: Int = 0
        @Published var loggedIntoAllComputers: Bool = false
        @Published var failedToLoginCount: Int = 0 {
            didSet {
                ensureArraysMatchCount()
            }
        }
        init() {
            fetchIssueTypes()
        }
        @Published var scannerComputers: [String] = []
        @Published var failedLoginTicketNumbers: [Int] = []
        @Published var computerFailures: [String] = []
        @Published var cleanedAllComputers: Bool = false
        @Published var cleanedAllStations: Bool = false
        @Published var needLabelReplacement: Bool = false
        @Published var labelsToReplace: Int = 0 {
            didSet {
                ensureArraysMatchCount()
            }
        }
        @Published var computerLabels: [String] = []
        @Published var needPrinterLabelReplacement: Bool = false
        @Published var printerLabelsToReplace: Int = 0 {
            didSet {
                ensureArraysMatchCount()
            }
        }
        @Published var printerLabels: [String] = []
        @Published var bwPrinterCount: Int = 0 {
            didSet {
                updateShowPrinterRelatedSections()
            }
        }
        @Published var colorPrinterCount: Int = 0 {
            didSet {
                updateShowPrinterRelatedSections()
            }
        }
        @Published var topOffPrintersWithPaper: Bool = false
        @Published var testPrintedForPrinters: Bool = false
        @Published var wipedDownPrinters: Bool = false
        @Published var issues: [Issue] = []
        @Published var labelIssues: [Issue] = []
        
        // Printer-related Sections
        @Published var showPrinterRelatedSections: Bool = false
        
        // Posters & Notices
        @Published var missionStatementBanner: String = "No"
        @Published var reservedBoardNotification: String = "No"
        @Published var cyberSecurityPoster: String = "No"
        @Published var adaptiveComputingPoster: String = "No"
        @Published var printSmartPrintingInfoPoster: String = "No"
        @Published var needHelpPoster: String = "No"
        @Published var activeShooterPoster: String = "No"
        @Published var emergencyProceduresPoster: String = "No"
        @Published var copyRightWrongPoster: String = "No"
        @Published var sasSpssPoster: String = "No"
        @Published var newAdobeCcLoginPoster: String = "No"
        @Published var signHoldersGoodCondition: Bool = true
        @Published var signHoldersIssueDescription: String = ""
        @Published var signHolders11x17GoodCondition: Bool = true
        @Published var signHolders11x17IssueDescription: String = ""
        @Published var removedOldCalendars: Bool = false
        
        func fetchIssueTypes() {
            IssueTypeManager.shared.fetchIssueTypes()
        }
        
        // Miscellaneous
        var missingChairs: Int = 0
        @Published var projectorWorkingProperly: String = "Yes"
        @Published var clockWorking: String = "Yes"
        @Published var cleanedWhiteboard: Bool = false
        @Published var updatedInventory: Bool = false
        @Published var tookOutRecycling: Bool = false
        
        @Published var otherIssuesCount: Int = 0 {
            didSet {
                ensureArraysMatchCount()
            }
        }
        @Published var otherIssues: [String] = []
        @Published var otherIssueTicketNumbers: [Int] = []
        @Published var otherIssueTypes: [String] = []
        @Published var reportId: String = ""
        @Published var additionalComments: String = ""
        
        // Function to update the showPrinterRelatedSections flag
        private func updateShowPrinterRelatedSections() {
            showPrinterRelatedSections = bwPrinterCount > 0 || colorPrinterCount > 0
        }
        
        // Ensure arrays match the count when otherIssuesCount or labelsToReplace changes
        private func ensureArraysMatchCount() {
            while scannerComputers.count < scannerCount {
                scannerComputers.append("")
            }
            while scannerComputers.count > scannerCount {
                scannerComputers.removeLast()
            }
            
            while computerFailures.count < failedToLoginCount {
                computerFailures.append("")
            }
            while computerFailures.count > failedToLoginCount {
                let count = computerFailures.count - failedToLoginCount
                computerFailures.removeLast(count)
            }
            
            while failedLoginTicketNumbers.count < failedToLoginCount {
                failedLoginTicketNumbers.append(0)
            }
            
            while computerLabels.count < labelsToReplace {
                computerLabels.append("")
            }
            while computerLabels.count > labelsToReplace {
                let count = computerLabels.count - labelsToReplace
                computerLabels.removeLast(count)
            }
            
            while printerLabels.count < printerLabelsToReplace {
                printerLabels.append("")
            }
            while printerLabels.count > printerLabelsToReplace {
                let count = printerLabels.count - printerLabelsToReplace
                printerLabels.removeLast(count)
            }
            
            while otherIssues.count < otherIssuesCount {
                otherIssues.append("")
                otherIssueTypes.append("")
                otherIssueTicketNumbers.append(0)
            }
            while otherIssues.count > otherIssuesCount {
                let count = otherIssues.count - otherIssuesCount
                otherIssues.removeLast(count)
                otherIssueTypes.removeLast(count)
            }
        }
    }
}

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


