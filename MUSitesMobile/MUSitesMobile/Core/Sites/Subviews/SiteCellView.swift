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
    let buildings: [Building]
    let siteTypes: [SiteType]
    let siteGroups: [SiteGroup]
    
    var hasComputers = true
    var hasPrinters = true
    
    func getEquipmentInfo() -> Void {
        //TODO: get equipment info
        // query computers collection to see if there is one at this site.id
        // assign hasComputers
        // query printers collection to see if there is one at this site.id
        // assign hasPrinters
    }
    
    //TODO: update to NavigationStack?
    var body: some View {
        // get site type from site
        let siteType = siteTypes.first(where: { $0.id == site.siteTypeId })
        // get building from site
        let building = buildings.first(where: { $0.id == site.buildingId })
        // get group from building
        let group = siteGroups.first(where: { $0.id == building?.siteGroupId })
        
        NavigationLink(destination: DetailedSiteView(site: site)) {
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
                        Text("\(group?.name ?? "G?") - \(siteType?.name ?? "Unkown Type")")
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
            }
            .background(Color.clear)
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
        ),
        buildings: [
            Building(
                id: "VYUlFVzdSeVTBkNuPQWT",
                name: "Arts & Science",
                address: Address(city: "Columbia", country: "United States", state: "MO", street: "902 Conley Ave", zipCode: "65201"),
                coordinates: GeoPoint(latitude: 1.1, longitude: 2.2),
                isLibrary: false,
                isReshall: false,
                siteGroupId: "zw1TFIf7KQxMNrThdfD1"
            ),
            Building(
                id: "OcMzHSE1L1urLvGiaPBV",
                name: "Bingham Hall",
                address: Address(city: "Columbia", country: "US", state: "MO", street: "1400 Treelane Dr.", zipCode: "65211"),
                coordinates:GeoPoint(latitude: 1.1, longitude: 2.2) ,
                isLibrary: true,
                isReshall: true,
                siteGroupId: "CgLht1pwcSdyDe7tJWVN"
            )
        ],
        siteTypes: [
            SiteType(id: "9VXZ0Njs0C46ehpN2kYY", name: "Classroom", notes: ""),
            SiteType(id: "xbkeVv7ml47lTknpbEKY", name: "Library", notes: ""),
            SiteType(id: "Y3GyB3xhDxKg2CuQcXAA", name: "Other", notes: ""),
            SiteType(id: "ZGgC7bgULE6Kp3bmTVAe", name: "Printer Only", notes: ""),
            SiteType(id: "u699TGf4zrEK3Vu0B6U1", name: "ResHall", notes: "")
        ],
        siteGroups: [
            SiteGroup(id: "gkRTxs7OyARmxGHHPuMV", name: "G1", notes: ""),
            SiteGroup(id: "kxeYimfnOx1YnB9TVXp9", name: "G2", notes: ""),
            SiteGroup(id: "zw1TFIf7KQxMNrThdfD1", name: "G3", notes: ""),
            SiteGroup(id: "LM0MN0spXlHfd2oZSahO", name: "R1", notes: ""),
            SiteGroup(id: "CgLht1pwcSdyDe7tJWVN", name: "R2", notes: "")
        ]
    )
}
