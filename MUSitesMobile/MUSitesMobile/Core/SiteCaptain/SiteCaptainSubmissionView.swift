//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI

struct SiteCaptainSubmissionView: View {
    var siteName: String
    
    var body: some View {
        VStack {
            Text("Site Captain Form for \(siteName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Add your form content here
            Text("Form content goes here")
        }
        .navigationTitle("Site Captain Form")
    }
}

#Preview {
    NavigationView {
        SiteCaptainSubmissionView(siteName: "Sample Site")
    }
}
