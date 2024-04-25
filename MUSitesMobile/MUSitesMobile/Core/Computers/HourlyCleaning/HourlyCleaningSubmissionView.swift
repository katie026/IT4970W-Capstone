//
//  HourlyCleaningSubmissionView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/18/24.
//

import SwiftUI

@MainActor
final class HourlyCleaningSubmissionViewModel: ObservableObject {
    // Inventory Entry Default Values
    @Published var computingSite: Site? = nil // will be passed in from the View
    @Published var computers: [Computer] = []
//    @Published var issues: [Issue] = []
    @Published var cleanedComputers: [Computer] = [] // this is only ot hold updated levels
    @Published var resultMessage = ""
    
    func getSiteComputers(siteId: String, completion: @escaping () -> Void) {
        Task {
            do {
                self.computers = try await ComputerManager.shared.getAllComputers(descending: false, siteId: siteId)
            } catch {
                print("Error fetching computers: \(error)")
            }
            print("Got \(computers.count) computers.")
            completion()
        }
    }
    
    func sortCleanedComputersByName() {
        cleanedComputers = cleanedComputers.sorted { $0.name ?? "" < $1.name ?? ""}
    }
    
    func sortComputersByDate() {
        computers = computers.sorted { computer1, computer2 in
            // Get the dates to compare (use 1/1/2001 as the default date)
            let date1 = computer1.lastCleaned ?? Date(timeIntervalSinceReferenceDate: 0)
            let date2 = computer2.lastCleaned ?? Date(timeIntervalSinceReferenceDate: 0)
            
            // Compare the dates
            return date1 < date2 // descending dates
        }
    }
    
    func submitHourlyCleaning(completion: @escaping () -> Void) {
        Task {
            do {
                // create new document and get id from Firestore
                let hourlyCleaningId = try await HourlyCleaningManager.shared.getNewHourlyCleaningId()
                
                // get current user
                let user = try AuthenticationManager.shared.getAuthenticatedUser()
                
                // get ids of cleanedComputers
                let cleanedComputerIds: [String] = cleanedComputers.map { $0.id }

                
                // create a new HourlyCleaning struct for the current site
                if let siteId = computingSite?.id {
                    let hourlyCleaning = HourlyCleaning (
                        id: hourlyCleaningId,
                        timestamp: Date(),
                        userId: user.uid,
                        siteId: siteId,
                        cleanedComputerIds: cleanedComputerIds)
                    
                    // update hourlyCleaning entry document in Firestore
                    try await HourlyCleaningManager.shared.createHourlyCleaning(hourlyCleaning: hourlyCleaning)
                    print("Created hourly cleaning: \(hourlyCleaningId).")
                }
                
                // update .lastCleaned for each computer
                updateCleanedComputers()
                
                resultMessage = cleanedComputers.count == 1 ? "Successfully reported 1 cleaning." : "Successfully reported \(cleanedComputers.count) cleanings."
                
                // call completion handler upon successful creation
                completion()
            } catch {
                resultMessage = "An error occured! \(error)"
                print("Error creating new hourly cleaning entry: \(error)")
            }
        }
    }
    
    func updateCleanedComputers() {
        Task {
            // for each computer in cleanedComputers
            for index in self.cleanedComputers.indices {
                // update lastCleaned
                cleanedComputers[index].lastCleaned = Date()
            }
            try await ComputerManager.shared.updateComputers(cleanedComputers)
            print("Updated \(cleanedComputers.count) cleaned computers.")
        }
    }
}

struct HourlyCleaningSubmissionView: View {
    // View Model
    @StateObject private var viewModel = HourlyCleaningSubmissionViewModel()
    // View Control
    @Environment(\.presentationMode) var presentationMode
    @State private var showCleanedComputers = false
    // Alerts (only one alert per view) https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-multiple-alerts-in-a-single-view
    @State private var showConfirmAlert = false
    @State private var showResultAlert = false
    @State private var showNoCleaningsAlert = false
    
    // init
    let computingSite: Site
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/d/yy"
        return formatter
    }()
    
    var body: some View {
        VStack {
            content
        }
        // View Title
        .navigationTitle("Hourly Cleaning")
        .onAppear{
            assignSite {
                if let site = viewModel.computingSite {
                    viewModel.getSiteComputers(siteId: site.id) {}
                    viewModel.sortComputersByDate()
                }
            }
        }
        .alert(isPresented: $showResultAlert) {
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
    
    private var content: some View {
        VStack {
            // Subtitle
            HStack {
                Text("\(computingSite.name ?? "N/A")")
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            // Summary
            Form {
                // Submit Button
                submitButton()
                    .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                // Cleaned Computers
                cleanedComputersSection
                    .listRowBackground(Color(UIColor.systemGray6))
                    .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(height: showCleanedComputers ? 180 + (CGFloat(viewModel.cleanedComputers.count) * 50.0) : 180)
            .scrollContentBackground(.hidden)
            
            // Computers
            Form {
                computerListSection
                    .listRowBackground(Color(UIColor.systemGray6))
                    .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    private var computerListSection: some View {
        Section("All Computers") {
            List {
                // loop through computers
                ForEach(viewModel.computers) { computer in
                    computerRow(computer: computer)
                }
            }
        }
    }
    
    private func computerRow(computer: Computer) -> some View {
        var textColor: Color = .primary
        var daysSinceLastCleaned: Int = -1
        
        if let lastCleaned = computer.lastCleaned {
            daysSinceLastCleaned = Calendar.current.dateComponents([.day], from: lastCleaned, to: Date()).day ?? 0
            
            switch daysSinceLastCleaned {
            case ...4:
                textColor = .primary // cleaned within 4 days
            case 5...6:
                textColor = .yellow // cleaned between 5-6 days
            case 7...14:
                textColor = .orange // cleaned between 1-2 weeks
            case 15...:
                textColor = .red // hasn't been cleaned in over 2 weeks
            default:
                textColor = .primary
            }
        }
        
        let result = HStack {
            VStack(alignment: .leading) {
                // COMPUTER NAME
                Text(computer.name ?? "N/A")
                
                // LAST CLEANED
                if let lastCleaned = computer.lastCleaned {
                    Text("Last Cleaned: \(dateFormatter.string(from: lastCleaned)) (\(daysSinceLastCleaned) days)")
                        .font(.system(size: 12))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .frame(width: 200, alignment: .leading)
                } else {
                    Text("Last Cleaned: N/A")
                        .font(.system(size: 12))
                        .foregroundColor(textColor)
                }
            }.padding(.vertical, 1)
            
            Spacer()
            
            computerToggle(for: computer)
        }
        
        return AnyView(result)
    }
    
    private func computerToggle(for computer: Computer) -> some View {
        // create Cleaned toggle
        Toggle(isOn: Binding( // binding establishes two-way connection between view and the underlying data
            // returns boolean binding (toggle state)
            get: {
                // if this computer exists in cleanedComputers
                // it has been cleaned, return true
                viewModel.cleanedComputers.contains { $0.id == computer.id }
            },
            set: { cleaned in // sets boolean binding (toggle state), receives boolean parameter "cleaned"
                // if toggled on (cleaned)
                if cleaned {
                    // add computer to cleanedComputers if not already added
                    if !viewModel.cleanedComputers.contains(where: { $0.id == computer.id }) {
                        viewModel.cleanedComputers.append(computer)
                        viewModel.sortCleanedComputersByName()
                    }
                // if toggled off (not cleaned)
                } else {
                    // remove computer from cleanedComputers array if exists
                    if let index = viewModel.cleanedComputers.firstIndex(where: { $0.id == computer.id }) {
                        viewModel.cleanedComputers.remove(at: index)
                    }
                }
            }
        )) {
            // empty toggle label
        }
    }
    
    private var cleanedComputersSection: some View {
        Section("Summary") {
            DisclosureGroup(isExpanded: $showCleanedComputers,  content: {
                List {
                    // loop through computers
                    ForEach(viewModel.cleanedComputers) { computer in
                        Text(computer.name ?? "N/A")
                    }
                }
            }, label: {
                Text("**Cleaned Computers:** \(viewModel.cleanedComputers.count)")
            })
        }
        .alert(isPresented: $showNoCleaningsAlert) {
            Alert(
                title: Text("No Cleanings"),
                message: Text("You have not indicated any cleaned computers."),
                dismissButton: .default(Text("OK")) { }
            )
        }
    }
    
    private func submitButton() -> some View {
        // create button
        let result = Section {
            Button {
                if viewModel.cleanedComputers.count == 0 {
                    showNoCleaningsAlert = true
                } else {
                    showConfirmAlert = true
                }
            } label: {
                Text("SUBMIT")
                    .font(.title3)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.green)
        .alert(isPresented: $showConfirmAlert) {
            Alert(
                title: Text("Confirm Submission"),
                message: Text(viewModel.cleanedComputers.count == 1 ? "Are you sure you want to submit 1 cleaning?" : "Are you sure you want to submit **\(viewModel.cleanedComputers.count)** cleanings?"),
                primaryButton: .default(Text("Submit")) {
                    // submit the form
                    viewModel.submitHourlyCleaning {
                        showResultAlert = true
                    }
                },
                secondaryButton: .cancel(Text("Cancel")) {
                    // dismiss alert
                    showConfirmAlert = false
                }
            )
        }
        
        return AnyView(result)
    }
    
    private func assignSite(completion: @escaping () -> Void) {
        viewModel.computingSite = computingSite
        completion()
    }
}

#Preview {
    NavigationView {
        HourlyCleaningSubmissionView(computingSite: Site(
            id: "BezlCe1ospf57zMdop2z",
            name: "Bluford",
            buildingId: "SvK0cIKPNTGCReVCw7Ln",
            nearestInventoryId: "345",
            chairCounts: [ChairCount(count: 3, type: "physics_black")],
            siteTypeId: "Y3GyB3xhDxKg2CuQcXAA",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: false,
            namePatternMac: "CLARK-MAC-##",
            namePatternPc: "CLARK-PC-##",
            namePatternPrinter: "Clark Printer ##",
            calendarName: "cornell-hall-5-lab"
        ))
    }
}
