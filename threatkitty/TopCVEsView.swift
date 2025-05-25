//
//  TopCVEsView.swift
//  threatkitty
//
//  Simple list of most-common CVEs
//

import SwiftUI

struct TopCVEsView: View {
    let data: [CVECount]

    var body: some View {
        ChartSection("Top CVE Identifiers") {
            if data.isEmpty {
                Text("No CVE identifiers found for this period.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(data) { item in
                            Text("• \(item.cve) (\(item.count))")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
