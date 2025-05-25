//
//  RotationDetector.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  A ViewModifier for device orientation detection.
//

import SwiftUI

/// A ViewModifier that listens for device‐orientation changes
struct DeviceRotationViewModifier: ViewModifier {
  let action: (UIDeviceOrientation) -> Void

  func body(content: Content) -> some View {
    content
      .onAppear {
        // Start listening when the view appears
        NotificationCenter.default.addObserver(
          forName: UIDevice.orientationDidChangeNotification,
          object: nil,
          queue: .main
        ) { _ in
          action(UIDevice.current.orientation)
        }
      }
  }
}

extension View {
  /// Call `action` whenever the device rotates.
  func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
    self.modifier(DeviceRotationViewModifier(action: action))
  }
}
