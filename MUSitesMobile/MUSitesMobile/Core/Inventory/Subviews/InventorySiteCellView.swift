//
//  InventorySiteCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI

struct InventorySiteCellView: View {
    // Init
    let inventorySite: InventorySite
    // reference variables
    @State private var building: Building? = nil
    @State private var inventoryTypes: [InventoryType] = []
    @State private var siteGroup: SiteGroup? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // IMAGE
            Group {
                AsyncImage(url: URL(string: "https://picsum.photos/300")) {image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                } placeholder: {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // INFO BLOCK
            VStack(alignment: .leading) {
                // site name
                Text("\(inventorySite.name ?? "N/A")")
                    .font(.headline)
                
                // subtitle
                //TODO: get group
                Text("\(siteGroup?.name ?? "Unknown Group")")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // TYPE ICONS
            inventoryTypeIcons()
        }
        .onAppear {
            getSiteGroup(){}
            getInventoryTypes{}
            //TODO: adjust this for InventorySites
//            Task {
//                await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "", category: "ProfilePicture")
//                getEquipmentInfo()
//            }
        }
    }
    
    func inventoryTypeIcons() -> some View {
        // if there are inventoryTypeIds
        if let typeIds = inventorySite.inventoryTypeIds {
            // create HStack
            let content = HStack {
                // loop through inventoryTypeIds
                ForEach(typeIds, id: \.self) { inventoryType in
                    if inventoryType == "XzRJMtaGOtUKCg5WJGU0" { // tall cabinet
                        Image(systemName: "cabinet")
                            .foregroundColor(Color.green)
                    } else if inventoryType == "TNkr3dS4rBnWTn5glEw0" { // closet
                        Image(systemName: "door.left.hand.open")
                            .foregroundColor(Color.orange)
                    } else if inventoryType == "fRM2GZq5XgvWRYiqIv81" { // short cabinet
                        Image(systemName: "rectangle.split.2x1")
                            .foregroundColor(Color.blue)
                    } else { // default
                        Image(systemName: "")
                            .foregroundColor(Color.gray)
                    }
                }
            }.padding(.vertical, 2)
            
            return AnyView(content)
        }
        
        // else
        return AnyView(EmptyView())
    }
    
    func getInventoryTypes(completion: @escaping () -> Void) {
        Task {
            do {
                self.inventoryTypes = try await InventoryTypeManager.shared.getAllInventoryTypes(descending: false)
                completion()
            } catch {
                print("Error getting inventoryTypes: \(error)")
            }
        }
    }
    
    func getSiteGroup(completion: @escaping () -> Void) {
        getBuilding(){
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
    }
    
    func getBuilding(completion: @escaping () -> Void) {
        if let buildingId = inventorySite.buildingId {
            Task {
                do {
                    self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
                    print("Got building: \(building?.name ?? "")")
                    completion()
                } catch {
                    print("Error getting building: \(error)")
                }
            }
        } else {
            print("No buildingId.")
        }
    }
}

#Preview {
    InventorySiteCellView(
        inventorySite: InventorySite(
            id: "TzLMIsUbadvLh9PEgqaV",
            name: "BCC 122",
            buildingId: "yXT87CrCZCoJVRvZn5DC",
            inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0", "fRM2GZq5XgvWRYiqIv81", "XzRJMtaGOtUKCg5WJGU0"]
        )
//        ,
//        inventoryTypes: [
//            InventoryType(id: "OzLYzERgjICtUQoQTt7t", name: "File Cabinet", keyTypeId: "Di3zmEFSss6TNR6PtOBo"),
//            InventoryType(id: "TNkr3dS4rBnWTn5glEw0", name: "Closet", keyTypeId: "Di3zmEFSss6TNR6PtOBo"),
//            InventoryType(id: "XzRJMtaGOtUKCg5WJGU0", name: "Tall Cabinet", keyTypeId: "Di3zmEFSss6TNR6PtOBo"),
//            InventoryType(id: "bSoWm67vYcQ61fn7U4z0", name: "Locker", keyTypeId: "Di3zmEFSss6TNR6PtOBo"),
//            InventoryType(id: "fRM2GZq5XgvWRYiqIv81", name: "Short Cabinet", keyTypeId: "Di3zmEFSss6TNR6PtOBo")
//        ]
    )
}
