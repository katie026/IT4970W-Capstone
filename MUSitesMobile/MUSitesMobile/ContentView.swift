//
//  ContentView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
