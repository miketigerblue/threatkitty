//
//  DashboardViewModel.swift
//  threatkitty
//
//  Loads JSON, filters by published‐date, computes all charts & lists.
//

import Foundation

@MainActor
public class DashboardViewModel: ObservableObject {
    @Published public var entries: [AnalysisEntry] = []
    @Published public var dateRange: DateRange    = .sevenDays {
        didSet { computeAll() }
    }
    @Published public private(set) var filteredEntries: [AnalysisEntry] = []
    
    @Published public private(set) var severityDist: [SeverityCount] = []
    @Published public private(set) var topActors:    [ActorCount]   = []
    @Published public private(set) var topActions:   [ActionCount]  = []
    @Published public private(set) var timeline:     [DateCount]    = []
    @Published public private(set) var topCVEs:      [CVECount]     = []
    @Published public private(set) var criticalTimeline: [DateCount] = []
       
    public func loadData() async {
        do {
            let url = URL(string:"https://tigerblue.app/api/analysis")!
            let (raw,_) = try await URLSession.shared.data(from:url)
            let dec = JSONDecoder()
            entries = try dec.decode([AnalysisEntry].self, from:raw)
            computeAll()
        } catch {
            print("❌ loadData error:",error)
        }
    }
    
    private func computeAll() {
        // filter
        if let cutoff = dateRange.cutoff {
            filteredEntries = entries.filter {
                guard let p = $0.published else { return false }
                return p >= cutoff
            }
        } else {
            filteredEntries = entries.filter { $0.published != nil }
        }
        
        // severity
        let bySev = Dictionary(grouping:filteredEntries, by:{ $0.severityLevel })
        severityDist = bySev.map { SeverityCount(severity:$0.key, count:$0.value.count) }
                            .sorted { $0.count > $1.count }
        
        // actors
        let actors = filteredEntries.flatMap(\.potentialThreatActors)
        topActors = Dictionary(actors.map{ ($0,1) }, uniquingKeysWith:+)
                      .map{ ActorCount(actor:$0.key, count:$0.value) }
                      .sorted{ $0.count>$1.count }
        
        // actions
        let actions = filteredEntries.flatMap(\.recommendedActions)
        topActions = Dictionary(actions.map{ ($0,1) }, uniquingKeysWith:+)
                       .map{ ActionCount(action:$0.key, count:$0.value) }
                       .sorted{ $0.count>$1.count }
        
        // timeline
        let days = Dictionary(grouping:
            filteredEntries.compactMap(\.published),
            by:{ Calendar.current.startOfDay(for:$0) }
        )
        timeline = days.map{ DateCount(date:$0.key, count:$0.value.count) }
                       .sorted{ $0.date<$1.date }
        
        // CVEs
        let cves = filteredEntries.flatMap(\.cveReferences)
        topCVEs = Dictionary(cves.map{ ($0,1) }, uniquingKeysWith:+)
                    .map{ CVECount(cve:$0.key, count:$0.value) }
                    .sorted{ $0.count>$1.count }
        
        // critical
        let crit = filteredEntries.filter{ $0.severityLevel.uppercased()=="CRITICAL" }
        let critDays = Dictionary(grouping:
            crit.compactMap(\.published),
            by:{ Calendar.current.startOfDay(for:$0) }
        )
        criticalTimeline = critDays.map{ DateCount(date:$0.key, count:$0.value.count) }
                                   .sorted{ $0.date<$1.date }
    }
}
