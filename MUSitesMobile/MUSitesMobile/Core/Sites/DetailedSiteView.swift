//
//  DetailedSiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//
import SwiftUI
import MapKit

struct DetailedSiteView: View {
    // View Model
    @StateObject private var viewModel = DetailedSiteViewModel()
    
    // init
    private var site: Site
    
    // WebView
    @State private var isPresentWebView = false
    @State var calendarDate = Date()
    
    // Collapsable Sections
    @State private var informationSectionExpanded: Bool = true
    @State private var equipmentSectionExpanded: Bool = false
    @State private var pcSectionExpanded: Bool = false
    @State private var macSectionExpanded: Bool = false
    @State private var bwPrinterSectionExpanded: Bool = false
    @State private var colorPrinterSectionExpanded: Bool = false
    @State private var scannerSectionExpanded: Bool = false
    @State private var mapSectionExpanded: Bool = false
    @State private var postersSectionExpanded: Bool = false
    @State private var calendarSectionExpanded: Bool = false
    
    init(site: Site) {
        self.site = site
    }
    
    func getCalendarLink(site: Site) -> String {
        // https://25livepub.collegenet.com/calendars/cornell-hall-5-lab?date=20240408&media=print
        if let calendarName = site.calendarName {
            if calendarName != "" {
                let base = "https://25livepub.collegenet.com/calendars/"
                let name = calendarName + "?"
                let date = "date=" + dateFormatter.string(from: calendarDate)
                let end = "&media=print"
                
                return base + name + date + end
            }
        }
        return ""
    }
    
    var body: some View {
        VStack {
            Form {
                informationSection
                equipmentSection
                mapSection
                postersSection
                
                if (site.calendarName != nil && site.calendarName != "") {
                    calendarSection
                }
            }
        }
        .navigationTitle(site.name ?? "N/A")
        .onAppear {
            Task {
                // get building
                viewModel.loadBuilding(site: self.site) {
                    // then get group
                    if let siteGroupId = viewModel.building?.siteGroupId {
                        viewModel.loadSiteGroup(siteGroupId: siteGroupId) {}
                    }
                }
                // get site type
                if let siteTypeId = self.site.siteTypeId {
                    viewModel.loadSiteType(siteTypeId: siteTypeId) {}
                }
                
                //this will take the current site the user is on(site.name) and then pass it to the fetchSiteSpecificImageURLs to get the specific images
                await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "Clark", category: "Posters")
                await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "Clark", category: "Board")
            }
        }
    }
    
    private var informationSection: some View {
        Section() {
            DisclosureGroup(
                isExpanded: $informationSectionExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**Group:** \(viewModel.siteGroup?.name ?? "N/A")")
                        Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                        Text("**Site Type:** \(viewModel.siteType?.name ?? "N/A")")
                        //TODO: get site captains
                        Text("**SS Captain:** \(viewModel.building?.siteGroupId ?? "N/A")")
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
    
    private var equipmentSection: some View {
        Section() {
            DisclosureGroup(
                isExpanded: $equipmentSectionExpanded,
                content: {
                    
                    // PC section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $pcSectionExpanded,
                            content: {
                                Text(site.namePatternPc ?? "N/A")
                            },
                            label: {
                                Text("**PC Count:** \(1)")
                            }
                        )
                    }
                    // MAC section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $macSectionExpanded,
                            content: {
                                Text(site.namePatternMac ?? "N/A")
                            },
                            label: {
                                Text("**MAC Count:** \(1)")
                            }
                        )
                    }
                    // B&W Printer section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $bwPrinterSectionExpanded,
                            content: {
                                Text(site.namePatternMac ?? "N/A")
                            },
                            label: {
                                Text("**B&W Printer Count:** \(1)")
                            }
                        )
                    }
                    // Color Printer section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $colorPrinterSectionExpanded,
                            content: {
                                Text(site.namePatternMac ?? "N/A")
                            },
                            label: {
                                Text("**Color Printer Count:** \(1)")
                            }
                        )
                    }
                    
                    // Bools
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if site.hasClock == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.square.fill")
                                    .foregroundColor(.red)
                            }
                            Text("Clock")
                        }
                        HStack {
                            if site.hasInventory == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.square.fill")
                                    .foregroundColor(.red)
                            }
                            Text("Inventory")
                        }
                        HStack {
                            if site.hasWhiteboard == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.square.fill")
                                    .foregroundColor(.red)
                            }
                            Text("Whiteboard")
                        }
                        
                    }
                },
                label: {
                    Text("Equipment")
                        .font(.title)
                        .fontWeight(.bold)
                }
            )
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
    
    private var mapSection: some View {
        // Map
        Section() {
            DisclosureGroup(
                isExpanded: $mapSectionExpanded,
                content: {
                    if let buildingCoordinates = viewModel.building?.coordinates {
                        SimpleMapView(
                            coordinates: CLLocationCoordinate2D(
                                latitude: buildingCoordinates.latitude,
                                longitude: buildingCoordinates.longitude
                            ),
                            label: self.site.name ?? "N/A"
                        )
                        .listRowInsets(EdgeInsets())
                        .frame(height: 200)
                        .cornerRadius(8)
                    } else {
                        SimpleMapView(
                            coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                            label: self.site.name ?? "N/A"
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
            .padding(.top, 10.0)
            .listRowBackground(Color.clear)
        }
    }

    
    private var postersSection: some View {
        Section {
            // Use DisclosureGroup only if you need the section to be collapsible
            if !viewModel.imageURLs.isEmpty || !viewModel.boardImageURLs.isEmpty {
                DisclosureGroup(
                    isExpanded: $postersSectionExpanded,
                    content: {
                        if !viewModel.imageURLs.isEmpty {
                            Section(header: Text("Posters")) {
                                PostersView(imageURLs: viewModel.imageURLs)
                            }
                        }
                        if !viewModel.boardImageURLs.isEmpty {
                            Section(header: Text("Board")) {
                                BoardView(imageURLs: viewModel.boardImageURLs)
                            }
                        }
                    },
                    label: {
                        Text("Poster Board")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                )
                .padding(.top, 10.0)
                .listRowBackground(Color.clear)
            }
        }
    }

    
    private var calendarSection: some View {
        Section() {
            DisclosureGroup(
                isExpanded: $calendarSectionExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 10) {
                        datePicker
                        CalendarWebViewButton
                            .padding(.top, 10)
                    }
                },
                label: {
                    Text("Calendar")
                        .font(.title)
                        .fontWeight(.bold)
                }
            )
            .padding(.top, 10.0)
            .listRowBackground(Color.clear)
        }
    }
    
    private var datePicker: some View {
        HStack {
            Text("Date:").fontWeight(.bold)
            DatePicker(
                "",
                selection: $calendarDate,
                displayedComponents: [.date]
            ).labelsHidden().padding(.leading, 10)
            Spacer()
        }
    }
    
    private var CalendarWebViewButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.yellow)
            Button {
                isPresentWebView = true
            } label: {
                Text("Open Calendar")
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(10)
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            isPresentWebView = true
        }
        .sheet(isPresented: $isPresentWebView, onDismiss: {
            isPresentWebView = false
        }) {
            NavigationStack {
                WebView(url: URL(string: getCalendarLink(site: site))!)
                    .ignoresSafeArea()
                    .navigationTitle("Events Calendar")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // button to open link in browser
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                guard let url = URL(string: getCalendarLink(site: site)) else { return }
                                UIApplication.shared.open(url)
                            } label: {
                                Image(systemName: "safari")
                            }
                        }
                    }
            }
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}

#Preview {
    NavigationStack {
        DetailedSiteView(
            site: Site(
                id: "6tYFeMv41IXzfXkwbbh6",
                name: "Clark",
                buildingId: "SvK0cIKPNTGCReVCw7Ln",
                nearestInventoryId: "345",
                chairCounts: [ChairCount(count: 3, type: "physics_black")],
                siteTypeId: "Y3GyB3xhDxKg2CuQcXAA",
                hasClock: true,
                hasInventory: true,
                hasWhiteboard: false,
                namePatternMac: "CLARK-MAC-##",
                namePatternPc: "CLARK-PC-##",
                namePatternPrinter: "Clark Printer ##",
                calendarName: "cornell-hall-5-lab"
            )
        )
    }
}
