    //
    //  AnalysisModels.swift
    //  threatkitty
    //
    //  Created by Mike Harris on 04/05/2025.
    //
    //  Decodes JSON feed into Swift, handles ISO8601 dates,
    //  and makes every entry Identifiable & Hashable.
    //

    import Foundation

    public struct AnalysisEntry: Identifiable, Decodable, Hashable {
        public let id = UUID()
        public let guid: String
        public let title: String
        public let link: String
        public let published: Date?        // may be null/missing
        public let content: String
        public let severityLevel: String
        public let confidencePct: Int
        public let historicalContext: String?
        public let summaryImpact: String?
        public let relevance: String?
        public let additionalNotes: String?
        public let sourceName: String?
        public let sourceURL: URL?
        public let analysedAt: Date        // always present
        public let recommendedActions: [String]
        public let keyIOCs: [String]
        public let affectedSystemsSectors: [String]
        public let mitigationStrategies: [String]
        public let potentialThreatActors: [String]
        public let cveReferences: [String]
        
        enum CodingKeys: String, CodingKey {
            case guid, title, link, content, published
            case severityLevel = "severity_level"
            case confidencePct = "confidence_pct"
            case historicalContext = "historical_context"
            case summaryImpact = "summary_impact"
            case relevance
            case additionalNotes = "additional_notes"
            case sourceName    = "source_name"
            case sourceURL     = "source_url"
            case analysedAt    = "analysed_at"
            case recommendedActions = "recommended_actions"
            case keyIOCs       = "key_iocs"
            case affectedSystemsSectors = "affected_systems_sectors"
            case mitigationStrategies   = "mitigation_strategies"
            case potentialThreatActors  = "potential_threat_actors"
            case cveReferences = "cve_references"
        }
        
        /// ISO8601 parser that handles both plain and fractional‐seconds forms.
        private static let iso8601: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()
        
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            guid    = try c.decode(String.self, forKey: .guid)
            title   = try c.decode(String.self, forKey: .title)
            link    = try c.decode(String.self, forKey: .link)
            content = try c.decode(String.self, forKey: .content)
            
            severityLevel     = try c.decode(String.self, forKey: .severityLevel)
            confidencePct     = try c.decode(Int.self,    forKey: .confidencePct)
            historicalContext = try c.decodeIfPresent(String.self, forKey: .historicalContext)
            summaryImpact     = try c.decodeIfPresent(String.self, forKey: .summaryImpact)
            relevance         = try c.decodeIfPresent(String.self, forKey: .relevance)
            additionalNotes   = try c.decodeIfPresent(String.self, forKey: .additionalNotes)
            sourceName        = try c.decodeIfPresent(String.self, forKey: .sourceName)
            sourceURL         = try c.decodeIfPresent(URL.self,    forKey: .sourceURL)
            
            // parse analysedAt (always non‐optional)
            let analysedRaw = try c.decode(String.self, forKey: .analysedAt)
            analysedAt = try AnalysisEntry.parseISO8601(analysedRaw)
            
            // parse published (optional)
            if let pubRaw = try c.decodeIfPresent(String.self, forKey: .published) {
                published = try AnalysisEntry.parseISO8601(pubRaw)
            } else {
                published = nil
            }
            
            recommendedActions      = try c.decodeIfPresent([String].self, forKey: .recommendedActions)      ?? []
            keyIOCs                 = try c.decodeIfPresent([String].self, forKey: .keyIOCs)                 ?? []
            affectedSystemsSectors  = try c.decodeIfPresent([String].self, forKey: .affectedSystemsSectors)  ?? []
            mitigationStrategies    = try c.decodeIfPresent([String].self, forKey: .mitigationStrategies)    ?? []
            potentialThreatActors   = try c.decodeIfPresent([String].self, forKey: .potentialThreatActors)   ?? []
            cveReferences           = try c.decodeIfPresent([String].self, forKey: .cveReferences)           ?? []
        }
        
        /// Accept either “2025-04-25T14:05:00Z” or “2025-04-25T14:05:00.123Z”
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
        
        private static func parseISO8601(_ raw: String) throws -> Date {
            // ensure there's a timezone designator
            let hasZone = raw.hasSuffix("Z")
                        || raw.range(of: #"[+\-]\d\d:\d\d$"#, options: .regularExpression) != nil
            let candidate = hasZone ? raw : raw + "Z"

            // try fractional‐seconds first
            if let d = isoWithFraction.date(from: candidate) {
                return d
            }
            // fall back to seconds‐only
            if let d = isoNoFraction.date(from: candidate) {
                return d
            }
            // still no luck: rethrow your old error
            throw DecodingError.dataCorrupted(
              .init(codingPath: [], debugDescription: "Bad ISO8601 date: \(raw)")
            )
        }
        
        
        
    }


    /// Which date window users can pick in the dashboard
    public enum DateRange: String, CaseIterable, Identifiable {
      case last24Hours
      case sevenDays
      case thirtyDays
      case ninetyDays
      case allTime

      public var displayName: String {
        switch self {
        case .last24Hours: return "Last 24h"
        case .sevenDays:   return "Last 7 Days"
        case .thirtyDays:  return "Last 30 Days"
        case .ninetyDays:  return "Last 90 Days"
        case .allTime:     return "All Time"
        }
      }

        public var id: String { rawValue }
        
        public var cutoff: Date? {
            let now = Date()
            switch self {
            case .last24Hours:
                return Calendar.current.date(byAdding: .hour,   value: -24, to: now)
            case .sevenDays:
                return Calendar.current.date(byAdding: .day,    value: -7,  to: now)
            case .thirtyDays:
                return Calendar.current.date(byAdding: .day,    value: -30, to: now)
            case .ninetyDays:
                return Calendar.current.date(byAdding: .day,    value: -90, to: now)
            case .allTime:
                return nil
            }
        }
        
        
    }


