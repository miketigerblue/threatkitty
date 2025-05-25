
//
//  DateRange.swift
//  threatkitty
//
//  Created by Mike Harris on 24/05/2025.
//

import Foundation

/// Preset date ranges for filtering dashboard data
enum DateRange: String, CaseIterable, Identifiable {
    case oneDay = "1 Day"
    case threeDays = "3 Days"
    case sevenDays = "7 Days"
    case thirtyDays = "30 Days"
    case allTime = "All"

    var id: Self { self }

    /// User-friendly name
    var displayName: String {
        switch self {
        case .oneDay: return "1D"
        case .threeDays: return "3D"
        case .sevenDays: return "7D"
        case .thirtyDays: return "30D"
        case .allTime: return "All"
        }
    }

    /// Date cutoff, or nil for 'All'
    var cutoff: Date? {
        switch self {
        case .oneDay:      return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        case .threeDays:   return Calendar.current.date(byAdding: .day, value: -3, to: Date())
        case .sevenDays:   return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .thirtyDays:  return Calendar.current.date(byAdding: .day, value: -30, to: Date())
        case .allTime:     return nil
        }
    }
}
