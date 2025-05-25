import Foundation
import Charts

/// Main view model for the dashboard, handling all metric computation and state
@MainActor
public class DashboardViewModel: ObservableObject {
    // MARK: - Data Sources

    @Published public private(set) var entries: [AnalysisEntry] = []
    @Published var dateRange: DateRange = .sevenDays {
        didSet { computeAll() }
    }
    @Published public private(set) var filteredEntries: [AnalysisEntry] = []

    // MARK: - Chart Metrics

    @Published public private(set) var severityDist: [SeverityCount] = []
    @Published public private(set) var topActors: [ActorCount] = []
    @Published public private(set) var timeline: [TimelineDateCount] = []
    @Published public private(set) var topCVEs: [CVECount] = []
    @Published public private(set) var criticalTimeline: [CriticalAlertCount] = []

    // --- NEW CHART METRICS ---
    @Published public private(set) var topTTPs: [TTPCount] = []
    @Published public private(set) var topAttackVectors: [AttackVectorCount] = []
    @Published public private(set) var topTools: [ToolCount] = []
    @Published public private(set) var topMalware: [MalwareCount] = []
    @Published public private(set) var topGeographies: [GeoCount] = []
    @Published public private(set) var topFeeds: [FeedCount] = []

    // MARK: - Data Loading

    public func loadData() async {
        do {
            let url = URL(string: "https://tigerblue.app/api/analysis")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedEntries = try decoder.decode([AnalysisEntry].self, from: data)
            entries = decodedEntries
            computeAll()
        } catch {
            print("❌ loadData error:", error)
        }
    }

    // MARK: - Metric Computation

    private func computeAll() {
        // 1) Filter by selected date range
        if let cutoff = dateRange.cutoff {
            filteredEntries = entries.filter {
                guard let published = $0.published else { return false }
                return published >= cutoff
            }
        } else {
            filteredEntries = entries
        }

        // 2) Severity Distribution
        let bySeverity = Dictionary(grouping: filteredEntries, by: { $0.severityLevel.uppercased() })
        severityDist = bySeverity.map { level, items in
            SeverityCount(severity: level, count: items.count)
        }
        .sorted { $0.count > $1.count }

        // 3) Top Threat Actors
        let allActors = filteredEntries.flatMap { $0.potentialThreatActors }
        let actorCounts = Dictionary(allActors.map { ($0, 1) }, uniquingKeysWith: +)
        topActors = actorCounts.map { actor, count in
            ActorCount(actor: actor, count: count)
        }
        .sorted { $0.count > $1.count }

        // 4) Daily Timeline
        let groupedDaily = Dictionary(grouping: filteredEntries, by: {
            Calendar.current.startOfDay(for: $0.analysedAt)
        })
        timeline = groupedDaily.map { day, items in
            TimelineDateCount(date: day, count: items.count)
        }
        .sorted { $0.date < $1.date }

        // 5) Top CVE Identifiers
        let allCves = filteredEntries.flatMap { $0.cveReferences }
        let cveCounts = Dictionary(allCves.map { ($0, 1) }, uniquingKeysWith: +)
        topCVEs = cveCounts.map { cve, count in
            CVECount(cve: cve, count: count)
        }
        .sorted { $0.count > $1.count }

        // 6) Critical Alerts Over Time
        let criticalOnly = filteredEntries.filter { $0.severityLevel.uppercased() == "CRITICAL" }
        let groupedCritical = Dictionary(grouping: criticalOnly, by: {
            Calendar.current.startOfDay(for: $0.analysedAt)
        })
        criticalTimeline = groupedCritical.map { day, items in
            CriticalAlertCount(date: day, count: items.count)
        }
        .sorted { $0.date < $1.date }

        // --- NEW CHART DATA ---

        // Top MITRE ATT&CK TTPs
        let allTTPs = filteredEntries.flatMap { $0.ttps }
        let ttpCounts = Dictionary(allTTPs.map { ($0, 1) }, uniquingKeysWith: +)
        topTTPs = ttpCounts.map { TTPCount(ttp: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // Top Attack Vectors
        let allAttackVectors = filteredEntries.flatMap { $0.attackVectors }
        let avCounts = Dictionary(allAttackVectors.map { ($0, 1) }, uniquingKeysWith: +)
        topAttackVectors = avCounts.map { AttackVectorCount(attackVector: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // Top Tools
        let allTools = filteredEntries.flatMap { $0.toolsUsed }
        let toolCounts = Dictionary(allTools.map { ($0, 1) }, uniquingKeysWith: +)
        topTools = toolCounts.map { ToolCount(tool: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // Top Malware Families
        let allMalware = filteredEntries.flatMap { $0.malwareFamilies }
        let malwareCounts = Dictionary(allMalware.map { ($0, 1) }, uniquingKeysWith: +)
        topMalware = malwareCounts.map { MalwareCount(malware: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // Top Geographies
        let allGeos = filteredEntries.flatMap { $0.targetGeographies }
        let geoCounts = Dictionary(allGeos.map { ($0, 1) }, uniquingKeysWith: +)
        topGeographies = geoCounts.map { GeoCount(geo: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        // Top Feeds (for feed_title or source_name)
        let allFeeds = filteredEntries.compactMap { $0.feedTitle ?? $0.sourceName }
        let feedCounts = Dictionary(allFeeds.map { ($0, 1) }, uniquingKeysWith: +)
        topFeeds = feedCounts.map { FeedCount(feed: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}

// MARK: - Supporting Models

public struct TimelineDateCount: Identifiable, Equatable {
    public let id = UUID()
    public let date: Date
    public let count: Int
}
public struct CriticalAlertCount: Identifiable {
    public let id = UUID()
    public let date: Date
    public let count: Int
}

// --- NEW MODELS ---

public struct TTPCount: Identifiable {
    public let id = UUID()
    public let ttp: String
    public let count: Int
}
public struct AttackVectorCount: Identifiable {
    public let id = UUID()
    public let attackVector: String
    public let count: Int
}
public struct ToolCount: Identifiable {
    public let id = UUID()
    public let tool: String
    public let count: Int
}
public struct MalwareCount: Identifiable {
    public let id = UUID()
    public let malware: String
    public let count: Int
}
public struct GeoCount: Identifiable {
    public let id = UUID()
    public let geo: String
    public let count: Int
}
public struct FeedCount: Identifiable {
    public let id = UUID()
    public let feed: String
    public let count: Int
}
