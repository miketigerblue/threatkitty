//
//  AnalysisModels.swift
//  threatkitty
//
//  Updated for 2025 API fields, including feed metadata and MITRE ATT&CK/other lists.
//

import Foundation

/// Model representing a single cyber threat intelligence analysis entry
public struct AnalysisEntry: Identifiable, Decodable, Hashable {
    public var id: String { guid }

    public let guid: String
    public let title: String
    public let link: String
    public let published: Date?
    public let content: String?
    public let severityLevel: String
    public let confidencePct: Int
    public let historicalContext: String?
    public let summaryImpact: String?
    public let relevance: String?
    public let additionalNotes: String?
    public let sourceName: String?
    public let sourceURL: String?
    // NEW feed metadata fields
    public let feedTitle: String?
    public let feedDescription: String?
    public let feedLanguage: String?
    public let feedIcon: String?
    public let feedUpdated: Date?
    public let analysedAt: Date

    public let recommendedActions: [String]
    public let keyIOCs: [String]
    public let affectedSystemsSectors: [String]
    public let mitigationStrategies: [String]
    public let potentialThreatActors: [String]
    public let cveReferences: [String]
    // NEW arrays for MITRE ATT&CK, tools, etc
    public let ttps: [String]
    public let attackVectors: [String]
    public let toolsUsed: [String]
    public let malwareFamilies: [String]
    public let targetGeographies: [String]
    public let exploitReferences: [String]

    enum CodingKeys: String, CodingKey {
        case guid, title, link, published, content
        case severityLevel = "severity_level"
        case confidencePct = "confidence_pct"
        case historicalContext = "historical_context"
        case summaryImpact = "summary_impact"
        case relevance
        case additionalNotes = "additional_notes"
        case sourceName = "source_name"
        case sourceURL = "source_url"
        case feedTitle = "feed_title"
        case feedDescription = "feed_description"
        case feedLanguage = "feed_language"
        case feedIcon = "feed_icon"
        case feedUpdated = "feed_updated"
        case analysedAt = "analysed_at"
        case recommendedActions = "recommended_actions"
        case keyIOCs = "key_iocs"
        case affectedSystemsSectors = "affected_systems_sectors"
        case mitigationStrategies = "mitigation_strategies"
        case potentialThreatActors = "potential_threat_actors"
        case cveReferences = "cve_references"
        case ttps
        case attackVectors = "attack_vectors"
        case toolsUsed = "tools_used"
        case malwareFamilies = "malware_families"
        case targetGeographies = "target_geographies"
        case exploitReferences = "exploit_references"
    }

    /// Custom ISO8601 parsing (handles with/without fractions and nullables)
    private static let isoWithFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let isoNoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guid = try c.decode(String.self, forKey: .guid)
        title = try c.decode(String.self, forKey: .title)
        link = try c.decode(String.self, forKey: .link)
        content = try c.decodeIfPresent(String.self, forKey: .content)
        severityLevel = try c.decode(String.self, forKey: .severityLevel)
        confidencePct = try c.decode(Int.self, forKey: .confidencePct)
        historicalContext = try c.decodeIfPresent(String.self, forKey: .historicalContext)
        summaryImpact = try c.decodeIfPresent(String.self, forKey: .summaryImpact)
        relevance = try c.decodeIfPresent(String.self, forKey: .relevance)
        additionalNotes = try c.decodeIfPresent(String.self, forKey: .additionalNotes)
        sourceName = try c.decodeIfPresent(String.self, forKey: .sourceName)
        sourceURL = try c.decodeIfPresent(String.self, forKey: .sourceURL)
        feedTitle = try c.decodeIfPresent(String.self, forKey: .feedTitle)
        feedDescription = try c.decodeIfPresent(String.self, forKey: .feedDescription)
        feedLanguage = try c.decodeIfPresent(String.self, forKey: .feedLanguage)
        feedIcon = try c.decodeIfPresent(String.self, forKey: .feedIcon)

        // Dates (published and feedUpdated) are optional, can be null or missing
        if let pubRaw = try c.decodeIfPresent(String.self, forKey: .published) {
            published = try? Self.parseISO8601(pubRaw)
        } else {
            published = nil
        }
        if let feedUpdRaw = try c.decodeIfPresent(String.self, forKey: .feedUpdated) {
            feedUpdated = try? Self.parseISO8601(feedUpdRaw)
        } else {
            feedUpdated = nil
        }

        // analysedAt (required)
        let analysedRaw = try c.decode(String.self, forKey: .analysedAt)
        analysedAt = try Self.parseISO8601(analysedRaw)

        recommendedActions = try c.decodeIfPresent([String].self, forKey: .recommendedActions) ?? []
        keyIOCs = try c.decodeIfPresent([String].self, forKey: .keyIOCs) ?? []
        affectedSystemsSectors = try c.decodeIfPresent([String].self, forKey: .affectedSystemsSectors) ?? []
        mitigationStrategies = try c.decodeIfPresent([String].self, forKey: .mitigationStrategies) ?? []
        potentialThreatActors = try c.decodeIfPresent([String].self, forKey: .potentialThreatActors) ?? []
        cveReferences = try c.decodeIfPresent([String].self, forKey: .cveReferences) ?? []

        ttps = try c.decodeIfPresent([String].self, forKey: .ttps) ?? []
        attackVectors = try c.decodeIfPresent([String].self, forKey: .attackVectors) ?? []
        toolsUsed = try c.decodeIfPresent([String].self, forKey: .toolsUsed) ?? []
        malwareFamilies = try c.decodeIfPresent([String].self, forKey: .malwareFamilies) ?? []
        targetGeographies = try c.decodeIfPresent([String].self, forKey: .targetGeographies) ?? []
        exploitReferences = try c.decodeIfPresent([String].self, forKey: .exploitReferences) ?? []
    }

    /// Flexible ISO8601 date parser
    private static func parseISO8601(_ raw: String) throws -> Date {
        let hasZone = raw.hasSuffix("Z") || raw.range(of: #"[+\-]\d\d:\d\d$"#, options: .regularExpression) != nil
        let candidate = hasZone ? raw : raw + "Z"
        if let d = isoWithFraction.date(from: candidate) { return d }
        if let d = isoNoFraction.date(from: candidate) { return d }
        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Bad ISO8601 date: \(raw)")
        )
    }
}
