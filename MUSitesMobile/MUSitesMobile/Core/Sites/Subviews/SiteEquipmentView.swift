//
//  SiteEquipmentView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//
import Foundation
import SwiftUI
struct SiteEquipmentView: View {
    @Binding var pcSectionExpanded: Bool
    @Binding var macSectionExpanded: Bool
    @Binding var bwPrinterSectionExpanded: Bool
    @Binding var colorPrinterSectionExpanded: Bool
    
    var site: Site
    
    var body: some View {
        Section {
            DisclosureGroup(
                isExpanded: $pcSectionExpanded,
                content: {
                    Text(site.namePatternPc ?? "N/A")
                },
                label: {
                    Text("**PC Count:** \(1)")
                }
            )
            
            DisclosureGroup(
                isExpanded: $macSectionExpanded,
                content: {
                    Text(site.namePatternMac ?? "N/A")
                },
                label: {
                    Text("**MAC Count:** \(1)")
                }
            )
            
            DisclosureGroup(
                isExpanded: $bwPrinterSectionExpanded,
                content: {
                    Text(site.namePatternMac ?? "N/A")
                },
                label: {
                    Text("**B&W Printer Count:** \(1)")
                }
            )
            
            DisclosureGroup(
                isExpanded: $colorPrinterSectionExpanded,
                content: {
                    Text(site.namePatternMac ?? "N/A")
                },
                label: {
                    Text("**Color Printer Count:** \(1)")
                }
            )
            
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
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }
}
