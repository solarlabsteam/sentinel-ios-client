//
//  ActivityIndicator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 11.11.2021.
//

import Cocoa
import SwiftUI

struct ActivityIndicator: NSViewRepresentable {
    @Binding var isAnimating: Bool
    var controlSize: NSControl.ControlSize
    
    func makeNSView(context: NSViewRepresentableContext<ActivityIndicator>) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.controlSize = controlSize
        progressIndicator.isIndeterminate = true
        progressIndicator.style = .spinning
        progressIndicator.isDisplayedWhenStopped = false
        
        return progressIndicator
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
    }
}
