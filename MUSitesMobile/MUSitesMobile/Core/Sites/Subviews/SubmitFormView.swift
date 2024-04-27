//
//  SubmitFormView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI

struct SubmitFormView: View {
    let computingSite: Site
    
    var body: some View {
        VStack {
            // Subtitle
            HStack {
                Text("\(computingSite.name ?? "N/A")")
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            // Link List
            List {
                // Hourly Cleaning Link
                NavigationLink(destination: HourlyCleaningSubmissionView(computingSite: computingSite)) {
                    HStack {
                        Text("Hourly Cleaning")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding(.vertical, 10)
                }
                
                // Site Captain Link
                NavigationLink(destination: SiteCaptainSubmissionView(site: computingSite)) {
                    HStack {
                        Text("Site Captain")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding(.vertical, 10)
                }
                
                // Site Ready Link
                NavigationLink(destination: SiteReadySurveyView(site: computingSite)) {
                    HStack {
                        Text("Site Ready")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding(.vertical, 10)
                }
            }
        }.navigationTitle("SUBMIT")
    }
}

#Preview {
    NavigationView {
        SubmitFormView(computingSite: Site(
            id: "BezlCe1ospf57zMdop2z",
            name: "Bluford",
            buildingId: "SvK0cIKPNTGCReVCw7Ln",
            nearestInventoryId: "345",
            chairCounts: [ChairCount(count: 3, type: "physics_black")],
            siteTypeId: "Y3GyB3xhDxKg2CuQcXAA",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: true,
            namePatternMac: "CLARK-MAC-##",
            namePatternPc: "CLARK-PC-##",
            namePatternPrinter: "Clark Printer ##",
            calendarName: "cornell-hall-5-lab"
        ))
    }
}
