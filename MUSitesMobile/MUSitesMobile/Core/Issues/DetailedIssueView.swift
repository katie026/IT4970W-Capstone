//
//  DetailedIssueView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/28/24.
//

import SwiftUI

struct DetailedIssueView: View {
    let issue: Issue
    let sites: [Site]
    let users: [DBUser]
    let issueTypes: [IssueType]
    
    @State private var resolved = false
    @State private var userAssignedId: String? = nil
    @State private var userSelected: DBUser? = nil
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
    
    var body: some View {
        content
            .onAppear {
                resolved = issue.resolved ?? false
                userAssignedId = issue.userAssigned
                userSelected = users.first { $0.userId == issue.userAssigned } ?? nil
            }
    }
    
    private var content: some View {
        List {
            BasicInfoSection()
            ActionSection
        }
    }
    
    private func BasicInfoSection() -> some View {
        let siteName = sites.first { $0.id == issue.siteId }?.name ?? "N/A"
        let userSubmittedName = users.first { $0.userId == issue.userSubmitted }?.fullName ?? "N/A"
        let userAssignedName = users.first { $0.userId == userAssignedId }?.fullName ?? "N/A"
        let description = issue.description ?? "N/A"
        var reportType = "N/A"
        if let report = issue.reportType {
            if report == "site_ready" {
                reportType = "Site Ready"
            } else if report == "site_captain" {
                reportType = "Site Captain"
            } else if report == "hourly_cleaning" {
                reportType = "Hourly Cleaning"
            }
        }
        
        let view = Section("Basic Information") {
            // SITE
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color.red)
                Text("**Computing Site:** \(siteName)")
            }
            // RESOLUTION STATUS
            issueResolvedSection(resolved: resolved)
            // DATE CREATED
            HStack {
                Image(systemName: "calendar")
                Text("**Date Created:** \(issue.dateCreated != nil ? dateFormatter.string(from: issue.dateCreated!) : "N/A")")
            }
            // DATE RESOLVED
            if resolved == true {
                HStack {
                    Image(systemName: "calendar")
                    Text("**Date Resolved:** \(issue.dateCreated != nil ? dateFormatter.string(from: issue.dateCreated!) : "N/A")")
                }
            }
            // ISSUE TYPE
            issueTypeSection(issue: issue)
            // USER SUBMITTED
            HStack {
                Image(systemName: "person.fill")
                Text("**User Submitted:** \(userSubmittedName)")
            }
            // USER ASSIGNED
            HStack {
                if userAssignedId == nil || userAssignedId == "" {
                    Image(systemName: "person")
                } else {
                    Image(systemName: "person.fill")
                }
                Text("**User Assigned:** \(userAssignedName)")
            }
            // REPORT TYPE
            HStack {
                Image(systemName: "pencil.and.list.clipboard")
                Text("**Report Type:** \(reportType)")
            }
            // DESCRIPTION
            HStack {
                Image(systemName: "bubble")
                Text("**Description:** \(description)")
            }
            Text("ID: \(issue.id)")
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
            Text("**Issue Type:** \(typeName)")
                .padding(.vertical, 3)
                .foregroundColor(issueTypeAccentColor)
                .cornerRadius(8)
        }
    }
    
    private func issueResolvedSection(resolved: Bool) -> some View {
        // default accent color
        var resolvedAccentColor = Color.gray
        // default image
        var resolvedImageName = "square.dotted"
        
        // customize color and image based on Type
        if resolved {
            // if resolved
            resolvedAccentColor = Color.green
            resolvedImageName = "checkmark.circle"
        } else {
            resolvedAccentColor = Color.red
            resolvedImageName = "xmark.app"
        }
        
        // return section
        return HStack {
            Image(systemName: resolvedImageName)
                .foregroundColor(resolvedAccentColor)
            Text(resolved ? "Resolved" : "Unresolved")
            Toggle("", isOn: Binding(
                get: {
                    self.resolved
                },
                set: { toggledOn in
                    if toggledOn {
                        //TODO: update Firetstore
                        //toggleResolutionStatus()
                        self.resolved = true
                    } else {
                        //TODO: update Firetstore
                        //toggleResolutionStatus()
                        self.resolved = false
                    }
                }
            ))
            Spacer()
        }
    }
    
    private var ActionSection: some View {
        Section("Assign a User") {
            HStack {
                Picker("Selected User", selection: $userSelected) {
                    ForEach(users, id: \.self) { user in
                        Text(user.fullName ?? "N/A").tag(user as DBUser?)
                    }
                }.multilineTextAlignment(.leading)
            }
            if (userAssignedId != userSelected?.id ?? "") {
                HStack(alignment:.center) {
                    Spacer()
                    
                    Button {
                        if let newUserId = userSelected?.id {
                            //TODO: assign user in Firestore
                            // update in Firestore
                            //updateAssignedUser(userId: newUserId)
                            // update in view
                            userAssignedId = newUserId
                            print("Assigned \(userSelected?.fullName ?? "N/A") to the ticket.")
                        } else {
                            print("No userSelected")
                        }
                    } label: {
                        Text("Assign **\(userSelected?.fullName ?? "N/A")** to the ticket.")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.vertical)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func toggleResolutionStatus() {
        Task {
            do {
                try await IssueManager.shared.toggleIssueResolution(issue: self.issue)
            } catch {
                print("Error toggling issue resolution: \(error)")
            }
        }
    }
    
    private func updateAssignedUser(userId: String) {
        Task {
            do {
                try await IssueManager.shared.updateUserAssigned(issue: self.issue, userId: userId)
            } catch {
                print("Error assigning new user to issue: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView {
        DetailedIssueView(
            issue: Issue(
                id: "LvkB7728one2PFaDky4C",
                description: "Projector not Turning on.",
                dateCreated: Date(),
                dateResolved: Date(),
                issueTypeId: "zpavvVHHgI3S3qujebnW",
                resolved: true,
                ticket: 9999999,
                reportId: "AbhGSSoDgn0K1d29SUw6",
                reportType: "site_captain",
                siteId: "BezlCe1ospf57zMdop2z",
                userSubmitted: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                userAssigned: "UP4qMGuLhCP3qHvT5tfNnZlzH4h1"
            ),
            sites: [Site(
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
                    chairReport: nil
                ),
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
            issueTypes: [IssueType(
                id: "zpavvVHHgI3S3qujebnW",
                name: "Classroom Equipment",
                notes: "Classroom equipment not working."
            )]
        )
    }
}
