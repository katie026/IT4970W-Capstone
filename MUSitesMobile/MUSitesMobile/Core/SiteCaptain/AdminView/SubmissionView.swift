//
//  SiteCaptainSubmissionAdminView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 4/22/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SiteCaptainSubmissionAdminView: View {
    @StateObject private var viewModel = AdminViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.siteCaptainEntries) { entry in
                NavigationLink(destination: SubmissionDetailView(entry: entry)) {
                    VStack(alignment: .leading) {
                        Text("Site Name: \(entry.siteName)")
                        Text("User: \(entry.user)")
                        Text("Timestamp: \(entry.timestamp.formatted())")
                        
                        ForEach(entry.issues, id: \.ticket) { issue in
                            Text("Issue: \(issue.issue) [Ticket: \(issue.ticket)]")
                        }
                        
                        ForEach(entry.suppliesNeeded, id: \.supplyId) { supply in
                            Text("Supply Needed: \(supply.supplyName) [Count: \(supply.count)]")
                        }
                        
                        Text("Updated Inventory: \(entry.updatedInventory ? "Yes" : "No")")
                    }
                }
            }
            .navigationBarTitle("Site Captain Entries")
        }
        .onAppear {
            viewModel.fetchSiteCaptainEntries()
        }
    }
}

struct SubmissionDetailView: View {
    let entry: SiteCaptain
    
    var body: some View {
        List {
            Section(header: Text("Site Details")) {
                Text("Site Name: \(entry.siteName)")
                Text("User: \(entry.user)")
                Text("Timestamp: \(entry.timestamp.formatted())")
                Text("Updated Inventory: \(entry.updatedInventory ? "Yes" : "No")")
            }
            
            Section(header: Text("Issues")) {
                if entry.issues.isEmpty {
                    Text("No issues reported")
                } else {
                    ForEach(entry.issues, id: \.ticket) { issue in
                        Text("\(issue.issue) [Ticket: \(issue.ticket)]")
                    }
                }
            }
            
            Section(header: Text("Labels for Replacement")) {
                if entry.labelsForReplacement.isEmpty {
                    Text("No labels for replacement")
                } else {
                    ForEach(entry.labelsForReplacement, id: \.self) { label in
                        Text(label)
                    }
                }
            }
            
            Section(header: Text("Supplies Needed")) {
                if entry.suppliesNeeded.isEmpty {
                    Text("No supplies needed")
                } else {
                    ForEach(entry.suppliesNeeded, id: \.supplyId) { supply in
                        Text("\(supply.supplyName) [Count: \(supply.count)]")
                    }
                }
            }
        }
        .navigationBarTitle("Submission Details")
    }
}

class AdminViewModel: ObservableObject {
    @Published var siteCaptainEntries: [SiteCaptain] = []
    
    private var db = Firestore.firestore()
    private let collectionPath = "site_captain_entries"
    
    init() {
        fetchSiteCaptainEntries()
    }
    
    func fetchSiteCaptainEntries() {
        db.collection(collectionPath).order(by: "timestamp", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching site captain entries: \(error)")
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("No site captain entries found")
                return
            }
            
            self?.siteCaptainEntries = snapshot.documents.compactMap { document in
                if let siteCaptain = try? document.data(as: SiteCaptain.self) {
                    print("Fetched Site Captain Entry: \(siteCaptain)")
                    return siteCaptain
                }
                return nil
            }
        }
    }
}
