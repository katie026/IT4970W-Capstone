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
    @State var isLoading: Bool = true
    @State var submitButtonActive: Bool = false
    @State private var showIssuesSummary = false
    @State private var showLabelsSummary = false
    // Temporary variables
    @State private var errorMessage: String?
    @State private var selectedSupplyType: SupplyType?
    @State private var suppliesNeededCount: Int = 1 // Initialize with default value

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
            content
                // Title
                .navigationTitle("Site Captain")
                .alert(isPresented: $viewModel.showSubmissionConfirmation) {
                    Alert(title: Text("Submission Successful"),
                          message: Text("Your site captain entry has been submitted."),
                          dismissButton: .default(Text("OK"), action: {
                        viewModel.resetForm()
                    }))
                }
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
            // Subtitle
            HStack {
                Text("\(site.name ?? "N/A")")
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            siteCaptainForm
            submitButton()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private func firstOnAppear(completion: @escaping () -> Void) {
        viewModel.getSupplyTypes()
        viewModel.getIssueTypes()
        viewModel.getUser()
        viewModel.getSiteComputers(siteId: site.id) {}
        viewModel.selectedThingsToClean = Array(repeating: false, count: viewModel.thingsToClean.count)
        viewModel.selectedThingsToDo = Array(repeating: false, count: viewModel.thingsToDo.count)
        
        completion()
    }

    private func submitSiteCaptain() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Unable to get current user information."
            return
        }

        if let selectedSupplyType = selectedSupplyType {
            viewModel.addSupply(supply: selectedSupplyType, count: suppliesNeededCount)
        }

        viewModel.submitSiteCaptainEntry(
            site: site,
            userId: currentUser.uid
        )
    }
    
    private func checkIfCanSubmit() {
        if (
            // checked each cleaning to do
            viewModel.selectedThingsToClean.allSatisfy({ $0 == true }) &&
            // checked each to do
            viewModel.selectedThingsToDo.allSatisfy({ $0 == true }) &&
            // check issues are filled out
            (viewModel.issues.allSatisfy({ $0.issueTypeId != nil }) && viewModel.issues.allSatisfy({ $0.ticket != nil }) && viewModel.issues.allSatisfy({ $0.description != nil })) &&
            // check labels are filled out
            viewModel.labelIssues.allSatisfy({ $0.description != nil }) &&
            // either has no inventory or has submitted an entry
            (site.hasInventory == false || viewModel.inventorySubmitted == true)
        ) {
            // they can submit
            submitButtonActive = true
        } else {
            // otherwise they can't
            submitButtonActive = false
        }
        
    }
    
    private var siteCaptainForm: some View {
        Form {
            // To Do Lists
            thingsToCleanSection
            thingsToDoSection
            // Issues
            issuesSection
            // Labels
            if viewModel.computers.count > 0 { //TODO: OR if printers > 0
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
        }
    }
    
    var thingsToCleanSection: some View {
        Section("Things to Clean") {
            ForEach(viewModel.thingsToClean.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.selectedThingsToClean[index].toggle()
                        checkIfCanSubmit()
                    }) {
                        Image(systemName: viewModel.selectedThingsToClean[index] ? "checkmark.square" : "square")
                    }
                    Text(viewModel.thingsToClean[index])
                }
            }
        }
    }
    
    var thingsToDoSection: some View {
        Section("Things to Do") {
            ForEach(viewModel.thingsToDo.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.selectedThingsToDo[index].toggle()
                        checkIfCanSubmit()
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
        let id = issue.id
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
                        .frame(width: 200)
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
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
                    
                    // Ticket # input (if issue type is not a chair, label, or poster issue)
                    if (viewModel.issues[index].issueTypeId != "FldaGVfpPdQ57H7XsGOO" && viewModel.issues[index].issueTypeId != "GxFGSkbDySZmdkCFExt9" && viewModel.issues[index].issueTypeId != "wYJWtaj33rx4EIh6v9RY") {
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
        return AnyView(Section("Labels") {
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
        })
    }
    
    func labelInputSection() -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    // ask how many issues
                    Text("How many labels need replacement?")
                        .frame(width: 200)
                    Spacer()
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
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
                        //TODO: add printers
                        // computer options
                        ForEach(viewModel.computers) { computer in
                            Text(computer.name ?? "").tag(computer.name as String?)
                        }
                    }
                    .labelsHidden()
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
        let id = issue.id
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
                    .padding(.top)
                
                RadioButton(text: "Yes", isSelected: viewModel.inventorySubmitted) {
                    viewModel.inventorySubmitted = true
                }
                RadioButton(text: "No", isSelected: !viewModel.inventorySubmitted) {
                    viewModel.inventorySubmitted = false
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
                        HStack {
                            Picker("Supply Type", selection: $selectedSupplyType) {
                                Text("Supply Type").tag(nil as SupplyType?)
                                ForEach(SupplyTypeManager.shared.supplyTypes, id: \.self) { supplyType in
                                    Text(supplyType.name).tag(supplyType as SupplyType?)
                                }
                            }.labelsHidden()
                            Picker("Count", selection: $suppliesNeededCount) {
                                ForEach(1...10, id: \.self) { count in
                                    Text("\(count)")
                                }
                            }.labelsHidden()
                                .pickerStyle(MenuPickerStyle())
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                        }
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func submitButton() -> some View {
        let result = VStack {
            if submitButtonActive {
                Button(action: submitSiteCaptain) {
                    Text("SUBMIT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                Text("SUBMIT")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemGray4))
                    .cornerRadius(10)
                    .padding()
            }
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
