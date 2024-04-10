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
    @State private var inventoryTypes: [InventoryType] = []
    
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
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // IMAGE
            AsyncImage(url: URL(string: "https://picsum.photos/300")) {image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            .padding(10)
            
            // INFO BLOCK
            VStack {
                // name and type icons
                HStack() {
                    // name
                    Text("\(inventorySite.name ?? "N/A")")
                        .font(.headline)
                    // type icons
                    inventoryTypeIcons().padding(.leading, 5)
                    Spacer()
                }
                
                // subtitle
                HStack {
                    //TODO: get group
                    Text("Group here")
                    Spacer()
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .onAppear {
            getInventoryTypes{}
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
