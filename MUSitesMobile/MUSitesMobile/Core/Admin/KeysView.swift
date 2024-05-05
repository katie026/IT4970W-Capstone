//
//  KeysView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/4/24.
//

import SwiftUI

// ViewModel for the KeysView
@MainActor
final class KeysViewModel: ObservableObject {
    @Published var users: [DBUser] = []
    @Published var keySets: [KeySet] = []
    @Published var keys: [Key] = []
    @Published var keyTypes: [KeyType] = []
    @Published var buildings: [Building] = []
    @Published var selectedSort = SortOption.ascending
    
    // Fetch users from the UserManager
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
    
    // Fetch keys, key sets, and key types from the respective managers
    func getKeys(completion: @escaping () -> Void) {
        Task {
            do {
                // Get key sets
                self.keySets = try await KeySetManager.shared.getAllKeySets(descending: false)
                self.keySets = self.keySets.sorted{ $0.name ?? "" <  $1.name ?? "" }
                
                // Get keys
                self.keys = try await KeyManager.shared.getAllKeys(descending: false)
                
                // Get key types
                self.keyTypes = try await KeyTypeManager.shared.getAllKeyTypes(descending: false)
            } catch {
                print("Error getting keys: \(error)")
            }
            completion()
        }
    }
    
    // Fetch buildings from the BuildingsManager
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

// Extension to make the Building struct conform to Hashable
extension Building: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Extension to make the KeyType struct conform to Hashable
extension KeyType: Hashable {
    static func == (lhs: KeyType, rhs: KeyType) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
    @State private var optionUser: DBUser? = nil
    @State private var optionBuilding: Building? = nil
    @State private var optionKeyType: KeyType? = nil
    
    // SearchOption enum for different search options
    enum SearchOption: String, CaseIterable, Hashable {
        case user // multiple choice
        case building // multiple choice
        case keySetName // search bar
        case keyType // multiple choice
        case keyCode // search bar
        
        // Computed property to get the label for each search option
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
        VStack {
            searchBar
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(sortedKeySets, id: \.self) { keySet in
                        keySetCell(keySet: keySet)
                    }
                }
            }
        }
        .navigationTitle("Key Sets")
        .onAppear {
            // Fetch users, buildings, and keys when the view appears
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
    
    // Search bar view
    private var searchBar: some View {
        HStack(alignment: .center) {
            Menu {
                Picker("Search Term", selection: $searchOption) {
                    ForEach(SearchOption.allCases, id: \.self) { option in
                        Text(option.optionLabel)
                    }
                }.multilineTextAlignment(.leading)
            } label: { HStack {
                Text(searchOption.optionLabel)
                Spacer()
            } }
            .frame(maxWidth: 120)
            
            if searchOption == .keySetName || searchOption == .keyCode {
                TextField("Search", text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if searchOption == .user {
                Picker("User", selection: $optionUser) {
                    Text("Any").tag(nil as DBUser?)
                    ForEach(viewModel.users, id: \.self) { user in
                        Text(user.fullName ?? "").tag(user as DBUser?)
                    }
                }.multilineTextAlignment(.leading)
            }
            
            if searchOption == .building {
                Picker("Building", selection: $optionBuilding) {
                    Text("Any").tag(nil as Building?)
                    ForEach(viewModel.buildings, id: \.id) { building in
                        Text(building.name ?? "").tag(building as Building?)
                    }
                }.multilineTextAlignment(.leading)
            }
            
            if searchOption == .keyType {
                Picker("Key Type", selection: $optionKeyType) {
                    Text("Any").tag(nil as KeyType?)
                    ForEach(viewModel.keyTypes, id: \.id) { type in
                        Text(type.name).tag(type as KeyType?)
                    }
                }.multilineTextAlignment(.leading)
            }
            
            Spacer()
        }.padding(.horizontal)
    }
    
    // Key set cell view
    private func keySetCell(keySet: KeySet) -> some View {
        // Get possible user that has the key set
        let userName = viewModel.users.first(where: { $0.id == keySet.userId })?.fullName
        
        // Get possible key set location
        var buildingName: String? = nil
        if let buildingId = keySet.buildingId {
            if keySet.staticLocation == true {
                if let name = viewModel.buildings.first(where: { $0.id == buildingId })?.name {
                    buildingName = name
                }
            }
        }
        
        // Get keys in this key set
        let keys = viewModel.keys.filter { $0.keySet == keySet.id }
        
        // Create a dictionary to hold key type name and key code
        var keyPairs: [String:String] = [:]
        
        // Populate the dictionary
        for key in keys {
            if let keyTypeName = viewModel.keyTypes.first(where: { $0.id == key.keyType })?.name {
                keyPairs[keyTypeName] = key.keyCode
            }
        }
        
        // Sort the dictionary
        let sortedKeyPairs = keyPairs.sorted { $0.key > $1.key }
        
        let view = VStack(alignment: .leading) {
            // Key set name
            HStack {
                Text("\(keySet.name ?? "No Name")").fontWeight(.bold)
                if let nickname = keySet.nickname {
                    Text(" (\(nickname))")
                }
            }
            // User
            if let userName = userName {
                HStack {
                    Image(systemName: "person.fill")
                    Text(userName)
                }
            }
            // Building
            if let buildingName = buildingName {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(buildingName)
                }
            }
            // List of keys
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
    
    // Computed property to get sorted key sets based on search options
    private var sortedKeySets: [KeySet] {
        // Default list
        let defaultList = viewModel.keySets
        
        // If search option requires search bar
        if searchOption == .keySetName || searchOption == .keyCode {
            // If nothing in search bar
            if searchText.isEmpty {
                // Return default list
                return defaultList
            } else {
                // Check which search term is selected
                if searchOption == .keyCode {
                    var filteredList: [KeySet] = []
                    // Filter key sets by key code
                    for keySet in viewModel.keySets {
                        let keys = viewModel.keys.filter { $0.keySet == keySet.id }
                        if keys.contains(where: { $0.keyCode?.localizedCaseInsensitiveContains(searchText) ?? false }) {
                            filteredList.append(keySet)
                        }
                    }
                    return filteredList
                } else if searchOption == .keySetName {
                    // Filter & sort key sets by name
                    return viewModel.keySets.filter {
                        $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
                    }.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
                } else {
                    return defaultList
                }
            }
        // If searching by KeyType
        } else if searchOption == .keyType {
            var filteredList = viewModel.keySets
            
            // Filter key sets by key type
            if optionKeyType != nil {
                filteredList = viewModel.keySets.filter { keySet in
                    let keys = viewModel.keys.filter { $0.keySet == keySet.id }
                    return keys.contains { $0.keyType == optionKeyType?.id }
                }
            }
            
            // Return filtered list
            return filteredList
        // If searching by User
        } else if searchOption == .user {
            var filteredList = viewModel.keySets
            
            // Filter key sets by user
            if optionUser != nil {
                filteredList = viewModel.keySets.filter { $0.userId == optionUser?.id }
            }
            
            // Return filtered list
            return filteredList
        // If searching by Building
        } else if searchOption == .building {
            var filteredList = viewModel.keySets
            
            // Filter key sets by building
            if optionBuilding != nil {
                filteredList = viewModel.keySets.filter { $0.buildingId == optionBuilding?.id }
            }
            
            // Return filtered list
            return filteredList
        // Otherwise
        } else {
            return defaultList
        }
    }
}

#Preview {
    NavigationView {
        KeysView()
    }
}
