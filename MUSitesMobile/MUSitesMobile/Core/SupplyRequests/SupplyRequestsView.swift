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
    
    func getUsers() {
        Task {
            do {
                self.users = try await UserManager.shared.getUsersList()
            } catch  {
                print("Error getting users: \(error)")
            }
        }
    }
    
    func getSupplyTypes() {
        Task {
            do {
                self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
            } catch  {
                print("Error getting supply types: \(error)")
            }
        }
    }
}



struct SupplyRequestsView: View {
    @StateObject private var viewModel = SupplyRequestsViewModel()
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var hasLoadedOnce = false


    
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
                    await viewModel.getSites {
                        // Empty completion handler
                    }
                    viewModel.getUsers()
                    await viewModel.getSupplyTypes() // Ensure supply types are fetched before rendering cells
                    fetchSupplyRequests() // Fetch supply requests after fetching supply types
                }
            }

    }


    
    func fetchSupplyRequests() {
        isLoading = true // Set isLoading to true when fetching
        Task {
            viewModel.getSupplyRequests {
                isLoading = false // Set isLoading to false after fetching
                hasLoadedOnce = true // Update hasLoadedOnce after fetching
                print("Got \(viewModel.supplyRequests.count) supply requests.")
            }
        }
    }


    
    private var content: some View {
        VStack {
            datePickers
            searchBar
            supplyRequestList
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
            }.padding([.horizontal, .top])
            
            HStack {
                // Start Date Picker
                HStack {
                    DatePicker(
                        "Start Date:",
                        selection: $viewModel.startDate,
                        in: ...viewModel.endDate,
                        displayedComponents: [.date]
                    ).labelsHidden()
                }.padding(.horizontal)
                
                Spacer()
                
                Text("to").padding(.horizontal)
                
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
                }.padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }


    
    private var searchBar: some View {
        HStack {
            // Search Text Field
            TextField("Search", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var fetchSupplyRequestsButton: some View {
        Button(action: {
            isLoading = true
            fetchSupplyRequests()
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
        List {
            if viewModel.supplyRequests.isEmpty {
                Text("There are no supply requests for this date range.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.supplyRequests, id: \.id) { supplyRequest in
                    supplyRequestCellView(supplyRequest: supplyRequest)
                        .contextMenu {
                            // Add context menu actions here if needed
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
    }




    
        
    private func filteredSupplyRequests() -> [SupplyRequest] {
        // Filter based on search text
        let filtered = viewModel.supplyRequests.filter {
            if let reportType = $0.reportType {
                return reportType.localizedCaseInsensitiveContains(searchText)
            } else {
                return false // Or handle the case when reportType is nil
            }
        }
        
        // No sorting logic based on selectedSortOption anymore
        
        return filtered
    }



        
    private func supplyRequestCellView(supplyRequest: SupplyRequest) -> some View {
        // Fetch supply type asynchronously
        let supplyTypeName: String = {
            if let supplyTypeID = supplyRequest.supplyType {
                if let supplyType = viewModel.supplyTypes.first(where: { $0.id == supplyTypeID }) {
                    return supplyType.name ?? "N/A"
                } else {
                    // If supply type not found, handle error or return default value
                    return "N/A"
                }
            } else {
                // If supply type ID is nil, handle error or return default value
                return "N/A"
            }
        }()
        
        let countNeeded = supplyRequest.countNeeded ?? 0
        
        let view = VStack(alignment: .leading, spacing: 8) {
            HStack {
                // DATE CREATED
                Image(systemName: "calendar")
                Text("Date Created: \(formattedDate(supplyRequest.dateCreated))")
            }
            HStack {
                // RESOLVED STATUS
                Image(systemName: supplyRequest.resolved ?? false ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(supplyRequest.resolved ?? false ? .green : .red)
                Text("Resolved: \(supplyRequest.resolved ?? false ? "Yes" : "No")")
            }
            HStack {
                // REPORT TYPE
                Image(systemName: "square.and.pencil")
                Text("Report Type: \(supplyRequest.reportType ?? "N/A")")
            }
            HStack {
                // SUPPLY TYPE
                Image(systemName: "cube.box")
                Text("Supply Type: \(supplyTypeName)")
            }
            HStack {
                // COUNT NEEDED
                Image(systemName: "number.circle")
                Text("Count Needed: \(countNeeded)")
            }
            // Add more information here as needed
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.vertical, 5)
        .padding(.horizontal)
        
        return AnyView(view)
    }




        
        private func formattedDate(_ date: Date?) -> String {
        guard let date = date else {
            return "N/A"
            }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
        }

    }


struct SupplyRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        SupplyRequestsView()
    }
}
