//
//  LiveMapHeaderView.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import SwiftUI

struct LiveMapHeaderView: View {
    
    @StateObject var viewModel: LiveMapHeaderViewModel
    
    let kWidthOfHoleView: CGFloat = 44
    let kHeightOfHoleView: CGFloat = 44
    let kPaddingOfHoleView: CGFloat = 8
    
    @Environment(\.frame) private var frame: CGRect
    @Environment(\.safeAreaInsets) private var insets: EdgeInsets
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollViewReader { scrollview in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack {
                            HStack(spacing: kPaddingOfHoleView) {
                                ForEach(1...viewModel.numberOfHoles, id: \.self) { index in
                                    let isSelectedHole = viewModel.holeId == index
                                    Button {
                                        viewModel.coordinator.onSelectedHoleChange(to: index)
                                    } label: {
                                        Circle()
                                            .fill(isSelectedHole ? .white : .standardGray_14())
                                            .overlay {
                                                Text("\(index)")
                                                    .montserratBold(size: isSelectedHole ? 24 : 18)
                                                    .foregroundColor(isSelectedHole ? .standardGray_14() : .standardGray_67())
                                            }
                                    }.id(index)
                                }
                            }.padding(.horizontal, (geometry.size.width/2) - kWidthOfHoleView/2)
                        }
                    }.onAppear(perform: {
                        scrollview.scrollTo(viewModel.holeId, anchor: .center)
                    }).onChange(of: viewModel.holeId) { newValue in
                        withAnimation {
                            scrollview.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }.frame(height: kHeightOfHoleView)
        }.frame(width: frame.width, height: 88 + insets.top)
            .clipped()
            .background(Color.black)
    }
}
