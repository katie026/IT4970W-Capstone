//
//  SiteCaptainFormView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI

struct SiteCaptainFormView: View {
    @Binding var siteCleanedToggle: Bool
    @Binding var selectedThingsToClean: [Bool]
    @Binding var selectedThingsToDo: [Bool]
    @Binding var needsRepair: Bool
    @Binding var issueDescription: String
    @Binding var ticketNumber: String
    @Binding var needsLabelReplacement: Bool
    @Binding var labelsToReplace: String
    @Binding var hasInventoryLocation: Bool
    @Binding var inventoryChecked: Bool
    
    let thingsToClean = [
        "Wipe down the keyboards, mice, all desks, and monitors for each workstation",
        "Wipe down the printer",
        "Tidy up the cords",
        "Push in the chairs",
        "Ensure every computer has a chair",
        "Fill the printer with paper",
        "Clean whiteboard (if there is one)"
    ]
    
    let thingsToDo = [
        "Check the projector (if there is one)",
        "Check the dry erase markers",
        "Check the classroom calendars are up to date (if not, contact a CS)",
        "Remove non-DoIT posters from the classroom poster board"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Were you able to clean this site?", isOn: $siteCleanedToggle)
                .padding()
            
            if siteCleanedToggle {
                VStack(alignment: .leading) {
                    Text("3. Things to clean!")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(thingsToClean.indices, id: \.self) { index in
                        HStack {
                            Button(action: {
                                selectedThingsToClean[index].toggle()
                            }) {
                                Image(systemName: selectedThingsToClean[index] ? "checkmark.square" : "square")
                            }
                            Text(thingsToClean[index])
                        }
                    }
                    
                    Text("4. Things to do!")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(thingsToDo.indices, id: \.self) { index in
                        HStack {
                            Button(action: {
                                selectedThingsToDo[index].toggle()
                            }) {
                                Image(systemName: selectedThingsToDo[index] ? "checkmark.square" : "square")
                            }
                            Text(thingsToDo[index])
                        }
                    }
                }
                .padding()
                
                Text("Is there anything that needs repair? (clock, keyboard, mouse, projector, missing chairs, etc.)")
                    .padding()
                
                HStack {
                    Button(action: {
                        needsRepair = false
                    }) {
                        Text("Nope, all is good")
                            .foregroundColor(needsRepair ? .primary : .blue)
                    }
                    
                    Button(action: {
                        needsRepair = true
                    }) {
                        Text("Yes, things are not quite right")
                            .foregroundColor(needsRepair ? .blue : .primary)
                    }
                }
                
                if needsRepair {
                    VStack {
                        Text("What issues are there in your site?")
                        
                        TextField("Enter the issue description", text: $issueDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("Enter the ticket number(s) below for the problems you encountered.")
                        Text("If no tickets were needed, leave it blank.")
                        
                        TextField("Enter the 7-digit ticket number", text: $ticketNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.numberPad)
                    }
                }
                
                Text("Are there any table or printer labels that need to be replaced?")
                    .padding()
                
                HStack {
                    Button(action: {
                        needsLabelReplacement = false
                    }) {
                        Text("Nope, all is good")
                            .foregroundColor(needsLabelReplacement ? .primary : .blue)
                    }
                    
                    Button(action: {
                        needsLabelReplacement = true
                    }) {
                        Text("Yes, I contacted a CS about it")
                            .foregroundColor(needsLabelReplacement ? .blue : .primary)
                    }
                }
                
                if needsLabelReplacement {
                    VStack {
                        Text("9. Which labels need to be replaced?")
                        
                        TextField("Enter the labels that need replacement", text: $labelsToReplace)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                }
                
                Text("Does your site building have a cabinet/inventory location?")
                    .padding()
                
                HStack {
                    Button(action: {
                        hasInventoryLocation = true
                    }) {
                        Text("Yes")
                            .foregroundColor(hasInventoryLocation ? .blue : .primary)
                    }
                    
                    Button(action: {
                        hasInventoryLocation = false
                    }) {
                        Text("No")
                            .foregroundColor(hasInventoryLocation ? .primary : .blue)
                    }
                }
                
                if hasInventoryLocation {
                    VStack {
                        Text("8. Did you check the inventory?")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack {
                            Button(action: {
                                inventoryChecked = true
                            }) {
                                Text("Yes")
                                    .foregroundColor(inventoryChecked ? .blue : .primary)
                            }
                            
                            Button(action: {
                                inventoryChecked = false
                            }) {
                                Text("No, I did not use any supplies and am not in the building of any inventory locations.")
                                    .foregroundColor(inventoryChecked ? .primary : .blue)
                            }
                        }
                    }
                }
            }
        }
    }
}
