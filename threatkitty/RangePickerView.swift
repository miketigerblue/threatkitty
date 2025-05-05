////
//  RangePickerView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//  A segmented‐control picker bound to DashboardViewModel.DateRange.
//

import SwiftUI

struct RangePickerView: View {
  @Binding var selectedRange: DateRange

  var body: some View {
    Picker("Time Range", selection: $selectedRange) {
      ForEach(DateRange.allCases) { range in
        Text(range.rawValue).tag(range)
      }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal)
  }
}
