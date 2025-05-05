//
//  MetricsModels.swift
//  threatkitty
//
//  Little structs for chart data.
//

import Foundation

public struct DateCount: Identifiable {
    public let id = UUID()
    public let date: Date
    public let count: Int
}

public struct SeverityCount: Identifiable {
    public let id = UUID()
    public let severity: String
    public let count: Int
}

public struct ActorCount: Identifiable {
    public let id = UUID()
    public let actor: String
    public let count: Int
}

public struct ActionCount: Identifiable {
    public let id = UUID()
    public let action: String
    public let count: Int
}

public struct CVECount: Identifiable {
    public let id = UUID()
    public let cve: String
    public let count: Int
}

