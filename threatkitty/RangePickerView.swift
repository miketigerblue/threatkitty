////
//  RangePickerView.swift
//  threatkitty
//
//  A segmented‐control picker bound to DashboardViewModel.DateRange.
//

import SwiftUI

struct RangePickerView: View {
  @Binding var selectedRange: DateRange

  var body: some View {
    Picker("Time Range", selection: $selectedRange) {
      ForEach(DateRange.allCases, id: \.self) { range in
        Text(range.rawValue).tag(range)
      }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal)
  }
}
