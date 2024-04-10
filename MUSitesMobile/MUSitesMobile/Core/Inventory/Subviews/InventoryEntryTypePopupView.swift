//
//  InventoryEntryTypePopupView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/22/24.
//

import SwiftUI

struct EntryTypePopupView: View {
    // Closure
    let didClose: () -> Void
    
    // Binded variables
    @Binding var selectedOption: InventoryEntryType
    @Binding var submitClicked: Bool

    var body: some View {
        VStack {
            Text("You did not confirm all counts, would you like to report this?")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .padding(.horizontal, 28)
                .foregroundColor(Color.black)
            
            if selectedOption == .MovedFrom {
                RadioButton(text: "Yes, I moved these supplies.", isSelected: selectedOption == .MovedFrom) {
                    selectedOption = .MovedFrom
                }
                .padding(.bottom)
            } else {
                RadioButton(text: "Yes, there is a discrepancy.", isSelected: selectedOption == .Fix) {
                    selectedOption = .Fix
                }
                .padding(.bottom)
                
                RadioButton(text: "Yes, there was a delivery.", isSelected: selectedOption == .Delivery) {
                    selectedOption = .Delivery
                }
                .padding(.bottom)
            }

            Divider()

            Button("Submit") {
                // tell parent view Submit button was clicked
                submitClicked = true
                // call closure
                didClose()
            }
            .padding()
        }
        .padding()
        .background(background)
        .cornerRadius(10)
        .overlay(alignment: .topTrailing) {
            close
        }
        .transition(.move(edge: .bottom))
        .onAppear {
            // set default option
            if (selectedOption != .MovedFrom && selectedOption != .Fix && selectedOption != .Delivery) {
                selectedOption = .Fix
            } else {
                selectedOption = selectedOption
            }
        }
    }
}

#Preview {
    EntryTypePopupView(didClose: {}, selectedOption: .constant(.Check), submitClicked: .constant(false))
        .padding()
        .background(.blue)
        .previewLayout(.sizeThatFits)
}

private extension EntryTypePopupView {
    var close: some View {
        Button(action: {
            // call closure
            didClose()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.gray)
                .opacity(1)
                .padding()
        }
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.9), radius: 3)
    }
}
