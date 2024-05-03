//
//  SupplyRequestsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/27/24.
//

import SwiftUI

@MainActor
final class SupplyRequestsViewModel: ObservableObject {
    @Published var supplyRequests: [SupplyRequest] = []
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @Published var endDate = Date()
    @Published var isLoading = false
    @Published var hasLoadedOnce = false
    // report types
    @Published var siteCaptains: [SiteCaptain] = []
    @Published var siteReadys: [SiteReady] = []
    @Published var hourlyCleanings: [HourlyCleaning] = []
    
    // for labels
    var sites: [Site] = []
    var users: [DBUser] = []
    var supplyTypes: [SupplyType] = []
    
    func getSupplyRequests(completion: @escaping () -> Void) {
        Task {
            do {
                self.supplyRequests = try await SupplyRequestManager.shared.getAllSupplyRequests(descending: false, startDate: startDate, endDate: endDate)
            } catch {
                print("Error getting supply requests: \(error)")
            }
            completion()
        }
    }
    
    func swapSupplyRequestsOrder() {
        supplyRequests.reverse()
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            do {
                self.sites = try await SitesManager.shared.getAllSites(descending: false)
            } catch {
                print("Error fetching sites: \(error)")
            }
            completion()
        }
    }
    
    func getUsers(completion: @escaping () -> Void) {
        Task {
            do {
                self.users = try await UserManager.shared.getUsersList()
            } catch  {
                print("Error getting users: \(error)")
            }
            completion()
        }
    }
    
    func getSupplyTypes(completion: @escaping () -> Void) {
        Task {
            do {
                self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
            } catch  {
                print("Error getting supply types: \(error)")
            }
            completion()
        }
    }
    
    func loadReports(completion: @escaping () -> Void) {
        Task {
            for request in self.supplyRequests {
                if request.reportType == "site_captain" {
                    if let report: SiteCaptain = await getReport(type: ReportType.siteCaptain, id: request.reportId ?? "") {
                        siteCaptains.append(report)
                    }
                } else if request.reportType == "site_ready" {
                    if let report: SiteReady = await getReport(type: ReportType.siteReady, id: request.reportId ?? "") {
                        siteReadys.append(report)
                    }
                } else if request.reportType == "hourly_cleaning" {
                    if let report: HourlyCleaning = await getReport(type: ReportType.hourlyCleaning, id: request.reportId ?? "") {
                        hourlyCleanings.append(report)
                    }
                }
            }
            print("Got \(siteCaptains.count) site captains, \(siteReadys.count) site readys, \(hourlyCleanings.count) hourly cleanings.")
            completion()
        }
    }
    
    func getReport<T>(type: ReportType, id: String) async -> T? {
        do {
            switch type {
            case .siteCaptain:
                return try await SiteCaptainManager.shared.getSiteCaptain(siteCaptainId: id) as? T
            case .siteReady:
                return try await SiteReadyManager.shared.getSiteReady(siteReadyId: id) as? T
            case .hourlyCleaning:
                return try await HourlyCleaningManager.shared.getHourlyCleaning(hourlyCleaningId: id) as? T
            case .other:
                return nil
            }
        } catch {
            print("Error getting report: \(error)")
            return nil
        }
    }
    
    func toggleResolutionStatus(supplyRequest: SupplyRequest) {
        Task {
            do {
                try await SupplyRequestManager.shared.toggleResolution(supplyRequest: supplyRequest)
            } catch {
                print("Error toggling resolution: \(error)")
            }
        }
    }
    
    func deleteSupplyRequest(supplyRequestId: String) {
        Task {
            do {
                try await SupplyRequestManager.shared.deleteSupplyRequest(supplyRequestId: supplyRequestId)
            } catch {
                print("Error deleting supplyRequest: \(error)")
            }
        }
    }
    
    func deleteSupplyRequests(supplyRequestIds: [String]) {
        Task {
            do {
                try await SupplyRequestManager.shared.deleteSupplyRequests(supplyRequestIds: supplyRequestIds)
            } catch {
                print("Error deleting \(supplyRequestIds.count) supplyRequests: \(error)")
            }
        }
    }
}

struct SupplyRequestsView: View {
    // View Model
    @StateObject private var viewModel = SupplyRequestsViewModel()
    // View Control
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var hasLoadedOnce = false
    // https://sarunw.com/posts/swiftui-list-multiple-selection/
    @State private var multiSelection = Set<String>()
    // Alerts
    @State private var showAlert = false
    @State private var activateAlert: AlertType = .none
    enum AlertType {
        case deleteSupplyRequest, deleteSupplyRequests, none
    }
    @State private var selectedSupplyRequest: SupplyRequest? = nil
    @State private var selectedSupplyRequestIds: [String] = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
    
    var body: some View {
        content
            .navigationTitle("Supply Requests")
            .onAppear {
                Task {
                    viewModel.getSites() {
                        viewModel.getUsers() {
                            viewModel.getSupplyTypes() {
                                fetchSupplyRequests() {
                                    viewModel.loadReports(){
                                        isLoading = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                switch activateAlert {
                case .deleteSupplyRequest:
                    return Alert(title: Text("Confirm Deletion"), message: Text("Are you sure you wish to delete this supply request? You cannot undo this action."), primaryButton: .default(Text("Cancel")) {
                        // dismiss alert
                        showAlert = false
                    }, secondaryButton: .destructive(Text("Delete")) {
                        if let supplyRequest = selectedSupplyRequest {
                            deleteRequest(supplyRequest: supplyRequest)
                        }
                    })
                case .deleteSupplyRequests:
                    return Alert(title: Text("Confirm Deletion"), message: Text("Are you sure you wish to delete \(selectedSupplyRequestIds.count) supply requests? You cannot undo this action."), primaryButton: .default(Text("Cancel")) {
                        // dismiss alert
                        showAlert = false
                    }, secondaryButton: .destructive(Text("Delete")) {
                        deleteSelectedRequests()
                    })
                case .none:
                    return Alert(title: Text("Error"), message: Text("Unexpected alert type"))
                }
            }
    }
    
    func fetchSupplyRequests(completion: @escaping () -> Void) {
        isLoading = true // Set isLoading to true when fetching
        Task {
            viewModel.getSupplyRequests {
                isLoading = false // Set isLoading to false after fetching
                hasLoadedOnce = true // Update hasLoadedOnce after fetching
                completion()
                print("Got \(viewModel.supplyRequests.count) supply requests.")
            }
        }
    }
    
    private var content: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                datePickers
                searchBar
                supplyRequestList
            }
        }
    }
    
    private var datePickers: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Date Range:")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                sortButton // Button to sort the supply requests
                fetchSupplyRequestsButton // Button to refresh the supply requests
            }
            
            HStack {
                // Start Date Picker
                HStack {
                    DatePicker(
                        "Start Date:",
                        selection: $viewModel.startDate,
                        in: ...viewModel.endDate,
                        displayedComponents: [.date]
                    ).labelsHidden()
                }
                
                Spacer()
                
                Text("to")
                
                Spacer()
                
                // End Date Picker
                HStack {
                    DatePicker(
                        "End Date:",
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var searchBar: some View {
        HStack(alignment: .center) {
            // Search Text Field
            TextField("Search Site", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }.padding(.horizontal)
    }
    
    private var fetchSupplyRequestsButton: some View {
        Button(action: {
            isLoading = true
            fetchSupplyRequests(){}
            hasLoadedOnce = true
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapSupplyRequestsOrder() // Toggle the sorting order
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    private var supplyRequestList: some View {
        List(selection: $multiSelection) {
            if viewModel.supplyRequests.isEmpty {
                Text("There are no supply requests for this date range.")
                    .foregroundColor(.gray)
            } else {
                ForEach(filteredSupplyRequests, id: \.id) { supplyRequest in
                    supplyRequestCellView(supplyRequest: supplyRequest)
                        .contextMenu {
                            // toggle resolution status
                            Button () {
                                toggleRequestResolution(supplyRequest: supplyRequest)
                            } label: {
                                Label(supplyRequest.resolved ?? false ? "Unresolve" : "Resolve", systemImage: supplyRequest.resolved ?? false ? "xmark.square" : "checkmark.square")
                            }
                            // delete issue
                            Button(role: .destructive) {
                                // update selected Issue to delete
                                selectedSupplyRequest = supplyRequest
                                // activate alert
                                activateAlert = .deleteSupplyRequest
                                showAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            if multiSelection.count > 0 {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    
                    Text("\(multiSelection.count) selections")
                    
                    Spacer()
                    
                    Button("Delete", role: .destructive) {
                        // define which issues to delete
                        selectedSupplyRequestIds = Array(multiSelection)
                        // activate alert
                        activateAlert = .deleteSupplyRequests
                        showAlert = true
                    }
                }
            }
        }
        .onChange(of: multiSelection) { oldValue, newValue in
            print(newValue)
        }
    }
    
    private var filteredSupplyRequests: [SupplyRequest] {
        // default list
        let defaultList = viewModel.supplyRequests.sorted { $0.dateCreated ?? Date() < $1.dateCreated ?? Date() }
        
        // return default if search is empty
        if searchText.isEmpty {
            return defaultList
        } else {
            // filter and sort supply requests by site name
            return viewModel.supplyRequests.filter { supplyRequest in
                if let siteId = supplyRequest.siteId {
                    // find the site name using siteId
                    if let siteName = viewModel.sites.first(where: { $0.id == siteId })?.name {
                        // compare site name to searchText
                        return siteName.localizedCaseInsensitiveContains(searchText)
                    } else {
                        // Site not found for the siteId, exclude this supply request
                        return false
                    }
                } else {
                    // If siteId is nil, exclude this supply request
                    return false
                }
            }
        }
    }
    
    private func supplyRequestCellView(supplyRequest: SupplyRequest) -> some View {
        let supplyTypeName = viewModel.supplyTypes.first { $0.id == supplyRequest.supplyTypeId }?.name ?? "N/A"
        let siteName = viewModel.sites.first { $0.id == supplyRequest.siteId }?.name ?? "N/A"
        let countNeeded = supplyRequest.countNeeded ?? 0
        var user = "N/A"
        var reportType = "Unknown"
        if supplyRequest.reportType == "site_captain" {
            reportType = "Site Captain"
            if let report = viewModel.siteCaptains.first(where: { $0.id == supplyRequest.reportId }) {
                user = viewModel.users.first { $0.id == report.user }?.fullName ?? "N/A"
                
            }
        }
        if supplyRequest.reportType == "site_ready" {
            reportType = "Site Ready"
            if let report = viewModel.siteReadys.first(where: { $0.id == supplyRequest.reportId }) {
                user = viewModel.users.first { $0.id == report.user }?.fullName ?? "N/A"
                
            }
        }
        if supplyRequest.reportType == "hourly_cleaning" {
            reportType = "Hourly Cleaning"
            if let report = viewModel.hourlyCleanings.first(where: { $0.id == supplyRequest.reportId }) {
                user = viewModel.users.first { $0.id == report.userId }?.fullName ?? "N/A"
                
            }
        }
        
        let view = VStack(alignment: .leading, spacing: 8) {
            HStack {
                // DATE CREATED
                Image(systemName: "calendar")
                Text("\(supplyRequest.dateCreated != nil ? dateFormatter.string(from: supplyRequest.dateCreated!) : "N/A")")
                // RESOLVED STATUS
                Image(systemName: supplyRequest.resolved ?? false ? "checkmark.circle.fill" : "xmark.square")
                    .foregroundColor(supplyRequest.resolved ?? false ? .green : .red)
                Text("\(supplyRequest.resolved ?? false ? "Resolved" : "Not Resolved")")
                // SITE
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                Text("\(siteName)")
            }
            HStack {
                // REPORT TYPE
                Image(systemName: "pencil.and.list.clipboard")
                Text("Report: \(reportType)")
                // USER SUBMITTED
                Image(systemName: user == "N/A" ? "person" : "person.fill")
                Text(user)
            }
            HStack {
                // SUPPLY TYPE
                Image(systemName: "cube.box")
                    .foregroundColor(.blue)
                Text("Supply: \(supplyTypeName)")
                // COUNT NEEDED
                Image(systemName: "number.circle")
                    .foregroundColor(.orange)
                Text("Count: \(countNeeded)")
            }
        }
        return AnyView(view)
    }
    
    func deleteRequest(supplyRequest: SupplyRequest) {
        // delete in Firestore
        viewModel.deleteSupplyRequest(supplyRequestId: supplyRequest.id)
        // delete in view (locally)
        if let index = viewModel.supplyRequests.firstIndex(where: { $0.id == supplyRequest.id }) {
            viewModel.supplyRequests.remove(at:index)
        }
    }
    
    func toggleRequestResolution(supplyRequest: SupplyRequest) {
        // toggle resolution status in Firestore
        viewModel.toggleResolutionStatus(supplyRequest: supplyRequest)
        // toggle resolution status in view (locally)
        if let index = viewModel.supplyRequests.firstIndex(where: { $0.id == supplyRequest.id }) {
            if supplyRequest.resolved != nil {
                if supplyRequest.resolved == true {
                    viewModel.supplyRequests[index].resolved = false
                } else {
                    viewModel.supplyRequests[index].resolved = true
                }
            } else {
                viewModel.supplyRequests[index].resolved = true
            }
        }
    }
    
    func deleteSelectedRequests() {
        // delete in view (locally)
        for selectedSupplyRequestId in selectedSupplyRequestIds {
            if let index = viewModel.supplyRequests.firstIndex(where: { $0.id == selectedSupplyRequestId }) {
                viewModel.supplyRequests.remove(at:index)
            }
        }
        // delete in Firestore
        viewModel.deleteSupplyRequests(supplyRequestIds: selectedSupplyRequestIds)
    }
}


#Preview {
    NavigationView {
        SupplyRequestsView()
    }
}
