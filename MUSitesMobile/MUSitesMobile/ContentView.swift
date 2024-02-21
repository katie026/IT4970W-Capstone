//
//  ContentView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world! I'm Katie.")
                Image(systemName: "pencil")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello world! Michael here")
                Text("Hello world! This is Karch")
                Text("Tristan :)")
                
                // Button to navigate to SitesMap for testing purposes
                NavigationLink(destination: SitesMap()) {
                    Text("Go to Sites Map")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

