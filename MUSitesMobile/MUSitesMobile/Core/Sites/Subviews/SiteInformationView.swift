//
//  SiteInformationView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/27/24.
//

import Foundation
import SwiftUI

struct SiteInfoView: View {
    @State private var isExpanded = false
    var building: Building?
    var siteType: String?
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("**Group:** \(building?.siteGroup ?? "N/A")")
                    Text("**Building:** \(building?.name ?? "N/A")")
                    Text("**Site Type:** \(siteType ?? "N/A")")
                    Text("**SS Captain:** \(building?.siteGroup ?? "N/A")")
                }
                .listRowInsets(EdgeInsets())
            },
            label: {
                Text("Information")
                    .font(.title)
                    .fontWeight(.bold)
            }
        )
        .padding(.top, 10.0)
        .listRowBackground(Color.clear)
    }
}
    
struct SiteInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let building = Building(id: "sample", name: "Sample Building", siteGroup: "Sample Group")
        return SiteInfoView(building: building, siteType: "Sample Type")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
