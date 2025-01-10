//
//  LiveMapHeaderViewModel.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import Foundation
import Combine
import SwiftUI

final class LiveMapHeaderViewModel: ObservableObject {
    
    let coordinator: LiveMapStateCoordinator
    
    @Published var holeId: Int
    
    fileprivate var subscription: Set<AnyCancellable> = []
    
    var numberOfHoles: Int {
        return coordinator.course.value?.numberOfHoles ?? 1
    }
    
    init(coordinator: LiveMapStateCoordinator) {
        self.coordinator = coordinator
        self.holeId = coordinator.selectedHoleId.value
        
        coordinator.selectedHoleId
        .receive(on: DispatchQueue.main)
        .sink { [weak self] holeId in
            guard let strongSelf = self else { return }
            strongSelf.holeId = holeId
        }.store(in: &subscription)
    }
}
