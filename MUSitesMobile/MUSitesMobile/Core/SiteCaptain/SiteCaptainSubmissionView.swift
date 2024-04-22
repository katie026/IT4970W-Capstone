//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI
import FirebaseAuth

struct SiteCaptainSubmissionView: View {
    var siteId: String
    var siteName: String
    @StateObject private var viewModel = SiteCaptainViewModel()
    @State private var errorMessage: String?
    @State private var selectedSupplyType: SupplyType?
    @State private var needsSupplies: Bool = false
    @State private var suppliesNeededCount: Int = 1 // Initialize with default value
    @State var issueCount = ""
    
    let thingsToClean = [
        "Wipe down the keyboards, mice, all desks, and monitors for each workstation",
        "Wipe down the printer",
        "Tidy up the cords",
        "Push in the chairs",
        "Ensure every computer has a chair",
        "Fill the printer with paper",
        "Clean whiteboard (if there is one)"
    ]
    
    let thingsToDo = [
        "Check the projector (if there is one)",
        "Check the dry erase markers",
        "Check the classroom calendars are up to date (if not, contact a CS)",
        "Remove non-DoIT posters from the classroom poster board"
    ]

    var body: some View {
        VStack {
            // Subtitle
            HStack {
                Text("\(siteName)")
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
        .onAppear {
            viewModel.getSupplyTypes()
            viewModel.getIssueTypes()
            viewModel.getUser()
        }
    }

    func submitSiteCaptain() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Unable to get current user information."
            return
        }

        if let selectedSupplyType = selectedSupplyType {
            viewModel.addSupply(supply: selectedSupplyType, count: suppliesNeededCount)
        }

        viewModel.issues.enumerated().forEach { index, issue in
            guard let selectedIssueType = viewModel.issues[index].issueType else {
                return
            }
            let issueType = IssueTypeManager.shared.issueTypes.first { $0.name == selectedIssueType }
            viewModel.addIssue(issue: viewModel.issues[index], issueType: issueType)
        }

        viewModel.submitSiteCaptainEntry(
            for: siteId,
            siteName: siteName,
            userId: currentUser.uid
        )
    }
    
    func checkIfCanSubmit() {
        if (
            viewModel.selectedThingsToClean.allSatisfy({ $0 == true }) &&
            viewModel.selectedThingsToDo.allSatisfy({ $0 == true })
        ) {
            viewModel.submitButtonActive = true
        } else {
            viewModel.submitButtonActive = false
        }
        
    }
    
    private var siteCaptainForm: some View {
        Form {
            thingsToCleanSection
            
            thingsToDoSection
            
            needsRepairSection
            
            labelsSection
            
            inventorySection
            
            if viewModel.hasInventoryLocation {
                supplySection
            }
        }
    }
    
    var thingsToCleanSection: some View {
<<<<<<< HEAD
//        VStack(alignment: .leading)
=======
//        VStack(alignment: .leading) 
>>>>>>> hourly-cleaning
        Section("Things to Clean") {
            ForEach(thingsToClean.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.selectedThingsToClean[index].toggle()
                        checkIfCanSubmit()
                    }) {
                        Image(systemName: viewModel.selectedThingsToClean[index] ? "checkmark.square" : "square")
                    }
                    Text(thingsToClean[index])
                }
            }
        }
    }
    
    var thingsToDoSection: some View {
        //VStack(alignment: .leading)
        Section("Things to Do") {
//            Text("Things to do:")
//                .font(.headline)
//                .padding(.top)
            
            ForEach(thingsToDo.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        viewModel.selectedThingsToDo[index].toggle()
                        checkIfCanSubmit()
                    }) {
                        Image(systemName: viewModel.selectedThingsToDo[index] ? "checkmark.square" : "square")
                    }
                    Text(thingsToDo[index])
                }
            }
        }
    }
    
    var needsRepairSection: some View {
//        VStack(alignment: .leading)
        Section("Repairs") {
            Text("Is there anything that needs repair? (clock, keyboard, mouse, projector, missing chairs, etc.)")
            
            RadioButton(text: "Nope, all is good.", isSelected: !viewModel.needsRepair) {
                viewModel.needsRepair = false
            }
            RadioButton(text: "Yes, things are not quite right.", isSelected: viewModel.needsRepair) {
                viewModel.needsRepair = true
            }
            
            if viewModel.needsRepair {
                issuesSection()
                // add a button to dismiss keypad when needed
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
            
            ForEach(viewModel.issues.indices, id: \.self) { index in
                let issue = viewModel.issues[index]
                Text("\(issue.id)")
            }
        }
    }
    
    func issuesSection() -> some View {
        let view = Section() {
            VStack(alignment: .leading) {
                Text("How many issues are there in your site?")
                TextField("#", text: Binding(
                    get: { String(issueCount) },
                    set: { newValue in
<<<<<<< HEAD
                        if let count = Int(newValue), count >= 0 && count <= 100 {
                            issueCount = newValue
                            let userId = viewModel.user?.uid ?? ""  // Handle nil case for viewModel.user
                            viewModel.issues = Array(repeating: Issue(
                                id: "",
                                description: nil,
                                timestamp: Date(),
                                issueType: nil,
                                resolved: false,
                                ticket: nil,
                                reportId: nil,
                                reportType: "site_captain",
                                siteId: siteId,
                                userSubmitted: userId,
                                userAssigned: nil
                            ), count: count)
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)

=======
                        issueCount = newValue
                        viewModel.issues = Array(repeating: Issue(
                            id: "",
                            description: nil,
                            timestamp: Date(),
                            issueType: nil,
                            resolved: false,
                            ticket: nil,
                            reportId: nil,
                            reportType: "site_captain",
                            siteId: siteId,
                            userSubmitted: viewModel.user?.uid,
                            userAssigned: nil
                        ), count: Int(issueCount) ?? 0)
                        viewModel.issues.enumerated().forEach { index, _ in
                            viewModel.issues[index].id = "\(index)"
                        }
                    }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.numberPad)
                
>>>>>>> hourly-cleaning
                ForEach(0..<(viewModel.issues.count), id: \.self) { index in
                    issueRow(index: index)
                }
            }
        }
<<<<<<< HEAD

=======
        
>>>>>>> hourly-cleaning
        return AnyView(view)
    }
    
    func issueRow(index: Int) -> some View {
<<<<<<< HEAD
        guard viewModel.issues.indices.contains(index) else {
            return AnyView(Text("Invalid index"))
        }

        return AnyView(Section {
            VStack(alignment: .leading) {
                HStack {
                    Picker("Issue Type", selection: Binding(
                        get: { viewModel.issues[index].issueType },
                        set: { newValue in
                            viewModel.issues[index].issueType = newValue
                        }
                    )) {
                        Text("Select Issue Type").tag(nil as String?)
                        ForEach(IssueTypeManager.shared.issueTypes, id: \.self) { issueType in
                            Text(issueType.name).tag(issueType.name as String?)
                        }
                    }
                    .labelsHidden()

                    TextField("7-digit ticket # if needed", value: Binding(
                        get: { viewModel.issues[index].ticket?.description ?? "" },
                        set: { newValue in
                            if let value = Int(newValue) {
                                viewModel.issues[index].ticket = value
                            } else {
                                viewModel.issues[index].ticket = nil
                            }
                        }
                    ), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.numberPad)
                }

                TextField("Description", text: Binding(
                    get: { viewModel.issues[index].description ?? "" },
                    set: { newValue in
                        viewModel.issues[index].description = newValue
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
        })
    }


=======
        var view = Section() {
            VStack(alignment: .leading) {
                HStack {
                    Picker("Issue Type", selection: $viewModel.issues[index].issueType) {
                        Text("Issue Type").tag(nil as IssueType?)
                        ForEach(IssueTypeManager.shared.issueTypes, id: \.self) { issueType in
                            Text(issueType.name).tag(issueType as IssueType?)
                        }
                    }.labelsHidden()
                    TextField("7-digit ticket # if needed", value: $viewModel.issues[index].ticket, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)
                    
                }
                
                TextField("Description", text: Binding(
                    get: { viewModel.issues[index].description ?? "" }, // if description is nil
                    set: { newValue in viewModel.issues[index].description = newValue }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
        }
        
//        let issue = Issue(
//            id: String(index),
//            description: description == "" ? nil : description,
//            timestamp: Date(),
//            issueType: issueType == "" ? nil : issueType,
//            resolved: false,
//            ticket: ticket == "" ? nil : Int(ticket),
//            reportId: nil,
//            reportType: "site_captain",
//            siteId: siteId,
//            userSubmitted: viewModel.user?.uid,
//            userAssigned: nil
//        )
        
        return AnyView(view)
    }
>>>>>>> hourly-cleaning
    
    func updateIssue(_ issue: Issue) {
        if (issue.description != nil), (issue.issueType != nil), (issue.ticket != nil) {
            // Append or update issue in viewModel.issues
            if let index = viewModel.issues.firstIndex(where: { $0.id == issue.id }) {
                viewModel.issues[index] = issue
            } else {
                viewModel.issues.append(issue)
            }
        } else {
            // Remove issue from viewModel.issues
            viewModel.issues.removeAll { $0.id == issue.id }
        }
    }
    
    var labelsSection: some View {
<<<<<<< HEAD
//        VStack(alignment: .leading)
=======
//        VStack(alignment: .leading) 
>>>>>>> hourly-cleaning
        Section("Labels") {
            Text("Are there any table or printer labels that need to be replaced?")
            
            RadioButton(text: "Nope, all is good.", isSelected: !viewModel.needsLabelReplacement) {
                viewModel.needsLabelReplacement = false
            }
            RadioButton(text: "Yes, I contacted a CS about it.", isSelected: viewModel.needsLabelReplacement) {
                viewModel.needsLabelReplacement = true
            }
            
            if viewModel.needsLabelReplacement {
                VStack(alignment: .leading) {
                    Text("Which labels need to be replaced?")
                    
                    TextField("Enter the labels that need replacement", text: $viewModel.labelsToReplace)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            }
        }
    }
    
    var inventorySection: some View {
<<<<<<< HEAD
//        VStack(alignment: .leading)
=======
//        VStack(alignment: .leading) 
>>>>>>> hourly-cleaning
        Section("Inventory") {
            Text("Does your site building have a cabinet/inventory location?")
            
            RadioButton(text: "Yes", isSelected: viewModel.hasInventoryLocation) {
                viewModel.hasInventoryLocation = true
            }
            RadioButton(text: "No", isSelected: !viewModel.hasInventoryLocation) {
                viewModel.hasInventoryLocation = false
            }
            
            if viewModel.hasInventoryLocation {
                Text("Did you check the inventory?")
                    .padding(.top)
                
                RadioButton(text: "Yes", isSelected: viewModel.inventoryChecked) {
                    viewModel.inventoryChecked = true
                }
                RadioButton(text: "No", isSelected: !viewModel.inventoryChecked) {
                    viewModel.inventoryChecked = false
                }
            }
        }
    }
        
    var supplySection: some View {
        Section("Supplies") {
            Text("Are there any supplies needed for your site?")
            
            RadioButton(text: "No", isSelected: !needsSupplies) {
                needsSupplies = false
                selectedSupplyType = nil
            }
            RadioButton(text: "Yes", isSelected: needsSupplies) {
                needsSupplies = true
            }
            
            if needsSupplies {
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
    }
    
    private func submitButton() -> some View {
        let result = VStack {
            if viewModel.submitButtonActive {
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
            siteId: "BezlCe1ospf57zMdop2z",
            siteName: "Bluford"
        )
    }
}
