//
//  SubmissionView.swift
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
        VStack(alignment: .leading) {
            Text("Site Name: \(entry.siteName)")
            Text("User: \(entry.user)")
            Text("Timestamp: \(entry.timestamp.formatted())")
            
            // Add more details as needed
        }
        .navigationBarTitle("Submission Details")
    }
}

class AdminViewModel: ObservableObject {
    @Published var siteCaptainEntries: [SiteCaptain] = []
    private let db = Firestore.firestore()
    private let siteCaptainEntry = "site_captain_entries"

    func fetchSiteCaptainEntries() {
        db.collection(siteCaptainEntry).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching site captain entries: \(error.localizedDescription)")
                return
            }

            self.siteCaptainEntries = querySnapshot?.documents.compactMap { document in
                try? document.data(as: SiteCaptain.self)
            } ?? []
        }
    }
}
