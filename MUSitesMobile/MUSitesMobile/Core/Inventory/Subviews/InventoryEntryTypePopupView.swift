//
//  InventoryEntryTypePopupView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/22/24.
//

import SwiftUI

struct EntryTypePopupView: View {
    @State var selectedOption: InventoryEntryType = .Check

    var body: some View {
        VStack {
            Text("You did not confirm all counts, would you like to report this?")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .padding(.horizontal, 28)

            RadioButton(text: "Yes, there is a discrepancy.", isSelected: selectedOption == .Fix) {
                selectedOption = .Fix
            }
            .padding(.bottom)

            RadioButton(text: "Yes, there was a delivery.", isSelected: selectedOption == .Delivery) {
                selectedOption = .Delivery
            }
            .padding(.bottom)

            Divider()

            Button("Submit") {
                // Dismiss the alert
            }
            .padding()
        }
        .padding()
        .background()
        .cornerRadius(10)
        .overlay(alignment: .topTrailing) {
            close
        }
    }
}

#Preview {
    EntryTypePopupView()
        .padding()
        .background(.blue)
        .previewLayout(.sizeThatFits)
}

private extension EntryTypePopupView {
    var close: some View {
        Button(action: {

        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.gray)
                .opacity(1)
                .padding()
        }
    }
}
