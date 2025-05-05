//
//  ChartSection.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  A styled container with title for each chart

import SwiftUI

struct ChartSection<Content: View>: View {
    let title: String
    let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.pink, .purple]),
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            content()
                .frame(height: 180)
                .background(RoundedRectangle(cornerRadius: 12)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [.pink, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 2)
                                .background(Color.black)
                )
        }
    }
}
