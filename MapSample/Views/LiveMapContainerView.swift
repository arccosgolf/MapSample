//
//  LiveMapContainerView.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import SwiftUI

struct LiveMapContainerView: View {
    
    private let coordinator: LiveMapStateCoordinator
    private let headerViewModel: LiveMapHeaderViewModel
    private let mapViewModel: LiveMapViewModel
    
    init() {
        self.coordinator = LiveMapStateCoordinator()
        self.headerViewModel = LiveMapHeaderViewModel(coordinator: coordinator)
        self.mapViewModel = LiveMapViewModel(coordinator: coordinator)
    }
    
    var body: some View {
        ZStack {
            LiveMapViewControllerRepresentable(viewModel: mapViewModel)
            VStack() {
                LiveMapHeaderView(viewModel: headerViewModel)
                Spacer()
            }
        }.ignoresSafeArea()
    }
}

#Preview {
    LiveMapContainerView()
}
