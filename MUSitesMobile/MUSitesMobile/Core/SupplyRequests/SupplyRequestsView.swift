////
////  SupplyRequestsView.swift
////  MUSitesMobile
////
////  Created by Katie Jackson on 4/27/24.
////
//
//import SwiftUI
//
//@MainActor
//final class SupplyRequestsViewModel: ObservableObject {
//    
//    @Published var requests: [SupplyRequest] = []
//    @Published var selectedSort = SortOption.descending
//    @Published var startDate = Calendar.current.date(byAdding: .day, value: -366, to: Date())!
//    @Published var endDate = Date()
//    
//    // for labels
//    var sites: [Site] = []
//    var users: [DBUser] = []
//    var supplyTypes: [SupplyType] = []
//    
//    func getSupplyRequests(completion: @escaping () -> Void) {
//        Task {
//            do {
//                self.requests = try await SupplyRequestManager.shared.getAllSupplyRequests(descending: selectedSort.sortDescending, startDate: startDate, endDate: endDate)
//            } catch {
//                print("Error getting requests: \(error)")
//            }
//            completion()
//        }
//    }
//    
//    func swapSupplyRequestsOrder() {
//        requests.reverse()
//    }
//    
//    func getSites(completion: @escaping () -> Void) {
//        Task {
//            do {
//                self.sites = try await SitesManager.shared.getAllSites(descending: false)
//            } catch {
//                print("Error fetching computing sites: \(error)")
//            }
//            completion()
//        }
//    }
//    
//    func getUsers() {
//        Task {
//            do {
//                self.users = try await UserManager.shared.getUsersList()
//            } catch  {
//                print("Error getting users: \(error)")
//            }
//        }
//    }
//    
//    func getSupplyRequestTypes() {
//        Task {
//            do {
//                self.supplyTypes = try await SupplyRequestTypeManager.shared.getAllSupplyRequestTypes(descending: false)
//            } catch  {
//                print("Error getting request types: \(error)")
//            }
//        }
//    }
//    
//    func toggleResolutionStatus(request: SupplyRequest) {
//        Task {
//            do {
//                try await SupplyRequestManager.shared.toggleSupplyRequestResolution(request: request)
//            } catch {
//                print("Error toggling request resolution: \(error)")
//            }
//        }
//    }
//}
//
//struct SupplyRequestsView: View {
//    // View Model
//    @StateObject private var viewModel = SupplyRequestsViewModel()
//    // View Control
//    @State private var searchText = ""
//    @State private var hasLoadedOnce = false
//    // Track loading status
//    @State private var isLoading = true
//    // sort/filter option
//    @State private var searchOption: SupplyRequestSearchOption = .description
//    @State private var optionResolved: Bool = false
//    @State private var optionSupplyRequestType: SupplyRequestType? = nil
//    // Date Formatter
//    let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "M/d/yy"
//        return formatter
//    }()
//    
//    // sorted list of requests
//    private var sortedSupplyRequests: [SupplyRequest] {
//        // default list
//        let defaultList = viewModel.requests
//        
//        // if search option requires search bar
//        if (searchOption == .description || searchOption == .userAssigned || searchOption == .userSubmitted || searchOption == .siteName) {
//            // if nothing in search bar
//            if searchText.isEmpty {
//                // sort requests by dateCreated
//                return defaultList
//            } else {
//                // check which search term is selected
//                if searchOption == .description {
//                    // filter & sort requests by description
//                    return viewModel.requests.filter {
//                        $0.description?.localizedCaseInsensitiveContains(searchText) ?? false
//                    }.sorted { $0.description?.localizedCaseInsensitiveCompare($1.description ?? "") == .orderedAscending }
//                } else if searchOption == .userAssigned {
//                    var filteredList: [SupplyRequest] = []
//                    // if searchText is empty, return requests that are unassigned
//                    if searchText == "" {
//                        return viewModel.requests
//                            .filter { $0.userAssigned == nil }
//                    }
//                    
//                    // else, filter the list by the user assigned names
//                    for request in viewModel.requests {
//                        // for each request, find the site name and compare to the searchText
//                        if let userName = viewModel.users.first(where: { $0.id == request.userAssigned })?.fullName {
//                            if userName.localizedCaseInsensitiveContains(searchText) {
//                                filteredList.append(request)
//                            }
//                        }
//                    }
//                    // then sort list by user assigned and return
//                    return filteredList.sorted { request1, request2 in
//                        guard let userName1 = viewModel.users.first(where: { $0.id == request1.userAssigned })?.fullName, let userName2 = viewModel.users.first(where: { $0.id == request2.userAssigned })?.fullName else {
//                            print("Error sorting requests: cannot find user name for \(request1.id) or \(request2.id).")
//                            return false
//                        }
//                        return userName1 < userName2
//                    }
//                } else if searchOption == .userSubmitted {
//                    var filteredList: [SupplyRequest] = []
//                    // filter list by user submitted
//                    for request in viewModel.requests {
//                        // for each request, find the site name and compare to the searchText
//                        if let userName = viewModel.users.first(where: { $0.id == request.userSubmitted })?.fullName {
//                            if userName.localizedCaseInsensitiveContains(searchText) {
//                                filteredList.append(request)
//                            }
//                        }
//                    }
//                    // sort list by user submitted
//                    return filteredList.sorted { request1, request2 in
//                        guard let userName1 = viewModel.users.first(where: { $0.id == request1.userSubmitted })?.fullName, let userName2 = viewModel.users.first(where: { $0.id == request2.userSubmitted })?.fullName else {
//                            print("Error sorting requests: cannot find user name for \(request1.id) or \(request2.id).")
//                            return false
//                        }
//                        return userName1 < userName2
//                    }
//                } else if searchOption == .siteName {
//                    var filteredList: [SupplyRequest] = []
//                    // filter list by site name
//                    for request in viewModel.requests {
//                        // for each request, find the site name and compare to the searchText
//                        if let siteName = viewModel.sites.first(where: { $0.id == request.siteId })?.name {
//                            if siteName.localizedCaseInsensitiveContains(searchText) {
//                                filteredList.append(request)
//                            }
//                        }
//                    }
//                    // sort list by site name
//                    return filteredList.sorted { request1, request2 in
//                        guard let siteName1 = viewModel.sites.first(where: { $0.id == request1.siteId })?.name, let siteName2 = viewModel.sites.first(where: { $0.id == request2.siteId })?.name else {
//                            print("Error sorting requests: cannot find siteName for \(request1.id) or \(request2.id).")
//                            return false
//                        }
//                        return siteName1 < siteName2
//                    }
//                } else {
//                    return defaultList
//                }
//            }
//        // if searching by SupplyRequestType
//        } else if searchOption == .requestType {
//            var filteredList = viewModel.requests
//            
//            // filter requests by request type & sort by dateCreated
//            if optionSupplyRequestType != nil {
//                filteredList = viewModel.requests
//                    .filter { $0.requestTypeId ?? "" == optionSupplyRequestType?.id ?? "" }
//            }
//            
//            // return filteredList
//            return filteredList
//        // if searching by resolution status
//        } else if searchOption == .resolutionStatus {
//            var filteredList = viewModel.requests
//            
//            if optionResolved {
//                // filter for resolved requests
//                filteredList = viewModel.requests.filter { $0.resolved ?? false == true }
//            } else if !optionResolved {
//                // filter for unresolved requests
//                filteredList = viewModel.requests.filter { $0.resolved ?? false == false }
//            }
//            
//            // return filteredList
//            return filteredList
//        // otherwise
//        } else {
//            return defaultList
//        }
//    }
//    
//    var body: some View {
//        // Content
//        content
//            .navigationTitle("Reported SupplyRequests")
//            .onAppear {
//                Task {
//                    //only really need to load these once per view session
//                    viewModel.getSites{}
//                    viewModel.getUsers()
//                    viewModel.getSupplyRequestTypes()
//                }
//            }
//    }
//    
//    func fetchSupplyRequests() {
//        Task {
//            // if arrays are empty, populate them
//            viewModel.getSupplyRequests {
//                print("Got \(viewModel.requests.count) requests.")
//                isLoading = false
//            }
//        }
//    }
//    
//    private var content: some View {
//        VStack {
//            datePickers
//            searchBar
//            requestList
//        }
//    }
//    
//    private var datePickers: some View {
//        VStack {
//            HStack(alignment: .center) {
//                Text("Date Range:")
//                    .font(.headline)
//                    .fontWeight(.medium)
//                Spacer()
//                sortButton
//                refreshButton
//            }.padding([.horizontal, .top])
//            
//            HStack {
//                HStack {
//                    DatePicker(
//                        "Start Date:",
//                        selection: $viewModel.startDate,
//                        in: ...viewModel.endDate,
//                        displayedComponents: [.date]
//                    ).labelsHidden()
//                }.padding(.horizontal)
//                
//                Spacer()
//                
//                Text("to").padding(.horizontal)
//                
//                Spacer()
//                
//                HStack {
//                    DatePicker(
//                        "End Date:",
//                        selection: $viewModel.endDate,
//                        in: viewModel.startDate...Date(),
//                        displayedComponents: [.date]
//                    )
//                    .labelsHidden()
//                }.padding(.horizontal)
//            }
//        }
//    }
//    
//    private var searchBar: some View {
//        HStack(alignment: .center) {
//            Menu {
//                Picker("Search Term", selection: $searchOption) {
//                    ForEach(SupplyRequestSearchOption.allCases, id: \.self) { option in
//                        Text(option.optionLabel)
//                        
//                    }
//                }.multilineTextAlignment(.leading)
//            } label: { HStack{
//                Text(searchOption.optionLabel)
//                Spacer()
//            } }
//            .frame(maxWidth: 100)
//            
//            if (searchOption == .description || searchOption == .userAssigned || searchOption == .userSubmitted || searchOption == .siteName) {
//                TextField("Search", text: $searchText)
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//            }
//            
//            if searchOption == .resolutionStatus {
//                Picker("Resolved", selection: $optionResolved) {
//                    Text("True").tag(true)
//                    Text("False").tag(false)
//                }.multilineTextAlignment(.leading)
//            }
//            
//            if searchOption == .requestType {
//                Picker("SupplyRequest Type", selection: $optionSupplyRequestType) {
//                    Text("Any").tag(nil as SupplyRequestType?)
//                    ForEach(viewModel.supplyTypes, id: \.self) { type in
//                        Text(type.name).tag(type as SupplyRequestType?)
//                    }
//                }.multilineTextAlignment(.leading)
//            }
//            
//            Spacer()
//        }.padding(.horizontal)
//    }
//    
//    private var requestList: some View {
//        List {
//            // if user hasn't loaded requests yet
//            if !hasLoadedOnce {
//                Text("Choose a date range and reload.")
//                    .foregroundColor(.gray)
//                // else, if they have, but there are still no entries
//            } else if (hasLoadedOnce && viewModel.requests.count == 0) {
//                Text("There are no requests for this date range.")
//                    .foregroundColor(.gray)
//            }
//            
//            ForEach(sortedSupplyRequests, id: \.id) { request in
//                ScrollView(.horizontal) {
//                        requestCellView(request: request)
//                }
//                .contextMenu {
//                    // toggle reoslution status
//                    Button (request.resolved ?? false ? "Unresolve" : "Resolve") {
//                        // toggle resolution status in Firestore
//                        viewModel.toggleResolutionStatus(request: request)
//                        // toggle resolution status in view (locally)
//                        if let index = viewModel.requests.firstIndex(where: { $0.id == request.id }) {
//                            if request.resolved != nil {
//                                if request.resolved == true {
//                                    viewModel.requests[index].resolved = false
//                                } else {
//                                    viewModel.requests[index].resolved = true
//                                }
//                            } else {
//                                viewModel.requests[index].resolved = false
//                            }
//                        }
//                    }
//                }
//            }
//        }.listStyle(.insetGrouped)
//    }
//    
//    private var refreshButton: some View {
//        Button(action: {
//            isLoading = true
//            fetchSupplyRequests()
//            hasLoadedOnce = true
//        }) {
//            Image(systemName: "arrow.clockwise")
//                .font(.system(size: 20))
//        }
//    }
//    
//    private var sortButton: some View {
//        Button(action: {
//            viewModel.swapSupplyRequestsOrder()
//        }) {
//            Image(systemName: "arrow.up.arrow.down.circle")
//                .font(.system(size: 20))
//                .padding(.trailing, 10)
//        }
//    }
//    
//    private func requestCellView(request: SupplyRequest) -> some View {
//        let siteName = viewModel.sites.first { $0.id == request.siteId }?.name ?? "N/A"
//        let userSubmittedName = viewModel.users.first { $0.userId == request.userSubmitted }?.fullName ?? "N/A"
//        let userAssignedName = viewModel.users.first { $0.userId == request.userAssigned }?.fullName ?? "N/A"
//        
//        let view = VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                // DATE
//                Image(systemName: "calendar")
//                Text("\(request.dateCreated != nil ? dateFormatter.string(from: request.dateCreated!) : "N/A")")
//                // RESOLUTION STATUS
//                requestResolvedSection(request: request)
//                // SITE
//                Image(systemName: "mappin.and.ellipse")
//                    .padding(.leading,20)
//                    .foregroundColor(Color.red)
//                Text("\(siteName)")
//            }
//            HStack {
//                // TYPE
//                requestTypeSection(request: request)
//                // USER ASSIGNED
//                if request.userAssigned == nil || request.userAssigned == "" {
//                    Image(systemName: "person")
//                } else {
//                    Image(systemName: "person.fill")
//                }
//                Text("\(userAssignedName)")
//            }
//            // DESCRIPTION
//            //TODO: consider shortening description if it's a certain amount of characters and redirect to a detailed view (or trigger pop up/long hold etc.)
//            // if description is not nil
//            if let description = request.description {
//                // and is not empty
//                if description != "" {
//                    // show description section
//                    HStack {
//                        Image(systemName: "bubble")
//                        Text("\(userSubmittedName): \(description)")
//                    }
//                }
//            }
//        }
//        
//        return AnyView(view)
//    }
//    
//    private func requestTypeSection(request: SupplyRequest) -> some View {
//        let typeName = viewModel.supplyTypes.first { $0.id == request.requestTypeId }?.name ?? "N/A"
//        
//        // default accent color
//        var requestTypeAccentColor = Color.gray
//        // default image
//        var requestTypeImageName = "square.dotted"
//        
//        // customize color and image based on Type
//        if let requestType = request.requestTypeId {
//            if requestType == "FldaGVfpPdQ57H7XsGOO" { // Chair
//                requestTypeAccentColor = Color.green
//                requestTypeImageName = "chair"
//            } else if requestType == "zpavvVHHgI3S3qujebnW" { // Classroom Equip
//                requestTypeAccentColor = Color.orange
//                requestTypeImageName = "videoprojector"
//            } else if requestType == "GxFGSkbDySZmdkCFExt9" { // Label
//                requestTypeAccentColor = Color.purple
//                requestTypeImageName = "tag"
//            } else if requestType == "wYJWtaj33rx4EIh6v9RY" { // Poster
//                requestTypeAccentColor = Color.blue
//                requestTypeImageName = "doc.richtext"
//            } else if requestType == "r6jx5SXc0x2OC7bM8XNN" { // SitesTech
//                requestTypeAccentColor = Color.yellow
//                requestTypeImageName = "hammer.fill"
//            }
//        }
//        
//        // return section
//        return HStack {
//            Image(systemName: requestTypeImageName)
//                .foregroundColor(requestTypeAccentColor)
//            Text("\(typeName)")
//                .padding(.vertical, 3)
//                .padding(.horizontal, 5)
//                .foregroundColor(requestTypeAccentColor)
//                .cornerRadius(8)
//        }
//    }
//    
//    private func requestResolvedSection(request: SupplyRequest) -> some View {
//        // default accent color
//        var resolvedAccentColor = Color.gray
//        // default image
//        var resolvedImageName = "square.dotted"
//        
//        // customize color and image based on Type
//        if let resolved = request.resolved {
//            // if resolved
//            if resolved == true {
//                resolvedAccentColor = Color.green
//                resolvedImageName = "checkmark.circle"
//            // if not resolved
//            } else {
//                resolvedAccentColor = Color.red
//                resolvedImageName = "xmark.app"
//            }
//        }
//        
//        // return section
//        return HStack {
//            Image(systemName: resolvedImageName)
//                .foregroundColor(resolvedAccentColor)
//                .padding(.leading, 15)
//            if let resolved = request.resolved {
//                Text(resolved ? "Resolved" : "Unresolved")
//                    .padding(.vertical, 3)
//                    .padding(.horizontal, 5)
//            } else {
//                Text("N/A")
//                    .padding(.vertical, 3)
//                    .padding(.horizontal, 5)
//            }
//        }
//    }
//}
//
//#Preview {
//    SupplyRequestsView()
//}
