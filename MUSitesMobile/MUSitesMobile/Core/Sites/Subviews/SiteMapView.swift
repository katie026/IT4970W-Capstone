//
//  SiteMapView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 4/1/24.
//

import SwiftUI
import MapKit

struct SiteMapView: View {
    var site: Site
    var building: Building?
    @State private var mapSectionExpanded: Bool = false
    
    var body: some View {
        Section {
            DisclosureGroup(
                isExpanded: $mapSectionExpanded,
                content: {
                    if let buildingCoordinates = building?.coordinates {
                        SimpleMapView(
                            coordinates: CLLocationCoordinate2D(
                                latitude: buildingCoordinates.latitude,
                                longitude: buildingCoordinates.longitude
                            ),
                            label: site.name ?? "N/A"
                        )
                        .listRowInsets(EdgeInsets())
                        .frame(height: 200)
                        .cornerRadius(8)
                    } else {
                        SimpleMapView(
                            coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                            label: site.name ?? "N/A"
                        )
                        .listRowInsets(EdgeInsets())
                        .frame(height: 200)
                        .cornerRadius(8)
                    }
                },
                label: {
                    Text("Map")
                        .font(.title)
                        .fontWeight(.bold)
                }
            )
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
}
