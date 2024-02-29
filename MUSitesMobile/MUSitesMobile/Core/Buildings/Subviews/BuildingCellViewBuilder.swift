//
//  BuildingCellViewBuilder.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/22/24.
//

import SwiftUI

struct BuildingCellViewBuilder: View {
    
    let buildingId: String
    @State private var building: Building? = nil
    
    var body: some View {
        ZStack { // ZStack should be the same size as BuildingCellView while loading eventually
            if let building {
                BuildingCellView(building: building)
            }
        }
        .task {
            self.building = try? await BuildingsManager.shared.getBuilding(buildingId: buildingId)
        }
    }
}

#Preview {
    BuildingCellViewBuilder(buildingId: "yXT87CrCZCoJVRvZn5DC")
}
