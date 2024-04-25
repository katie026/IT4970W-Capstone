//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI
import FirebaseAuth

struct SiteCaptainSubmissionView: View {
    // init
    var site: Site
    // ViewModel
    @StateObject private var viewModel = SiteCaptainViewModel()
    // View Control
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = true
    @State var submitButtonActive: Bool = false
    @State private var showIssuesSummary = false
    @State private var showLabelsSummary = false
    @State private var showSupplySummary = false
    // Alerts
    @State private var showInputErrorMessage = false
    @State private var showConfirmAlert = false
    @State private var showResultAlert = false
    // Temporary variables
    @State private var inputErrorMessage = ""
    @State private var errorMessage: String? // delete eventually?
    @State private var selectedSupplyType: SupplyType? // delete eventually
    @State private var suppliesNeededCount: Int = 1 // delete eventually

    var body: some View {
        if isLoading {
            ProgressView()
                .onAppear {
                    print("OnFirstAppear)")
                    firstOnAppear(){
                        isLoading = false
                    }
                }
        } else {
            // Content
            VStack {
                content
            }
            // Title
            .navigationTitle("Site Captain")
            .onReceive(viewModel.$submissionError) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = nil
                }
            }
        }
    }
    
    private var content: some View {
        VStack {
            header
            
            // Form Section
            siteCaptainForm
                
            
            // Submit Section
            submitButton()
                .alert(isPresented: $showConfirmAlert) {
                    Alert(
                        title: Text("Confirm Submission"),
                        message: Text("Report \(viewModel.issues.count) issues, \(viewModel.labelIssues.count) labels, and \(viewModel.supplyRequests.count) supply requests."),
                        primaryButton: .default(Text("Submit")) {
                            // submit the site captain form
                            viewModel.submitSiteCaptainEntry(site: site) {
                                showResultAlert = true
                            }
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            // dismiss alert
                            showConfirmAlert = false
                        }
                    )
                }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private var header: some View {
        // Subtitle
        HStack {
            Text("\(site.name ?? "N/A")")
                .font(.title2)
                .fontWeight(.medium)
                .alert(isPresented: $showInputErrorMessage) {
                    Alert(title: Text("Input Error"),
                          message: Text(inputErrorMessage),
                          dismissButton: .default(Text("OK"), action: {
                    }))
                }

            Spacer()
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
    }
    
    private func firstOnAppear(completion: @escaping () -> Void) {
        viewModel.getUser()
        viewModel.getSupplyTypes(){}
        viewModel.getIssueTypes(){}
        viewModel.selectedThingsToClean = Array(repeating: false, count: viewModel.thingsToClean.count)
        viewModel.selectedThingsToDo = Array(repeating: false, count: viewModel.thingsToDo.count)
        viewModel.getSiteComputers(siteId: site.id) {
            viewModel.getSitePrinters(siteId: site.id) {
                completion()
            }
        }
    }

    private func submitSiteCaptain() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Unable to get current user information."
            return
        }

        if let selectedSupplyType = selectedSupplyType {
            viewModel.addSupply(supply: selectedSupplyType, count: suppliesNeededCount)
        }

        viewModel.submitSiteCaptainEntry(site: site) {}
    }
    
    private func checkIfCanSubmit() -> Bool {
        // checked each cleaning to do
        if !(viewModel.selectedThingsToClean.allSatisfy({ $0 == true })) {
            inputErrorMessage = "You have not completed all cleaning tasks."
            return false
        }
        
        // checked each to do
        if !(viewModel.selectedThingsToDo.allSatisfy({ $0 == true })) {
            inputErrorMessage = "You have not completed all miscellaneous tasks."
            return false
        }
        
        // check if reported issues AND not all issues fields are filled out
        if (viewModel.hasIssues == true && // if user said there are issues
            (
                (viewModel.issues.count == 0) || // but the issues list is empty
                !(viewModel.issues.allSatisfy({ $0.issueTypeId != nil })) || // or not all type ids are selected
                !(viewModel.issues.allSatisfy({ $0.description != nil })) // or not all descriptions are entered
//                !(viewModel.issues.allSatisfy({ $0.ticket != nil })) // or not all ticket #s are entered
            )
          )
        {
            inputErrorMessage = "You have not inputed all issue information."
            return false
        }
        
        // for each issue
        for issue in viewModel.issues {
            if (
                // if the issue type needs a ticket
                !(viewModel.issueTypesNoTickets.contains(where: {$0 == issue.issueTypeId})) &&
                // AND ticket == nil
                (issue.ticket == nil)
            ){
                inputErrorMessage = "You have not inputed all issue information."
                return false
            }
        }
        
        // check if label issues AND not all label fields are filled out
        if (viewModel.hasLabelIssues == true &&  // if user said there are label issues
            (
                viewModel.labelIssues.count == 0 || // but the labels list is empty
                !(viewModel.labelIssues.allSatisfy({ $0.description != nil })) // or not all descriptions are entered
            )
        ) {
            inputErrorMessage = "You have not inputed all label names."
            return false
        }
        
        // check if either site has no inventory or has submitted an entry
        if (site.hasInventory == true && viewModel.inventoryUpdated == false) {
            inputErrorMessage = "You have not indicated you submitted an inventory entry."
            return false
        }
        
        // check if supply requests AND not all supplyRequest fields are filled out
        if (viewModel.needsSupplies == true && // if user said site needs supplies
            (
                (viewModel.supplyRequests.count == 0) || // but the issues list is empty
                !(viewModel.supplyRequests.allSatisfy({ $0.supplyTypeId != nil })) // or not all type ids are selected
            )
        ){
            inputErrorMessage = "You have not inputed all supply request information."
            return false
        }
        
        // If it passes all checks
        return true
    }
    
    private var siteCaptainForm: some View {
        Form {
            // To Do Lists
            thingsToCleanSection
            thingsToDoSection
            // Issues
            issuesSection
            // Labels
            if (viewModel.computers.count > 0 || viewModel.printers.count > 0) {
                labelsSection()
            }
            // Inventory
            inventorySection
            if site.hasInventory == true {
                // Supplies
                supplySection
            }
            // Summary
            if viewModel.issues.count > 0 {
                issuesSummarySection
            }
            if viewModel.labelIssues.count > 0 {
                labelsSummarySection
            }
            if viewModel.supplyRequests.count > 0 {
                supplySummarySection
            }
        }
    }
    
    var thingsToCleanSection: some View {
        Section("Things to Clean") {
            ForEach(viewModel.thingsToClean.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.selectedThingsToClean[index].toggle()
//                        checkIfCanSubmit()
                    }) {
                        Image(systemName: viewModel.selectedThingsToClean[index] ? "checkmark.square" : "square")
                    }
                    Text(viewModel.thingsToClean[index])
                }
            }
        }.alert(isPresented: $showResultAlert) {
            Alert(
                title: Text("Status"),
                message: Text(viewModel.resultMessage),
                dismissButton: .default(Text("OK")) {
                    // dismiss the current view and navigate back one view (SubmitFormView)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    var thingsToDoSection: some View {
        Section("Things to Do") {
            ForEach(viewModel.thingsToDo.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.selectedThingsToDo[index].toggle()
//                        checkIfCanSubmit()
                    }) {
                        Image(systemName: viewModel.selectedThingsToDo[index] ? "checkmark.square" : "square")
                    }
                    Text(viewModel.thingsToDo[index])
                }
            }
        }
    }
    
    var issuesSection: some View {
        Section("Issues") {
            Text("Are there any issues? (clock, keyboard, mouse, projector, missing chairs, etc.)")
            
            RadioButton(text: "Nope!", isSelected: !viewModel.hasIssues) {
                viewModel.hasIssues = false
            }
            RadioButton(text: "Yes.", isSelected: viewModel.hasIssues) {
                viewModel.hasIssues = true
            }
            
            if viewModel.hasIssues {
                issueInputSection()
            }
        }
    }
    
    private var issuesSummarySection: some View {
        Section("Issues Summary") {
            DisclosureGroup(isExpanded: $showIssuesSummary,  content: {
                // summary: for testing
                ForEach(viewModel.issues.indices, id: \.self) { index in
                    let issue = viewModel.issues[index]
                    issueSummaryRow(issue: issue)
                }
            }, label: {
                Text("**Reported Issues:** \(viewModel.issues.count)")
            })
        }
    }
    
    private func issueSummaryRow(issue: Issue) -> some View {
        let ticketNum = issue.ticket != nil ? String(issue.ticket ?? 0) : "nil"
        let typeName = IssueTypeManager.shared.issueTypes.first(where: { $0.id == issue.issueTypeId ?? "" })?.name ?? "unkown type name"
        let description = issue.description ?? "nil"
            
        let view = VStack(alignment: .leading) {
            // row
            Text("**Type:** \(typeName)")
                .lineLimit(1)
            Text("**Description:** \(description)")
                .lineLimit(1)
            Text("**Ticket:** \(ticketNum)")
                .lineLimit(1)
        }
        
        return AnyView(view)
    }
    
    func issueInputSection() -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    // ask how many issues
                    Text("How many issues are there?")
                        .frame(width: 250)
                    Spacer()
                    // issue count input
                    TextField("#", text: Binding(
                        get: { String(viewModel.issueCount) },
                        set: { newValue in
                            // limit how many issues can be reported
                            if Int(newValue) ?? 0 > 5 {
                                viewModel.issueCount = 5
                            } else {
                                // define issue count
                                viewModel.issueCount = Int(newValue) ?? 0
                            }
                            
                            // create an issue for each issue count
                            viewModel.issues = Array(repeating: Issue(
                                id: "", // must edit before creating in Firebase
                                description: nil, // should be editted by user using State var
                                timestamp: Date(),
                                issueTypeId: nil, // should be editted by user using State var
                                resolved: false,
                                ticket: nil, // should be editted by user using State var
                                reportId: nil, // must edit before creating in Firebase
                                reportType: "site_captain",
                                siteId: site.id,
                                userSubmitted: viewModel.user?.uid,
                                userAssigned: nil // keep nil
                            ), count: viewModel.issueCount)
                            viewModel.issues.enumerated().forEach { index, _ in
                                viewModel.issues[index].id = "\(index)"
                            }
                        }
                    ))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                    Spacer()
                }
                
                // Issue Form for each issue indicated
                ForEach(0..<(viewModel.issues.count), id: \.self) { index in
                    issueInputRow(index: index)
                }
            }
        }
        // add a button to dismiss keypad when needed
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        
        return AnyView(view)
    }
    
    func issueInputRow(index: Int) -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    // Issue Type input
                    Picker("Issue Type", selection: $viewModel.issues[index].issueTypeId) {
                        Text("Issue Type").tag(nil as String?)
                        ForEach(IssueTypeManager.shared.issueTypes, id: \.self) { issueType in
                            Text(issueType.name).tag(issueType.id as String?)
                        }
                    }
                    .labelsHidden()
                    .multilineTextAlignment(.center)
                    
                    // Ticket # input (if issue type is not a chair, label, or poster issue)
                    if !(viewModel.issueTypesNoTickets.contains(where: { $0 ==  viewModel.issues[index].issueTypeId})) {
                        TextField("7-digit ticket # if needed", text: Binding(
                            get: {
                                if let ticketNum = viewModel.issues[index].ticket {
                                    return String(ticketNum)
                                } else {
                                    return "Ticket #"
                                }
                            },
                            set: { newValue in
                                if let newValue = Int(newValue) {
                                    viewModel.issues[index].ticket = newValue
                                } else {
                                    viewModel.issues[index].ticket = nil
                                }
                            }))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    }
                }
                
                // Issue description input
                TextField("Description", text: Binding(
                    get: { viewModel.issues[index].description ?? "" }, // if description is nil
                    set: { newValue in
                        viewModel.issues[index].description = newValue
                    }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        
        return AnyView(view)
    }
    
    private func labelsSection() -> some View {
        return AnyView(
            Section("Labels") {
                // ask if any label issues
                Text("Are there any computer or printer labels that need to be replaced?")
                
                RadioButton(text: "Nope, they all look good.", isSelected: !viewModel.hasLabelIssues) {
                    viewModel.hasLabelIssues = false
                }
                RadioButton(text: "Yes", isSelected: viewModel.hasLabelIssues) {
                    viewModel.hasLabelIssues = true
                }
                
                if viewModel.hasLabelIssues {
                    labelInputSection()
                }
            }
        )
    }
    
    func labelInputSection() -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    // ask how many issues
                    Text("How many labels need replacement?")
                        .frame(width: 250)
                    // issue count input
                    TextField("#", text: Binding(
                        get: { String(viewModel.labelIssueCount) },
                        set: { newValue in
                            // limit how many issues can be reported
                            if Int(newValue) ?? 0 > 5 {
                                viewModel.labelIssueCount = 5
                            } else {
                                // define issue count
                                viewModel.labelIssueCount = Int(newValue) ?? 0
                            }
                            
                            // create an issue for each issue count
                            viewModel.labelIssues = Array(repeating: Issue(
                                id: "", // must edit before creating in Firebase
                                description: nil, // should be editted by user using State var
                                timestamp: Date(),
                                issueTypeId: "GxFGSkbDySZmdkCFExt9", // label issue
                                resolved: false,
                                ticket: nil, // labels don't need tickets
                                reportId: nil, // must edit before creating in Firebase
                                reportType: "site_captain",
                                siteId: site.id,
                                userSubmitted: viewModel.user?.uid,
                                userAssigned: nil // keep nil
                            ), count: viewModel.labelIssueCount)
                            viewModel.labelIssues.enumerated().forEach { index, _ in
                                viewModel.labelIssues[index].id = "\(index)"
                            }
                        }
                    ))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                    Spacer()
                }
                
                // Issue Form for each issue indicated
                ForEach(0..<(viewModel.labelIssues.count), id: \.self) { index in
                    labelInputRow(index: index)
                }
            }
        }
        // add a button to dismiss keypad when needed
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        
        return AnyView(view)
    }
    
    func labelInputRow(index: Int) -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    Text("Label Name: ")
                    // Issue Type input
                    Picker("Label", selection: $viewModel.labelIssues[index].description) {
                        // nil option
                        Text("Computer/Printer").tag(nil as String?)
                        //printer options
                        ForEach(viewModel.printers) { printer in
                            Text(printer.name ?? "").tag(printer.name as String?)
                        }
                        // computer options
                        ForEach(viewModel.computers) { computer in
                            Text(computer.name ?? "").tag(computer.name as String?)
                        }
                    }
                    .labelsHidden()
                    .multilineTextAlignment(.center)
                }
            }
        }
        
        return AnyView(view)
    }
    
    private var labelsSummarySection: some View {
        Section("Labels Summary") {
            DisclosureGroup(isExpanded: $showLabelsSummary,  content: {
                // summary: for testing
                ForEach(viewModel.labelIssues.indices, id: \.self) { index in
                    let issue = viewModel.labelIssues[index]
                    labelSummaryRow(issue: issue)
                }
            }, label: {
                Text("**Reported Labels:** \(viewModel.labelIssues.count)")
            })
        }
    }
    
    private func labelSummaryRow(issue: Issue) -> some View {
        let description = issue.description ?? "nil"
            
        let view = VStack(alignment: .leading) {
            // row
            Text("\(description)")
        }
        
        return AnyView(view)
    }
    
    var inventorySection: some View {
        Section("Inventory") {
            if site.hasInventory == true {
                Text("Did you submit an inventory entry?")
                
                RadioButton(text: "Yes", isSelected: viewModel.inventoryUpdated) {
                    viewModel.inventoryUpdated = true
                }
                RadioButton(text: "No", isSelected: !viewModel.inventoryUpdated) {
                    viewModel.inventoryUpdated = false
                }
            } else {
                Text("This site does not have an inventory site.")
                    .padding(.top)
            }
        }
    }
        
    var supplySection: some View {
        if site.hasInventory == true {
            return AnyView(
                Section("Supplies") {
                    Text("Are there any supplies immediately needed at this site's inventory location?")
                    
                    RadioButton(text: "No", isSelected: !viewModel.needsSupplies) {
                        viewModel.needsSupplies = false
                        selectedSupplyType = nil
                    }
                    RadioButton(text: "Yes", isSelected: viewModel.needsSupplies) {
                        viewModel.needsSupplies = true
                    }
                    
                    if viewModel.needsSupplies {
                        supplyInputSection()
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func supplyInputSection() -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    // ask how many issues
                    Text("How many supply types are needed?")
                        .frame(width: 250)
                    // issue count input
                    TextField("#", text: Binding(
                        get: { String(viewModel.supplyRequestCount) },
                        set: { newValue in
                            // limit how many supply types can be requested
                            if Int(newValue) ?? 0 > 5 {
                                viewModel.supplyRequestCount = 5
                            } else {
                                // define supply request count
                                viewModel.supplyRequestCount = Int(newValue) ?? 0
                            }
                            
                            // create SupplyRequest for each requested
                            viewModel.supplyRequests = Array(repeating: SupplyRequest(
                                id: "", // must edit before creating in Firebase
                                siteId: site.id,
                                supplyTypeId: nil, // should be editted by user using State var
                                countNeeded: nil, // should be editted by user using State var
                                reportId: nil, // must edit before creating in Firebase
                                reportType: "site_captain",
                                resolved: false,
                                dateCreated: Date(),
                                dateResolved: nil // keep nil
                            ), count: viewModel.supplyRequestCount)
                            // set temporary ids
                            viewModel.supplyRequests.enumerated().forEach { index, _ in
                                viewModel.supplyRequests[index].id = "\(index)"
                            }
                        }
                    ))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .keyboardType(.numberPad)
                    Spacer()
                }
                
                // SupplyRequest form for each supply indicated
                ForEach(0..<(viewModel.supplyRequests.count), id: \.self) { index in
                    supplyInputRow(index: index)
                }
            }
        }
        // add a button to dismiss keypad when needed
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        
        return AnyView(view)
    }
    
    func supplyInputRow(index: Int) -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    // Supply Type input
                    Picker("Supply Type", selection: $viewModel.supplyRequests[index].supplyTypeId) {
                        // nil option
                        Text("Supply Type").tag(nil as String?)
                        // supply type option
                        ForEach(SupplyTypeManager.shared.supplyTypes, id: \.self) { supplyType in
                            Text(supplyType.name).tag(supplyType.id as String?)
                        }
                    }
                    .labelsHidden()
                    .multilineTextAlignment(.center)
                    
                    // Supply Count input
                    Picker("Count", selection: $viewModel.supplyRequests[index].countNeeded) {
                        ForEach(1...10, id: \.self) { count in
                            Text("\(count)").tag(count as Int?)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(MenuPickerStyle())
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                }
            }
        }
        
        return AnyView(view)
    }
    
    private var supplySummarySection: some View {
        Section("Supply Request Summary") {
            DisclosureGroup(isExpanded: $showSupplySummary,  content: {
                ForEach(viewModel.supplyRequests.indices, id: \.self) { index in
                    let supplyRequest = viewModel.supplyRequests[index]
                    supplySummaryRow(supplyRequest: supplyRequest)
                }
            }, label: {
                Text("**Requests:** \(viewModel.supplyRequests.count)")
            })
        }
    }
    
    private func supplySummaryRow(supplyRequest: SupplyRequest) -> some View {
        let typeName = SupplyTypeManager.shared.supplyTypes.first(where: { $0.id == supplyRequest.supplyTypeId ?? "" })?.name ?? "unkown type name"
        let count = supplyRequest.countNeeded != nil ? "\(String(supplyRequest.countNeeded!))" : "nil"
            
        let view = VStack(alignment: .leading) {
            // row
            Text("\(typeName): \(count)")
        }
        
        return AnyView(view)
    }
    
    private func submitButton() -> some View {
        let result = Section {
            Button {
                let canSubmit = checkIfCanSubmit()
                if canSubmit {
                    showConfirmAlert = true
                } else {
                    showInputErrorMessage = true
                }
            } label: {
                Text("SUBMIT")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(5)
        }
        
        return AnyView(result)
    }
}

#Preview {
    NavigationView {
        SiteCaptainSubmissionView(
            site: Site(
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
            )
        )
    }
}
