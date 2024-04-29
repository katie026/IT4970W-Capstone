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
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -366, to: Date())!
    @Published var endDate = Date()
    @Published var isLoading = false
    @Published var hasLoadedOnce = false
    
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
}

struct SupplyRequestsView: View {
    // View Model
    @StateObject private var viewModel = SupplyRequestsViewModel()
    // View Control
    @State private var searchText = ""
    @State private var selectedSortOption: SortOption? // Define selectedSortOption
    @State private var hasLoadedOnce = false
    // Track loading status
    @State private var isLoading = true
    // sort/filter option
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
    
    // Define SortOption enum if not defined already
    enum SortOption {
        case date
        case status
    }
    
    var body: some View {
        // Content
        content
            .navigationTitle("Supply Requests")
            .onAppear {
                Task {
                    // Fetch supply requests when view appears
                    viewModel.getSupplyRequests {}
                }
            }
    }
        
    
    func fetchSupplyRequests() {
            
            viewModel.getSupplyRequests {
                print("Got \(viewModel.supplyRequests.count) supply requests.")
                isLoading = false
                
            }
        }
    

    
    private var content: some View {
        VStack {
            datePickers
            searchBar
            supplyRequestList
        }
    }
    
    private var sortPicker: some View {
        Picker("Sort by", selection: $selectedSortOption) {
            Text("Date").tag(SortOption.date)
            Text("Status").tag(SortOption.status)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
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
            viewModel.swapSupplyRequestsOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }

    
    private var supplyRequestList: some View {
        List {
            // Check if the supply requests have been loaded at least once
            if viewModel.hasLoadedOnce {
                // Check if there are no supply requests for the selected date range
                if viewModel.supplyRequests.isEmpty {
                    Text("There are no supply requests for this date range.")
                        .foregroundColor(.gray)
                } else {
                    // Display the list of supply requests
                    ForEach(filteredSupplyRequests(), id: \.id) { supplyRequest in
                        ScrollView(.horizontal) {
                            supplyRequestCellView(supplyRequest: supplyRequest)
                        }
                        .contextMenu {
                            // Add context menu actions here if needed
                        }
                    }
                }
            } else {
                // Show a message prompting the user to choose a date range and reload
                Text("Choose a date range and reload.")
                    .foregroundColor(.gray)
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
        
        // Sort based on selected option
        switch selectedSortOption {
        case .date:
            return filtered.sorted(by: { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date()) })
        case .status:
            return filtered.sorted(by: { ($0.resolved ?? false) == ($1.resolved ?? false) ? ($0.countNeeded ?? 0) < ($1.countNeeded ?? 0) : !($0.resolved ?? false) })
        case nil:
            return filtered // Handle the case when selectedSortOption is nil
        }
    }



        
    private func supplyRequestCellView(supplyRequest: SupplyRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                Text("Date Created: \(formattedDate(supplyRequest.dateCreated))")
            }
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(supplyRequest.resolved ?? false ? .green : .red)
                Text("Resolved: \(supplyRequest.resolved ?? false ? "Yes" : "No")")
            }
            HStack {
                Image(systemName: "square.and.pencil")
                Text("Report Type: \(supplyRequest.reportType ?? "N/A")")
            }
            HStack {
                Image(systemName: "cube.box")
                Text("Supply Type: \(supplyRequest.supplyType ?? "N/A")")
            }
            // Can add more information here as needed
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.vertical, 5)
        .padding(.horizontal)
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
