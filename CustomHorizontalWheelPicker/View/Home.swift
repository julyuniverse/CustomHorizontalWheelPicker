//
//  HomeView.swift
//  CustomHorizontalWheelPicker
//
//  Created by July universe on 1/1/24.
//

import SwiftUI
import AudioToolbox

struct Home: View {
    @State var offset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 15) {
            Image("excersize")
                .resizable()
                .frame(width: 300, height: 300)
                .padding(.top, 40)
            Spacer(minLength: 0)
            Text("Weight")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.black)
            Text("\(getWeight()) Kg")
                .font(.system(size: 38, weight: .heavy))
                .foregroundColor(Color("purple"))
                .padding(.bottom, 20)
            
            // ie from 40kg to 100kg
            let pickerCount = 6
            CustomSlider(pickerCount: pickerCount, offset: $offset, content: {
                HStack(spacing: 0) {
                    ForEach(1...pickerCount, id: \.self) { index in
                        VStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 1, height: 30)
                            Text("\(30 + (index * 10))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        // each picker tick will have 20 width
                        .frame(width: 20)
                        
                        // subticks
                        // fixed subticks will have four for each main tick
                        ForEach(1...4, id: \.self) { subIndex in
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 1, height: 15)
                            // each picker tick will have 20 width
                                .frame(width: 20)
                        }
                    }
                    VStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 1, height: 30)
                        Text("\(100)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    // each picker tick will have 20 width
                    .frame(width: 20)
                }
            })
            // maxheight
            .frame(height: 50)
            .overlay(
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1, height: 50)
                    .offset(x: 1, y: -30)
            )
            .padding()
            Button(action: {}) {
                Text("Next")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 60)
                    .background(Color("purple"))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: -5)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // Custom slider
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Circle()
                .fill(Color("purple"))
            // Enlarging circle
                .scaleEffect(1.5)
            // Moving up
                .offset(y: -getRect().height / 2.4)
        )
    }
    
    func getWeight() -> String {
        // since our weight starts from 40
        let startWeight = 40
        let progress = offset / 20
        
        // each subtick will calculated as 2
        return "\(startWeight + (Int(progress) * 2))"
    }
}

#Preview {
    Home()
}

// Screen size
func getRect() -> CGRect {
    return UIScreen.main.bounds
}

// were going to build custom slider with the help of uiscrollview in UIKit
// with the help of view Builders
struct CustomSlider<Content: View>: UIViewRepresentable {
    var content: Content
    
    // Binding offset for KG Calculations
    @Binding var offset: CGFloat
    var pickerCount: Int
    
    init(pickerCount: Int, offset: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._offset = offset
        self.pickerCount = pickerCount
    }
    
    func makeCoordinator() -> Coordinator {
        return CustomSlider.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let swiftUIView = UIHostingController(rootView: content).view!
        
        // So swiftui with will be total of pickercount multiplied with 20 + screen size
        // each pickercount have 4 subpickers
        // so 6 * 4 = 24 + 6 = 30
        // picker * 5
        let width = CGFloat((pickerCount * 5) * 20) + (getRect().width - 30)
        swiftUIView.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        scrollView.contentSize = swiftUIView.frame.size
        scrollView.addSubview(swiftUIView)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
    }
    
    // Delegate methods for offset
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: CustomSlider
        
        init(parent: CustomSlider) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.x
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            let value = (offset / 20).rounded(.toNearestOrAwayFromZero)
            scrollView.setContentOffset(CGPoint(x: value * 20, y: 0), animated: false)
            
            // tick and vibrate sound
            // on end
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            // tick sound code
            AudioServicesPlayAlertSound(1157)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // if end delcate not fired
            if !decelerate {
                let offset = scrollView.contentOffset.x
                let value = (offset / 20).rounded(.toNearestOrAwayFromZero)
                scrollView.setContentOffset(CGPoint(x: value * 20, y: 0), animated: false)
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                // tick sound code
                AudioServicesPlayAlertSound(1157)
            }
        }
    }
}
