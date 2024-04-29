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
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
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
    
        func fetchSupplyRequests() {
                isLoading = true
                getSupplyRequests {
                    self.isLoading = false
                    self.hasLoadedOnce = true
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
    
    // Define SortOption enum if not defined already
    enum SortOption {
        case date
        case status
    }
    
    var body: some View {
            NavigationView { // Embed the view in a NavigationView
                // Content
                content
                    .navigationTitle("Supply Requests")
                    .navigationBarHidden(false) // Ensure navigation bar is visible
                    .onAppear {
                        // Fetch supply requests when view appears
                        viewModel.getSupplyRequests {}
                    }
            }
        }
    
    private var content: some View {
        ScrollView { // Wrap the content in a ScrollView
            VStack(spacing: 20) { // Adjust the spacing between elements
                datePickers
                searchBar
                supplyRequestList
            }
            .padding() // Add padding to the VStack
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
            self.viewModel.fetchSupplyRequests() // Use self.viewModel to access the view model
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
                ForEach(filteredSupplyRequests(), id: \.id) { supplyRequest in
                    supplyRequestCellView(supplyRequest: supplyRequest)
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
        VStack(alignment: .leading) {
            Text("Report Type: \(supplyRequest.reportType ?? "N/A")")
            Text("Date Created: \(formattedDate(supplyRequest.dateCreated))")
            Text("Resolved: \(supplyRequest.resolved ?? false ? "Yes" : "No")")
            Text("Supply Type: \(supplyRequest.supplyType ?? "N/A")") // Use supplyType property here
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
