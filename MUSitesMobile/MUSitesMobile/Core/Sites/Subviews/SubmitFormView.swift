//
//  SubmitFormView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI

struct SubmitView: View {
    let site: Site
    
    var body: some View {
        NavigationLink(destination: SiteCaptainSubmissionView(siteId: site.id, siteName: site.name ?? "")) {
            HStack {
                Spacer(minLength: 4)
                Text("Submit a Form")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
    }
}

