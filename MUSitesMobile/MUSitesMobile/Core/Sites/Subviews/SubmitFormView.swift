//
//  SubmitFormView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI

struct SubmitView: View {
    var siteName: String
    
    var body: some View {
        VStack {
            Text("Submit View for \(siteName)")
                .font(.title)
                .padding()
            
            NavigationLink(destination: SiteCaptainSubmissionView(siteName: siteName)) {
                Text("Go to Site Captain Form")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    NavigationView {
        SubmitView(siteName: "Sample Site")
    }
}
