//
//  SiteCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import SwiftUI
import FirebaseFirestore

struct SiteCellView: View {
    let site: Site
    @StateObject private var viewModel = DetailedSiteViewModel()
    @State private var siteType: SiteType? = nil
    @State private var building: Building? = nil
    @State private var siteGroup: SiteGroup? = nil
    @State private var profilePictureUrl: URL?
    @State private var hasComputers = false
    @State private var hasPrinters = false
    
    func getSiteType(completion: @escaping () -> Void) {
        if let typeId = site.siteTypeId {
            Task {
                do {
                    self.siteType = try await SiteTypeManager.shared.getSiteType(siteTypeId: typeId)
                    completion()
                } catch {
                    print("Error getting site type: \(error)")
                }
            }
        } else {
            print("No siteTypeId.")
        }
    }
    
    var siteFeatureIcons: some View {
        HStack(alignment: .center, spacing: 10) {
            if site.hasInventory == true {
                Image(systemName: "cabinet")
                    .foregroundColor(.green)
            }
            
            if hasComputers {
                Image(systemName: "desktopcomputer")
                    .foregroundColor(.purple)
            }
            
            if hasPrinters {
                Image(systemName: "printer")
                    .foregroundColor(.pink)
            }
            
            if site.hasPosterBoard == true {
                Image(systemName: "rectangle.3.offgrid.fill")
                    .foregroundColor(.pink)
            }
        }.padding(.leading, 5)
    }
    
    func getBuilding(completion: @escaping () -> Void) {
        if let buildingId = site.buildingId {
            Task {
                do {
                    self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
                    completion()
                } catch {
                    print("Error getting building: \(error)")
                }
            }
        } else {
            print("No buildingId.")
        }
    }
    
    func getSiteGroup(completion: @escaping () -> Void) {
        if let groupId = building?.siteGroupId {
            Task {
                do {
                    self.siteGroup = try await SiteGroupManager.shared.getSiteGroup(siteGroupId: groupId)
                    completion()
                } catch {
                    print("Error getting site group: \(error)")
                }
            }
        } else {
            print("No siteGroupId from the building.")
        }
    }
    
    func getEquipmentInfo() {
        let db = Firestore.firestore()

        db.collection("printers").whereField("computing_site", isEqualTo: site.id).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching printers: \(error)")
                return
            }

            if let documents = snapshot?.documents {
                print("Printers count: \(documents.count)")
                if !documents.isEmpty {
                    print("Printers found")
                    self.hasPrinters = true
                } else {
                    print("No printers found")
                    self.hasPrinters = false
                }
            } else {
                print("No printer documents")
                self.hasPrinters = false
            }
        }

        db.collection("computers").whereField("computing_site", isEqualTo: site.id).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching computers: \(error)")
                return
            }

            if let documents = snapshot?.documents {
                print("Computers count: \(documents.count)")
                if !documents.isEmpty {
                    print("Computers found")
                    self.hasComputers = true
                } else {
                    print("No computers found")
                    self.hasComputers = false
                }
            } else {
                print("No computer documents")
                self.hasComputers = false
            }
        }
    }
    
    var body: some View {
        NavigationLink(destination: DetailedSiteView(site: site)) {
            HStack(alignment: .center, spacing: 10) {
                ProfileImageView(imageURL: viewModel.profilePicture.first)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading) {
                    Text("\(site.name ?? "N/A")")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("\(siteGroup?.name ?? "G?") - \(siteType?.name ?? "Unknown Type")")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Place siteFeatureIcons here
                siteFeatureIcons
            }
            .background(Color.clear)
            .onAppear {
                getSiteType {}
                getBuilding {
                    getSiteGroup {}
                }
                Task {
                    await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "", basePath: "Sites", category: "ProfilePicture")
                    getEquipmentInfo()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    }

#Preview {
    SiteCellView(
        site: Site(
            id: "001",
            name: "Naka",
            buildingId: "VYUlFVzdSeVTBkNuPQWT",
            nearestInventoryId: "Naka",
            chairCounts: [ChairCount(count: 4, type: "black_physics")],
            siteTypeId: "9VXZ0Njs0C46ehpN2kYY",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: true,
            hasPosterBoard: true,
            namePatternMac: "NAKA-MAC-##",
            namePatternPc: "NAKA-PC-##",
            namePatternPrinter: "Naka Printer #"
        )
    )
}
