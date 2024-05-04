//
//  KeysView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/4/24.
//

import SwiftUI

@MainActor
final class KeysViewModel: ObservableObject {
    @Published var users: [DBUser] = []
    @Published var keySets: [KeySet] = []
    @Published var keys: [Key] = []
    @Published var keyTypes: [KeyType] = []
    @Published var buildings: [Building] = []
    
    func getUsers(completion: @escaping () -> Void) {
        Task {
            do {
                self.users = try await UserManager.shared.getUsersList()
                self.users = self.users.sorted{ $0.fullName ?? "" <  $1.fullName ?? "" }
            } catch  {
                print("Error getting users: \(error)")
            }
            completion()
        }
    }
    
    func getKeys(completion: @escaping () -> Void) {
        Task {
            do {
                // get key sets
                self.keySets = try await KeySetManager.shared.getAllKeySets(descending: false)
                self.keySets = self.keySets.sorted{ $0.name ?? "" <  $1.name ?? "" }
                
                // get keys
                self.keys = try await KeyManager.shared.getAllKeys(descending: false)
                
                // get key types
                self.keyTypes = try await KeyTypeManager.shared.getAllKeyTypes(descending: false)
            } catch {
                print("Error getting keys: \(error)")
            }
            completion()
        }
    }
    
    func getBuildings(completion: @escaping () -> Void) {
        Task {
            do {
                self.buildings = try await BuildingsManager.shared.getAllBuildings(descending: false, group: nil)
            } catch {
                print("Error getting buildings: \(error)")
            }
            completion()
        }
    }
}

struct KeysView: View {
    // ViewModel
    @StateObject private var viewModel = KeysViewModel()
    // View Control
    @State private var isLoading = true
    @State private var isExpanded = true
    @State private var searchText = ""
    @State private var searchOption: SearchOption = .keySetName
    
    enum SearchOption: String, CaseIterable, Hashable {
        case user // multiple choice
        case building // multiple choice
        case keySetName // search bar
        case keyType // multiple choice
        case keyCode // search bar
        
        var optionLabel: String {
            switch self {
            case .user: return "User"
            case .building: return "Building"
            case .keySetName: return "Key Set"
            case .keyType: return "Key Type"
            case .keyCode: return "Key Code"
            }
        }
    }
    
    var body: some View {
        content
            .navigationTitle("Key Sets")
            .onAppear {
                viewModel.getUsers {
                    viewModel.getBuildings {
                        viewModel.getKeys {
                            print("got \(viewModel.keys.count) keys")
                            print("got \(viewModel.keyTypes.count) key types")
                            print("got \(viewModel.keySets.count) key sets")
                            isLoading = false
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isExpanded ? "Collapse" : "Expand") {
                        isExpanded.toggle()
                    }
                }
            }
    }
    
    private var content: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.keySets, id: \.self) { keySet in
                        keySetCell(keySet: keySet)
                    }
                }
            }
        }
    }
    
    private func keySetCell(keySet: KeySet) -> some View {
        // get possible user that has key set
        let userName = viewModel.users.first(where: { $0.id == keySet.userId })?.fullName
        // get possible key set location
        var buildingName: String? = nil
        
        if let buildingId = keySet.buildingId {
            if keySet.staticLocation == true {
                if let name = viewModel.buildings.first(where: { $0.id == buildingId })?.name {
                    buildingName = name
                }
            }
        }
        
        // get keys in this key set
        let keys = viewModel.keys.filter { $0.keySet == keySet.id }
        // create dictionary to hold key type name and key code
        var keyPairs: [String:String] = [:]
        
        // populate dictionary
        for key in keys {
            if let keyTypeName = viewModel.keyTypes.first(where: { $0.id == key.keyType })?.name {
                keyPairs[keyTypeName] = key.keyCode
            }
        }
        
        // sort dictionary
        let sortedKeyPairs = keyPairs.sorted { $0.key > $1.key }
        
        let view = VStack(alignment: .leading) {
            // key set name
            HStack {
                Text("\(keySet.name ?? "No Name")").fontWeight(.bold)
                if let nickname = keySet.nickname {
                    Text(" (\(nickname))")
                }
            }
            // user
            if let userName = userName {
                HStack {
                    Image(systemName: "person.fill")
                    Text(userName)
                }
            }
            // building
            if let buildingName = buildingName {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(buildingName)
                }
            }
            // list of keys
            if sortedKeyPairs.count > 0 {
                DisclosureGroup("Keys", isExpanded: $isExpanded) {
                    VStack(alignment: .leading) {
                        ForEach(sortedKeyPairs.indices, id: \.self) { index in
                            let (key, value) = sortedKeyPairs[index]
                            Text("\(key): \(value)")
                        }
                    }
                }
            }
        }
        
        return AnyView(view)
    }
    
//    // sorted list of issues
//    private var sortedKeySets: [KeySet] {
//        // default list
//        let defaultList = viewModel.keySets
//        
//        // if search option requires search bar
//        if (searchOption == .keySetName || searchOption == .keyCode) {
//            // if nothing in search bar
//            if searchText.isEmpty {
//                // sort searchText
//                return defaultList
//            } else {
//                // check which search term is selected
//                if searchOption == .keyCode {
//                    // filter & sort keys by key code
//                    return viewModel.keys.filter {
//                        $0.keyCode?.localizedCaseInsensitiveContains(searchText) ?? false
//                    }.sorted { $0.keyCode?.localizedCaseInsensitiveCompare($1.keyCode ?? "") == .orderedAscending }
//                } else if searchOption == .keySetName {
//                    var filteredList: [Key] = []
//                    // if searchText is empty, return issues that are unassigned
//                    if searchText == "" {
//                        return viewModel.keys
//                            .filter { $0. == nil }
//                    }
//                    
//                    // else, filter the list by the user assigned names
//                    for issue in viewModel.issues {
//                        // for each issue, find the site name and compare to the searchText
//                        if let userName = viewModel.users.first(where: { $0.id == issue.userAssigned })?.fullName {
//                            if userName.localizedCaseInsensitiveContains(searchText) {
//                                filteredList.append(issue)
//                            }
//                        }
//                    }
//                    // then sort list by user assigned and return
//                    return filteredList.sorted { issue1, issue2 in
//                        guard let userName1 = viewModel.users.first(where: { $0.id == issue1.userAssigned })?.fullName, let userName2 = viewModel.users.first(where: { $0.id == issue2.userAssigned })?.fullName else {
//                            print("Error sorting issues: cannot find user name for \(issue1.id) or \(issue2.id).")
//                            return false
//                        }
//                        return userName1 < userName2
//                    }
//                } else {
//                    return defaultList
//                }
//            }
//        // if searching by KeyType
//        } else if searchOption == .issueType {
//            var filteredList = viewModel.issues
//            
//            // filter issues by issue type & sort by dateCreated
//            if optionIssueType != nil {
//                filteredList = viewModel.issues
//                    .filter { $0.issueTypeId ?? "" == optionIssueType?.id ?? "" }
//            }
//            
//            // return filteredList
//            return filteredList
//        // if searching by User
//        } else if searchOption == .resolutionStatus {
//            var filteredList = viewModel.issues
//            
//            if optionResolved {
//                // filter for resolved issues
//                filteredList = viewModel.issues.filter { $0.resolved ?? false == true }
//            } else if !optionResolved {
//                // filter for unresolved issues
//                filteredList = viewModel.issues.filter { $0.resolved ?? false == false }
//            }
//            
//            // return filteredList
//            return filteredList
//        // otherwise
//        } else {
//            return defaultList
//        }
//    }
}

#Preview {
    NavigationView {
        KeysView()
    }
}
