//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/25/24.
//
/*import Foundation
import SwiftUI

struct SiteCaptainSubmissionView: View {
    @State private var selectedInventorySite: InventorySite?
    @State private var inventorySites: [InventorySite] = []
    
    var body: some View {
        VStack {
            Picker("Select Inventory Site", selection: $selectedInventorySite) {
                Text("Select a site").tag(nil as InventorySite?)
                ForEach(inventorySites, id: \.self) { inventorySite in
                    Text(inventorySite.name ?? "").tag(inventorySite as InventorySite?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            if let selectedSite = selectedInventorySite {
                Text("Selected Inventory Site: \(selectedSite.name ?? "")")
                
                // Display the questions for the selected site
                SiteCaptainFormView(inventorySite: selectedSite)
            } else {
                Text("No inventory site selected")
            }
        }
        .navigationTitle("Inventory Sites")
        .onAppear {
            Task {
                do {
                    inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: nil)
                } catch {
                    print("Error retrieving inventory sites: \(error)")
                }
            }
        }
    }
}

struct SiteCaptainFormView: View {
    let inventorySite: InventorySite
    
    var body: some View {
        Form {
            // Display the questions for the selected site
            Section(header: Text("Questions")) {
                // Add your questions here based on the selected site
                Text("Question 1")
                Text("Question 2")
                // ...
            }
            
            // Add a submit button or any other necessary form elements
            Button(action: {
                // Handle form submission
            }) {
                Text("Submit")
            }
        }
        .navigationTitle(inventorySite.name ?? "")
    }
}

#Preview {
    NavigationStack {
        SiteCaptainSubmissionView()
    }
}
*/
