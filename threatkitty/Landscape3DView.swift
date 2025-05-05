//
//  Landscape3DView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  SceneKit-based 3D world stub for landscape mode

import SwiftUI
import SceneKit

struct Landscape3DView: UIViewRepresentable {
    let entries: [AnalysisEntry]

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = SCNScene()
        view.allowsCameraControl = true
        view.backgroundColor = .black

        // TODO: build fractal geometry + AI models based on `entries`

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // React to new entries if needed
    }
}
