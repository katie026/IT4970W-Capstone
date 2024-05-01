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
    
    // View Control
    @State var isLoading = true
    @State var progress = 0
    
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
            if isLoading {
                ProgressView("Loading data...")
            } else {
                Form {
                    informationSection
                    submitForm(site: site)
                    equipmentSection
                    mapSection
                    postersSection
                    if (site.calendarName != nil && site.calendarName != "") {
                        calendarSection
                    }
                }
            }
        }
        .navigationTitle(site.name ?? "N/A")
        .onAppear {
            Task {
                // get building
                viewModel.loadBuilding(site: self.site) {
                    print("Got building")
                    // then get group
                    if let siteGroupId = viewModel.building?.siteGroupId {
                        viewModel.loadSiteGroup(siteGroupId: siteGroupId) {
                            print("Got ID")
                            progress += 1
                            if progress >= 4 {
                                isLoading = false
                                progress = 0
                            }
                        }
                    }
                }
                // get site type
                if let siteTypeId = self.site.siteTypeId {
                    viewModel.loadSiteType(siteTypeId: siteTypeId) {
                        print("Got siteType")
                        progress += 1
                        if progress >= 4 {
                            isLoading = false
                            progress = 0
                        }
                    }
                }
                // get inventorySite
                viewModel.getNearestInventory(inventorySiteId: site.nearestInventoryId ?? "") {
                    print("Got inventory site")
                    progress += 1
                    if progress >= 4 {
                        isLoading = false
                        progress = 0
                    }
                }
                // get users
                viewModel.updateUsers() {
                    progress += 1
                    if progress >= 4 {
                        isLoading = false
                        progress = 0
                    }
                }
                
                //this will take the current site the user is on(site.name) and then pass it to the fetchSiteSpecificImageURLs to get the specific images
                if viewModel.imageURLs.isEmpty && viewModel.boardImageURLs.isEmpty
                {
                    await viewModel.fetchSiteSpecificPosters(siteId: site.id)
                    await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "Clark", basePath: "Sites", category: "Board")
                }
                //for computers it takes the siteID to link it to the related site, it will then get the siteName so it can list all the computers
                viewModel.fetchComputers(forSite: site.id, withName: site.name ?? "")
                //printers just need siteID since it already has the B&W or color type
                viewModel.fetchPrinters(forSite: site.id)
            }
        }
        .onDisappear {
            viewModel.imageURLs.removeAll()
            viewModel.boardImageURLs.removeAll()
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
                        Text("**Nearest Inventory:** \(viewModel.inventorySite?.name ?? "N/A")")
                        Text("**Site Type:** \(viewModel.siteType?.name ?? "N/A")")
                        Text("**SS Captain:** \(UserManager.shared.allUsers.first(where: {$0.id == site.siteCaptain ?? ""})?.fullName ?? "N/A")")
                    }
                    .padding(.top)
                    .listRowInsets(EdgeInsets())
                },
                label: {
                    Label("Information", systemImage: "info.circle")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            )
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
                                List(viewModel.pcComputers, id: \.self) { computer in
                                    VStack(alignment: .leading) {
                                        Text(computer.name ?? "")
                                        //checking if there is a last cleaned date
                                        if let cleanedDate = computer.lastCleaned {
                                            Text("Last cleaned: \(cleanedDate, formatter: itemFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            },
                            label: {
                                //was able to get computer counts by just calling .count
                                Text("**PC Count:** \(viewModel.pcComputers.count)")
                            }
                        )
                    }
                    // MAC section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $macSectionExpanded,
                            content: {
                                List(viewModel.macComputers, id: \.self) { computer in
                                    VStack(alignment: .leading) {
                                        Text(computer.name ?? "")
                                        //checking if there is a last cleaned date
                                        if let cleanedDate = computer.lastCleaned {
                                            Text("Last cleaned: \(cleanedDate, formatter: itemFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            },
                            label: {
                                //was able to get computer counts by just calling .count
                                Text("**MAC Count:** \(viewModel.macComputers.count)")
                            }
                        )
                    }
                    //B&W Printer section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $bwPrinterSectionExpanded,
                            content: {
                                List(viewModel.bwPrinters) { printer in
                                    Text(printer.name ?? "")
                                }
                            },
                            label: {
                                Text("**B&W Printer Count:** \(viewModel.bwPrinters.count)")
                            }
                        )
                    }

                    
                    // Color Printer section
                    Section() {
                        DisclosureGroup(
                            isExpanded: $colorPrinterSectionExpanded,
                            content: {
                                List(viewModel.colorPrinters) { printer in
                                    Text(printer.name ?? "")
                                }
                            },
                            label: {
                                Text("**Color Printer Count:** \(viewModel.colorPrinters.count)")
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
                    Label("Equipment", systemImage: "desktopcomputer")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            )
            .listRowBackground(Color.clear)
        }
    }
    
    private var mapSection: some View {
        let coordinates: CLLocationCoordinate2D?
        if let buildingCoordinates = viewModel.building?.coordinates {
            coordinates = CLLocationCoordinate2D(latitude: buildingCoordinates.latitude, longitude: buildingCoordinates.longitude)
        } else {
            coordinates = nil
        }
        
        // Map
        return Section() {
            DisclosureGroup(
                isExpanded: $mapSectionExpanded,
                content: {
                    if coordinates != nil {
                        VStack {
                            // Button to Apple Maps
                            Button {
                                openMapDirections(to: coordinates!)
                            } label: {
                                HStack {
                                    Text("Get Directions")
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(Color.accentColor)
                                }
                            }
                            .padding(.top, 10)
                            // Map View
                            SimpleMapView(coordinates: coordinates!, label: self.site.name ?? "N/A")
                            .listRowInsets(EdgeInsets())
                            .frame(height: 200)
                            .cornerRadius(8)
                        }
                    } else {
                        Text("No coordinates have been provided for this site.")
                    }
                },
                label: {
                    Label("Map", systemImage: "mappin.and.ellipse")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            )
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
                            VStack(alignment: .leading) {
                                Text("Posters")
                                PostersView(imageURLs: viewModel.imageURLs)
                            }
                        }
                        if !viewModel.boardImageURLs.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Board")
                                BoardView(imageURLs: viewModel.boardImageURLs)
                            }
                        }
                    },
                    label: {
                        Label("Poster Board", systemImage: "rectangle.3.group")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                )
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
                    Label("Calendar", systemImage: "calendar")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            )
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
        }.padding(.top,4)
    }
    
    private var CalendarWebViewButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.accentColor)
            Button {
                isPresentWebView = true
            } label: {
                Text("Open Calendar")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(6)
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
    
    func openMapDirections(to destinationCoordinate: CLLocationCoordinate2D) {
        // specify destination
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        // define destination name
        mapItem.name = (site.name ?? "N/A")
        
        // launch Apple Maps with walking directions
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    private func submitForm(site: Site) -> some View {
        //Submit a Form section
        NavigationLink(destination: SubmitFormView(computingSite: site, inventorySite: viewModel.inventorySite)) {
            HStack {
                Label("Submit a Form", systemImage: "pencil.and.list.clipboard")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
    }

    //formating dates for computers
    let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    NavigationStack {
        DetailedSiteView(
            site: Site(
                id: "6tYFeMv41IXzfXkwbbh6", //ncgvyP2RI3wNvTfSwjM2
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
            )
        )
    }
}
