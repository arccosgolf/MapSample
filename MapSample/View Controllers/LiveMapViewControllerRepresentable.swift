//
//  LiveMapViewControllerRepresentable.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import SwiftUI

struct LiveMapViewControllerRepresentable: UIViewControllerRepresentable {
    
    @StateObject var viewModel: LiveMapViewModel
    
    func makeUIViewController(context: Context) -> LiveMapViewController {
        let viewController = UIStoryboard(name: "LiveMap", bundle: Bundle.main).instantiateViewController(withIdentifier: "LiveMapViewController") as! LiveMapViewController
        viewModel.dataSource = viewController
        viewModel.delegate = viewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: LiveMapViewController, context: Context) { }
}
