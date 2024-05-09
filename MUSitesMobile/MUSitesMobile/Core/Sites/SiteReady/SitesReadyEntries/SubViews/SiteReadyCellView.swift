//
//  SiteReadyCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/4/24.
//

import SwiftUI

struct SiteReadyCellView: View {
    // init
    let siteReady: SiteReady
    let sites: [Site]
    let users: [DBUser]
    let supplyTypes: [SupplyType]
    let allIssues: [Issue]
    let allSupplyRequests: [SupplyRequest]
    
    // view control
    @State private var issueSectionExpanded: Bool = false
    @State private var supplySectionExpanded: Bool = false
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    var body: some View {
        let siteName = sites.first { $0.id == siteReady.siteId }?.name ?? "N/A"
        let userFullName = users.first { $0.userId == siteReady.user }?.fullName ?? "N/A"
        
        VStack {
            HStack {
                // DATE
                Image(systemName: "calendar")
                Text("\(siteReady.timestamp != nil ? dateFormatter.string(from: siteReady.timestamp!) : "N/A")")
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
                // UPDATED INVENTORY
                if siteReady.updatedInventory == true {
                    // did check inventory
                    Image(systemName: "checkmark.seal")
                        .foregroundColor(Color.green)
                    Text("Inventory Updated")
                } else if siteReady.updatedInventory == false {
                    // did not check inventory
                    Image(systemName: "xmark.app")
                        .foregroundColor(Color.red)
                    Text("Inventory Missed")
                } else {
                    // nil
                    Image(systemName: "square.dotted")
                        .foregroundColor(Color.gray)
                    Text("No Inventory")
                }
                Spacer()
            }.padding(.top, 2)
            
            // ISSUES
            issuesList()
            
            // SUPPLY REQUESTS
            supplyRequestsList()
        }
    }
    
    private func issuesList() -> some View {
        // if siteReady does not have supplyRequests property
        if self.siteReady.issues == nil {
            return AnyView(EmptyView())
        }
        
        // create empty list for cleaned computers
        var entryIssues: [Issue] = []
        
        // if there are issueIds
        if let issueIds = self.siteReady.issues {
            // for each issueId
            for issueId in issueIds {
                // find issue using issueId
                if let issue  = allIssues.first(where: { $0.id == issueId }) {
                    // add issue to Issues list
                    entryIssues.append(issue)
                }
            }
            // sort issues list by typeId
            entryIssues = entryIssues.sorted { $0.issueTypeId ?? "" < $1.issueTypeId ?? ""}
            // if no matches were found for the supplyRequests
            if entryIssues.count == 0 {
                // return empty
                return AnyView(EmptyView())
            }
        }
        
        let result = DisclosureGroup(
            isExpanded: $issueSectionExpanded,
            content: {
                Group {
                    List {
                        ForEach(entryIssues, id: \.id) { issue in
                            HStack {
                                if issue.resolved == true {
                                    Image(systemName: "checkmark.seal")
                                        .foregroundColor(Color.green)
                                } else {
                                    Image(systemName: "xmark.app")
                                        .foregroundColor(Color.red)
                                }
                                Text("\(issue.description ?? "N/A")")
                                //Text("\(issue.resolved == true ? "Resolved" : "Unreselved")")
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(entryIssues.count) * 44.0) // each row is 44 points high
                }
            },
            label: {
                Text("Reported Issues: **\(entryIssues.count)**")
            }
        )
        .padding(.top, 5)
        
        // return the list
        return AnyView(result)
    }
    
    private func supplyRequestsList() -> some View {
        // if siteReady does not have supplyRequests property
        if self.siteReady.supplyRequests == nil {
            // return empty
            return AnyView(EmptyView())
        }
        
        // create empty list for cleaned computers
        var supplyRequests: [SupplyRequest] = []
        
        // if there are requestIds
        if let requestIds = self.siteReady.supplyRequests {
            // for each issueId
            for requestId in requestIds {
                // find issue using issueId
                if let request  = allSupplyRequests.first(where: { $0.id == requestId }) {
                    // add issue to Issues list
                    supplyRequests.append(request)
                }
            }
            // if no matches were found for the supplyRequests
            if supplyRequests.count == 0 {
                // return empty
                return AnyView(EmptyView())
            }
        }
        
        let result = DisclosureGroup(
            isExpanded: $supplySectionExpanded,
            content: {
                Group {
                    List {
                        ForEach(supplyRequests, id: \.id) { request in
                            HStack {
                                if request.resolved == true {
                                    Image(systemName: "checkmark.seal")
                                        .foregroundColor(Color.green)
                                } else {
                                    Image(systemName: "xmark.app")
                                        .foregroundColor(Color.red)
                                }
                                supplyRequestText(request: request)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(supplyRequests.count) * 44.0) // each row is 44 points high
                }
            },
            label: {
                Text("Supply Requests: **\(supplyRequests.count)**")
            }
        )
        .padding(.top, 5)
        
        // return the list
        return AnyView(result)
    }
    
    private func supplyRequestText(request: SupplyRequest) -> some View {
        if let supplyName = supplyTypes.first(where: { $0.id == request.supplyTypeId })?.name {
            return AnyView(Text("\(supplyName): \(request.countNeeded ?? 0)"))
        } else {
            return AnyView(EmptyView())
        }
    }
}

#Preview {
    SiteReadyCellView(
        siteReady: SiteReady(
            id: "oeWvTMrqMza2nebC8mImsFOaNVL2",
            timestamp: Date(),
            user: "oeWvTMrqMza2nebC8mImsFOaNVL2",
            siteId: "BezlCe1ospf57zMdop2z",
            macCount: 2,
            pcCount: 23,
            scannerCount: 1,
            scannerComputers: ["PC-01"],
            bwPrinterCount: 1,
            colorPrinterCount: 1,
            chairCount: 18,
            missingChairs: nil, //TODO: implement eventually
            updatedInventory: true,
            posters: [PosterReport(posterType: "newAdobeCcLoginPoster", status: "Yes")],
            supplyRequests: ["8QQshpEN6Zt7ndDKq3Z9"],
            equipmentStatuses: nil,
            issues: ["LvkB7728one2PFaDky4C", "eGYWgrdU2ngLHo0z3Pk8"],
            comments: "Commenting here for testing."
        ),
        sites: [Site(
            id: "BezlCe1ospf57zMdop2z",
            name: "Bluford",
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
        users: [
            DBUser(
                userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                studentId: 12572353,
                isAnonymous: false,
                hasAuthentication: true,
                email: "ka@gmail.com",
                fullName: "Katie Jackson",
                photoURL: "https://lh3.googleusercontent.com/a/ACg8ocIonA7UjQCTfY-8P4NDZM2HB8K8_K-ZOnj3CJl5fikw=s96-c",
                dateCreated: Date(),
                isClockedIn: true,
                positionIds: ["CO","SS","CS"],
                chairReport: ChairReport(chairType: "physics_black",
                                     chairCount: 20)
            ),
            DBUser(
                userId: "TkFJO3rRBGPeDebJ3owiFxu8OwJ2",
                studentId: 9876543,
                isAnonymous: false,
                hasAuthentication: true,
                email: "karch@gmail.com",
                fullName: "Karch Hert",
                photoURL: "https://lh3.googleusercontent.com/a/ACg8ocLGSK6IGWvBznMx3C_HKs2XslxYSr8-imEwz6BQYaBF=s96-c",
                dateCreated: Date(),
                isClockedIn: true,
                positionIds: ["CO","SS","CS"],
                chairReport: ChairReport(chairType: "physics_black",
                                     chairCount: 20)
            )
        ],
        supplyTypes: [
            SupplyType(id: "5dbQL6Jmc3ezlsqR75Pu", name: "Color 11x17", notes: "", collectLevel: false),
            SupplyType(id: "B17QKJXEM3oPLaoreQWn", name: "B&W 11x17", notes: "", collectLevel: false),
            SupplyType(id: "SWHMBwzJaR3EggqgWNEk", name: "3M Spray", notes: "", collectLevel: false),
            SupplyType(id: "dpj0LV4bBdw8wRVle7aD", name: "B&W", notes: "", collectLevel: false),
            SupplyType(id: "rGTzAyr1CXN2NV0sapK1", name: "Color Paper", notes: "", collectLevel: false),
            SupplyType(id: "w4V5uYVeF48AvfcgAFN1", name: "Wipes", notes: "", collectLevel: false),
            SupplyType(id: "yOPDkKB4wVEB1dTK9fXy", name: "Paper Towel", notes: "", collectLevel: true),
            SupplyType(id: "pzYHibgLjJ6yjh8T9Jno", name: "Table Spray", notes: "", collectLevel: true)
        ],
        allIssues: [
            Issue(
                id: "LvkB7728one2PFaDky4C",
                description: "Issue 1",
                dateCreated: Date(),
                dateResolved: Date(),
                issueTypeId: "zpavvVHHgI3S3qujebnW",
                resolved: false,
                ticket: 1234567,
                reportId: "AbhGSSoDgn0K1d29SUw6",
                reportType: "site_captain",
                siteId: "BezlCe1ospf57zMdop2z",
                userSubmitted: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                userAssigned: "TkFJO3rRBGPeDebJ3owiFxu8OwJ2"
            ),
            Issue(
                id: "eGYWgrdU2ngLHo0z3Pk8",
                description: "BLUFORD-PC-03 label",
                dateCreated: Date(),
                dateResolved: Date(),
                issueTypeId: "GxFGSkbDySZmdkCFExt9",
                resolved: true,
                ticket: 1234567,
                reportId: "AbhGSSoDgn0K1d29SUw6",
                reportType: "site_captain",
                siteId: "BezlCe1ospf57zMdop2z",
                userSubmitted: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                userAssigned: "oeWvTMrqMza2nebC8mImsFOaNVL2"
            )
        ],
        allSupplyRequests: [
            SupplyRequest(
                id: "8QQshpEN6Zt7ndDKq3Z9",
                siteId: "BezlCe1ospf57zMdop2z",
                supplyTypeId: "pzYHibgLjJ6yjh8T9Jno",
                countNeeded: 3,
                reportId: "AbhGSSoDgn0K1d29SUw6",
                reportType: "site_captain",
                resolved: false,
                dateCreated: Date(),
                dateResolved: Date()
            )
        ]
    )
}
