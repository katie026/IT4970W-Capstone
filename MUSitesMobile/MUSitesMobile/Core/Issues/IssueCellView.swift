//
//  IssueCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/29/24.
//

import SwiftUI

struct IssueCellView: View {
    let issue: Issue
    let sites: [Site]
    let users: [DBUser]
    let issueTypes: [IssueType]
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
    
    var body: some View {
        let siteName = sites.first { $0.id == issue.siteId }?.name ?? "N/A"
        let userSubmittedName = users.first { $0.userId == issue.userSubmitted }?.fullName ?? "N/A"
        let userAssignedName = users.first { $0.userId == issue.userAssigned }?.fullName ?? "N/A"
        
        let view = VStack(alignment: .leading, spacing: 8) {
            HStack {
                // DATE
                Image(systemName: "calendar")
                Text("\(issue.dateCreated != nil ? dateFormatter.string(from: issue.dateCreated!) : "N/A")")
                // RESOLUTION STATUS
                issueResolvedSection(issue: issue)
                // SITE
                Image(systemName: "mappin.and.ellipse")
                    .padding(.leading,20)
                    .foregroundColor(Color.red)
                Text("\(siteName)")
            }
            HStack {
                // TYPE
                issueTypeSection(issue: issue)
                // USER ASSIGNED
                if issue.userAssigned == nil || issue.userAssigned == "" {
                    Image(systemName: "person")
                } else {
                    Image(systemName: "person.fill")
                }
                Text("\(userAssignedName)")
            }
            // DESCRIPTION
            //TODO: consider shortening description if it's a certain amount of characters and redirect to a detailed view (or trigger pop up/long hold etc.)
            // if description is not nil
            if let description = issue.description {
                // and is not empty
                if description != "" {
                    // show description section
                    HStack {
                        Image(systemName: "bubble")
                        Text("\(userSubmittedName): \(description)")
                    }
                }
            }
        }
        
        return AnyView(view)
    }
    
    private func issueTypeSection(issue: Issue) -> some View {
        let typeName = issueTypes.first { $0.id == issue.issueTypeId }?.name ?? "N/A"
        
        // default accent color
        var issueTypeAccentColor = Color.gray
        // default image
        var issueTypeImageName = "square.dotted"
        
        // customize color and image based on Type
        if let issueType = issue.issueTypeId {
            if issueType == "FldaGVfpPdQ57H7XsGOO" { // Chair
                issueTypeAccentColor = Color.green
                issueTypeImageName = "chair"
            } else if issueType == "zpavvVHHgI3S3qujebnW" { // Classroom Equip
                issueTypeAccentColor = Color.orange
                issueTypeImageName = "videoprojector"
            } else if issueType == "GxFGSkbDySZmdkCFExt9" { // Label
                issueTypeAccentColor = Color.purple
                issueTypeImageName = "tag"
            } else if issueType == "wYJWtaj33rx4EIh6v9RY" { // Poster
                issueTypeAccentColor = Color.blue
                issueTypeImageName = "doc.richtext"
            } else if issueType == "r6jx5SXc0x2OC7bM8XNN" { // SitesTech
                issueTypeAccentColor = Color.yellow
                issueTypeImageName = "hammer.fill"
            }
        }
        
        // return section
        return HStack {
            Image(systemName: issueTypeImageName)
                .foregroundColor(issueTypeAccentColor)
            Text("\(typeName)")
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
                .foregroundColor(issueTypeAccentColor)
                .cornerRadius(8)
        }
    }
    
    private func issueResolvedSection(issue: Issue) -> some View {
        // default accent color
        var resolvedAccentColor = Color.gray
        // default image
        var resolvedImageName = "square.dotted"
        
        // customize color and image based on Type
        if let resolved = issue.resolved {
            // if resolved
            if resolved == true {
                resolvedAccentColor = Color.green
                resolvedImageName = "checkmark.circle"
            // if not resolved
            } else {
                resolvedAccentColor = Color.red
                resolvedImageName = "xmark.app"
            }
        }
        
        // return section
        return HStack {
            Image(systemName: resolvedImageName)
                .foregroundColor(resolvedAccentColor)
                .padding(.leading, 15)
            if let resolved = issue.resolved {
                Text(resolved ? "Resolved" : "Unresolved")
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
            } else {
                Text("N/A")
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
            }
        }
    }
}

#Preview {
    IssueCellView(
        issue: Issue(
            id: "LvkB7728one2PFaDky4C",
            description: "Projector not Turning on.",
            dateCreated: Date(),
            dateResolved: Date(),
            issueTypeId: "zpavvVHHgI3S3qujebnW",
            resolved: false,
            ticket: 9999999,
            reportId: "AbhGSSoDgn0K1d29SUw6",
            reportType: "site_captain",
            siteId: "BezlCe1ospf57zMdop2z",
            userSubmitted: "oeWvTMrqMza2nebC8mImsFOaNVL2",
            userAssigned: "UP4qMGuLhCP3qHvT5tfNnZlzH4h1"
        ),
        sites: [
            Site(
            id: "BezlCe1ospf57zMdop2z", //ncgvyP2RI3wNvTfSwjM2
            name: "Clark", //A&S
            buildingId: "SvK0cIKPNTGCReVCw7Ln",
            nearestInventoryId: "8xSqb2Gf5nfgf7g5P9PA",
            chairCounts: [ChairCount(count: 3, type: "physics_black")],
            siteTypeId: "Y3GyB3xhDxKg2CuQcXAA",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: false,
            namePatternMac: "CLARK-MAC-##",
            namePatternPc: "CLARK-PC-##",
            namePatternPrinter: "Clark Printer ##",
            calendarName: "cornell-hall-5-lab",
            siteCaptain: "ezWofRU3EjNXlXey5P446UeQH6B3"
        )],
        users: [
            DBUser(
                userId: "UP4qMGuLhCP3qHvT5tfNnZlzH4h1",
                studentId: 12572353,
                isAnonymous: false,
                hasAuthentication: true,
                email: "tmwny4@umsystem.edu",
                fullName: "Tristan Winship",
                photoURL: "https://lh3.googleusercontent.com/a/ACg8ocJxVcI6q24DRgPDw3dz1lVJLowgsgaXiARzj9lMBGxS=s96-c",
                dateCreated: Date(),
                lastLogin: Date(),
                isClockedIn: true,
                positionIds: ["1HujvaLNHtUEs59nTdci", "FYK5L6XdE4YE5kMpDOyr", "xArozhlNGujNsgczkKsr"],
                chairReport: nil),
            DBUser(
                userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                studentId: 12572353,
                isAnonymous: false,
                hasAuthentication: true,
                email: "kmjbcw@umsystem.edu",
                fullName: "Katie Jackson",
                photoURL: "https://lh3.googleusercontent.com/a/ACg8ocJxVcI6q24DRgPDw3dz1lVJLowgsgaXiARzj9lMBGxS=s96-c",
                dateCreated: Date(),
                lastLogin: Date(),
                isClockedIn: true,
                positionIds: ["1HujvaLNHtUEs59nTdci", "FYK5L6XdE4YE5kMpDOyr", "xArozhlNGujNsgczkKsr"],
                chairReport: nil)
        ],
        issueTypes: [
            IssueType(
                id: "zpavvVHHgI3S3qujebnW",
                name: "Classroom Equipment",
                notes: "Classroom equipment not working."
            )
        ]
    )
}
