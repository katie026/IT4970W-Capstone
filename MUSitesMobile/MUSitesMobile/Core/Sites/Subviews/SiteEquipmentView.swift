//
//  SiteEquipmentView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/27/24.
//

import Foundation
import SwiftUI

struct SiteEquipmentView: View {
    var site: Site
    @State private var equipmentSectionExpanded: Bool = false
    @State private var pcSectionExpanded: Bool = false
    @State private var macSectionExpanded: Bool = false
    @State private var bwPrinterSectionExpanded: Bool = false
    @State private var colorPrinterSectionExpanded: Bool = false
    
    var body: some View {
        Section {
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
                        .padding(.horizontal)
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
                        .padding(.horizontal)
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
                        .padding(.horizontal)
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
                        .padding(.horizontal)
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
}
