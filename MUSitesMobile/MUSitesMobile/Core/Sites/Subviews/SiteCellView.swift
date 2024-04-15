//
//  SiteCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import SwiftUI
import FirebaseFirestore // for Preview

struct SiteCellView: View {
    // init
    let site: Site
//    @ObservedObject var viewModel: DetailedSiteViewModel
    @StateObject private var viewModel = DetailedSiteViewModel()
    @State private var siteType: SiteType? = nil
    @State private var building: Building? = nil
    @State private var siteGroup: SiteGroup? = nil
    @State private var profilePictureUrl: URL?
    
    var hasComputers = true
    var hasPrinters = true
    
    func getSiteType(completion: @escaping () -> Void) {
        // if site has a siteTypeId
        if let typeId = site.siteTypeId {
            Task {
                do {
                    // get the SiteType from Firestore
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
    
    func getBuilding(completion: @escaping () -> Void) {
        // if site has a buildingId
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
        // if building has a siteGroupId
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
    
    func getEquipmentInfo() -> Void {
        //TODO: get equipment info
        // query computers collection to see if there is one at this site.id
        // assign hasComputers
        // query printers collection to see if there is one at this site.id
        // assign hasPrinters
    }
    
    //TODO: update to NavigationStack?
    var body: some View {
        NavigationLink(destination: DetailedSiteView(site: site)) {
            HStack(alignment: .center, spacing: 10) {
                // IMAGE
                ProfileImageView(imageURL: viewModel.profilePicture.first)

                
                // INFO BLOCK
                VStack(alignment: .leading) {
                    // name and type icons
                    HStack() {
                        // SITE NAME
                        Text("\(site.name ?? "N/A")")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        // feature icons
                        siteFeatureIcons
                        Spacer()
                    }
                    
                    // subtitle
                    HStack {
                        // GROUP & TYPE
                        Text("\(siteGroup?.name ?? "G?") - \(siteType?.name ?? "Unkown Type")")
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
            }
            .background(Color.clear)
            .onAppear {
                getSiteType{}
                getBuilding {
                    getSiteGroup{}
                }
                Task {
                        // Ensure viewModel has the function fetchSiteSpecificImageURLs defined as async
                        await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "", category: "ProfilePicture")
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var siteFeatureIcons: some View {
        HStack(alignment: .center, spacing: 10) {
            if site.hasInventory == true {
                Image(systemName: "cabinet")
                    .foregroundColor(.green)
            }
            
            if hasComputers == true {
                Image(systemName: "desktopcomputer")
                    .foregroundColor(.purple)
            }
            
            if hasPrinters == true {
                Image(systemName: "printer")
                    .foregroundColor(.pink)
            }
            
            if site.hasPosterBoard == true {
                Image(systemName: "rectangle.3.offgrid.fill")
                    .foregroundColor(.pink)
            }
            
//            if site.hasClock == true {
//                Image(systemName: "clock")
//                    .foregroundColor(.orange)
//            }
//            
//            if site.hasWhiteboard == true {
//                Image(systemName: "rectangle.inset.filled.and.person.filled")
//                    .foregroundColor(.blue)
//            }
        }.padding(.leading, 5)
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
