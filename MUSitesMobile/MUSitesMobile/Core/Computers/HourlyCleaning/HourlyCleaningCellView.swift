//
//  HourlyCleaningCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/18/24.
//

import SwiftUI

struct HourlyCleaningCellView: View {
    // init
    let hourlyCleaning: HourlyCleaning
    let sites: [Site]
    let users: [DBUser]
    let allComputers: [Computer]
    
    @State private var computersSectionExpanded: Bool = false
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    var body: some View {
        let siteName = sites.first { $0.id == hourlyCleaning.siteId }?.name ?? "N/A"
        let userFullName = users.first { $0.userId == hourlyCleaning.userId }?.fullName ?? "N/A"
        
        VStack {
            HStack {
                // DATE
                Image(systemName: "calendar")
                Text("\(hourlyCleaning.timestamp != nil ? dateFormatter.string(from: hourlyCleaning.timestamp!) : "N/A")")
                // SITE
                Image(systemName: "mappin.and.ellipse")
                    .padding(.leading,20)
                    .foregroundColor(Color.red)
                Text("\(siteName)")
                Spacer()
            }.padding(.top, 5)
            
            HStack {
                // USER
                Image(systemName: "person.fill")
                Text("\(userFullName)")
                Spacer()
            }.padding(.top, 2)
            
            // CLEANED COMPUTERS
            computersList()
        }
    }
    
    private func computersList() -> some View {
        // create empty list for cleaned computers
        var computers: [Computer] = []
        
        // if there are computerIds
        if let computerIdList = self.hourlyCleaning.cleanedComputerIds {
            // for each computerId
            for computerId in computerIdList {
                // find computer using computerId
                if let computer  = allComputers.first(where: { $0.id == computerId }) {
                    // add computer to cleaned computers list
                    computers.append(computer)
                }
            }
            // sort cleaned computers list by name
            computers = computers.sorted { $0.name ?? "" < $1.name ?? ""}
        }
        
        let result = DisclosureGroup(
            isExpanded: $computersSectionExpanded,
            content: {
                Group {
                    List {
                        ForEach(computers, id: \.id) { computer in
                            Text("\(computer.name ?? "N/A")")
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(computers.count) * 44.0) // each row is 44 points high
                }
            },
            label: {
                Text("Cleaned Computers: **\(computers.count)**")
            }
        )
        .padding(.top, 5)
        
        // return the list
        return AnyView(result)
    }
}

#Preview {
    List {
        HourlyCleaningCellView(
            hourlyCleaning: HourlyCleaning(
                id: "5ZAuOg8mdLgpf23rqYZH",
                timestamp: Date(),
                userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                siteId: "R7NRnUACYSFP9IDzaCHu",
                cleanedComputerIds: ["Tfl3SuRakdAPNAa8WwsN","0wsElPxpxwimKuQAgbWB","43K7D8D6ZOdmh8IirGc1"]
            ),
            sites: [Site(
                id: "R7NRnUACYSFP9IDzaCHu",
                name: "Ellis",
                buildingId: nil,
                nearestInventoryId: nil,
                chairCounts: nil,
                siteTypeId: nil,
                hasClock: nil,
                hasInventory: nil,
                hasWhiteboard: nil,
                hasPosterBoard: nil,
                namePatternMac: nil,
                namePatternPc: nil,
                namePatternPrinter: nil,
                calendarName: nil
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
                positionIdsds: ["CO","SS","CS"],
                chairReport: ChairReport(chairType: "physics_black",
                                         chairCount: 20))
            ],
            allComputers: [
                Computer(
                    id: "Tfl3SuRakdAPNAa8WwsN",
                    name: "EXAMPLE-PC-02",
                    os: "Windows",
                    siteId: "R7NRnUACYSFP9IDzaCHu",
                    lastCleaned: Date(),
                    section: nil
                ),
                Computer(
                    id: "0wsElPxpxwimKuQAgbWB",
                    name: "EXAMPLE-PC-11",
                    os: "Windows",
                    siteId: "R7NRnUACYSFP9IDzaCHu",
                    lastCleaned: Date(),
                    section: nil
                ),
                Computer(
                    id: "43K7D8D6ZOdmh8IirGc1",
                    name: "EXAMPLE-PC-01",
                    os: "Windows",
                    siteId: "R7NRnUACYSFP9IDzaCHu",
                    lastCleaned: Date(),
                    section: nil
                )
            ]
        )
    }
}
