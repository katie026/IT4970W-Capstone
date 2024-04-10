//
//  InventoryEntryCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/4/24.
//

import SwiftUI

struct InventoryEntryCellView: View {
    // init
    let supplyTypes: [SupplyType]
    let inventoryEntry: InventoryEntry
    let inventorySites: [InventorySite]
    let users: [DBUser]
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    var body: some View {
        let inventorySiteName = inventorySites.first { $0.id == inventoryEntry.inventorySiteId }?.name ?? "N/A"
        let userFullName = users.first { $0.userId == inventoryEntry.userId }?.fullName ?? "N/A"
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // DATE
                Image(systemName: "calendar")
                Text("\(inventoryEntry.timestamp != nil ? dateFormatter.string(from: inventoryEntry.timestamp!) : "N/A")")
                // SITE
                Image(systemName: "mappin.and.ellipse")
                    .padding(.leading,20)
                    .foregroundColor(Color.red)
                Text("\(inventorySiteName)")
            }
            HStack {
                // USER
                Image(systemName: "person.fill")
                Text("\(userFullName)")
                // TYPE
                entryTypeSection
            }
            // COMMENTS //TODO: consider shortening comment if it's a certain amount of characters and redirect to a detailed view (or trigger pop up/long hold etc.)
            // if comments is not nil
            if let comments = inventoryEntry.comments {
                // and is not empty
                if comments != "" {
                    // show comments section
                    HStack {
                        Image(systemName: "bubble")
                        Text("\(comments)")
                    }
                }
            }
        }
        
        Spacer()
    }
        
    private var entryTypeSection: some View {
        // default accent color
        var entryTypeAccentColor = Color.gray
        // default image
        var entryTypeImageName = "square.dotted"
        
        // customize color and image based on Type
        if let entryType = inventoryEntry.type {
            switch entryType {
            case .Check:
                entryTypeAccentColor = Color.green
                entryTypeImageName = "checkmark.circle.fill"
            case .Fix:
                entryTypeAccentColor = Color.orange
                entryTypeImageName = "hammer.fill"
            case .Delivery:
                entryTypeAccentColor = Color.purple
                entryTypeImageName = "shippingbox.fill"
            case .MovedFrom:
                entryTypeAccentColor = Color.blue
                entryTypeImageName = "arrowshape.zigzag.right"
            case .Use:
                entryTypeAccentColor = Color.yellow
                entryTypeImageName = "minus.circle.fill"
            case .MoveTo:
                entryTypeAccentColor = Color.blue
                entryTypeImageName = "arrowshape.zigzag.right"
            case .NA:
                break
            }
        }
        
        // return section
        return HStack {
            Image(systemName: entryTypeImageName)
                .foregroundColor(entryTypeAccentColor)
                .padding(.leading, 15)
            Text("\(inventoryEntry.type?.rawValue ?? "N/A")")
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
//                .background(entryTypeAccentColor)
                .foregroundColor(entryTypeAccentColor)
                .cornerRadius(8)
        }
    }
}

#Preview {
    List {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                InventoryEntryCellView(
                    supplyTypes: [
                        SupplyType(id: "5dbQL6Jmc3ezlsqR75Pu", name: "Color 11x17", notes: "", collectLevel: false),
                        SupplyType(id: "B17QKJXEM3oPLaoreQWn", name: "B&W 11x17", notes: "", collectLevel: false),
                        SupplyType(id: "SWHMBwzJaR3EggqgWNEk", name: "3M Spray", notes: "", collectLevel: false),
                        SupplyType(id: "dpj0LV4bBdw8wRVle7aD", name: "B&W", notes: "", collectLevel: false),
                        SupplyType(id: "rGTzAyr1CXN2NV0sapK1", name: "Color Paper", notes: "", collectLevel: false),
                        SupplyType(id: "w4V5uYVeF48AvfcgAFN1", name: "Wipes", notes: "", collectLevel: false),
                        SupplyType(id: "yOPDkKB4wVEB1dTK9fXy", name: "Paper Towel", notes: "", collectLevel: false)
                    ],
                    inventoryEntry: InventoryEntry(
                        id: "BhMOtDzIS0QLC4ELMPLm",
                        inventorySiteId: "TzLMIsUbadvLh9PEgqaV",
                        timestamp: Date(),
                        type: .Fix,
                        userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                        comments: "Commenting here. Moved some stuff."
                    ),
                    inventorySites: [InventorySite(
                        id: "TzLMIsUbadvLh9PEgqaV",
                        name: "GO BCC",
                        buildingId: "yXT87CrCZCoJVRvZn5DC",
                        inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
                    )],
                    users: [DBUser(
                        userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                        studentId: 12572353,
                        isAnonymous: false,
                        hasAuthentication: true,
                        email: "ka@gmail.com",
                        fullName: "Katie Jackson",
                        photoURL: "https://lh3.googleusercontent.com/a/ACg8ocIonA7UjQCTfY-8P4NDZM2HB8K8_K-ZOnj3CJl5fikw=s96-c",
                        dateCreated: Date(),
                        isClockedIn: true,
                        positions: ["CO","SS","CS"],
                        chairReport: ChairReport(chairType: "physics_black",
                                                 chairCount: 20))
                    ]
                )
            }.padding()
        }
    }
    .listStyle(.insetGrouped)
}
