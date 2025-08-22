import SwiftUI
import Charts

/// Visual dashboard shown after processing completes. Presents charts that summarize
/// usage by company, with a choice of metric and chart type.
struct ProcessedDashboardView: View {
    
    /// Merged, filtered rows (one per user) produced by processing.
    let processedData: [CSVRow]

    /// Chart visualization type.
    enum ChartType: String, CaseIterable, Identifiable {
        case pie = "Pie"
        case bar = "Bar"
        var id: String { rawValue }
    }

    /// Metric to plot.
    enum ChartMetric: String, CaseIterable, Identifiable {
        case employees = "Employees"
        case requests = "Requests"
        var id: String { rawValue }
    }

    /// Aggregate values per company for charting.
    struct CompanyStat: Identifiable {
        let id: String
        let company: String
        let employees: Int
        let requests: Int
    }

    @State private var selectedChartType: ChartType = .pie
    @State private var selectedMetric: ChartMetric = .employees

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            controls
            chart
            totals
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }

    /// Header text for the dashboard.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Usage Dashboard")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Visualize which companies use Cursor the most")
                .foregroundColor(.secondary)
        }
    }

    /// Metric and chart type selectors.
    private var controls: some View {
        HStack(spacing: 12) {
            Picker("Chart", selection: $selectedChartType) {
                ForEach(ChartType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Picker("Metric", selection: $selectedMetric) {
                ForEach(ChartMetric.allCases) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    /// The primary chart, switching between pie and bar representations.
    @ViewBuilder
    private var chart: some View {
        if processedData.isEmpty {
            Text("No processed data available.")
                .foregroundColor(.secondary)
        } else {
            let stats = computeCompanyStats()
            if #available(macOS 13.0, *) {
                switch selectedChartType {
                case .pie:
                    Chart(stats) { stat in
                        let value = selectedMetric == .employees ? stat.employees : stat.requests
                        SectorMark(
                            angle: .value(selectedMetric.rawValue, value),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(by: .value("Company", stat.company))
                        .annotation(position: .overlay) {
                            if value > 0 {
                                Text(stat.company)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .chartLegend(.visible)
                    .frame(height: 320)
                case .bar:
                    let sorted = stats.sorted { lhs, rhs in
                        let l = selectedMetric == .employees ? lhs.employees : lhs.requests
                        let r = selectedMetric == .employees ? rhs.employees : rhs.requests
                        return l > r
                    }
                    Chart(sorted) { stat in
                        let value = selectedMetric == .employees ? stat.employees : stat.requests
                        BarMark(
                            x: .value("Company", stat.company),
                            y: .value(selectedMetric.rawValue, value)
                        )
                        .foregroundStyle(by: .value("Company", stat.company))
                    }
                    .chartYAxisLabel(selectedMetric.rawValue)
                    .frame(height: 320)
                }
            } else {
                Text("Charts require macOS 13 or newer.")
                    .foregroundColor(.secondary)
            }
        }
    }

    /// Shows the totals for quick reference.
    private var totals: some View {
        let stats = computeCompanyStats()
        let totalEmployees = stats.reduce(0) { $0 + $1.employees }
        let totalRequests = stats.reduce(0) { $0 + $1.requests }
        return HStack(spacing: 24) {
            Label("Total employees: \(totalEmployees)", systemImage: "person.3")
            Label("Total requests: \(totalRequests)", systemImage: "chart.bar")
        }
        .foregroundColor(.secondary)
    }

    /// Computes aggregated company statistics from the processed data.
    private func computeCompanyStats() -> [CompanyStat] {
        var companyToEmails: [String: Set<String>] = [:]
        var companyToRequests: [String: Int] = [:]

        for row in processedData {
            let company = companyName(for: row.email)
            companyToEmails[company, default: []].insert(row.email)
            companyToRequests[company, default: 0] += totalRequests(in: row)
        }

        let allCompanies = Set(companyToEmails.keys).union(companyToRequests.keys)
        return allCompanies.map { company in
            let employees = companyToEmails[company]?.count ?? 0
            let requests = companyToRequests[company] ?? 0
            return CompanyStat(id: company, company: company, employees: employees, requests: requests)
        }
    }

    /// Maps an email address to a short company name based on known domains.
    private func companyName(for email: String) -> String {
        let lower = email.lowercased()
        if lower.hasSuffix("@\(EmailDomain.tinder.rawValue)") { return "Tinder" }
        if lower.hasSuffix("@\(EmailDomain.hinge.rawValue)") { return "Hinge" }
        if lower.hasSuffix("@\(EmailDomain.okcupid.rawValue)") { return "OKCupid" }
        if lower.hasSuffix("@\(EmailDomain.match.rawValue)") { return "Match" }
        if lower.hasSuffix("@\(EmailDomain.theLeague.rawValue)") { return "The League" }
        if lower.hasSuffix("@\(EmailDomain.eureka.rawValue)") { return "Eureka" }
        if lower.hasSuffix("@\(EmailDomain.meetic.rawValue)") { return "Meetic" }
        return "Other"
    }

    /// Sums request-related numeric columns for a single merged row.
    private func totalRequests(in row: CSVRow) -> Int {
        let headers = row.headers
        let usageColumns = [
            "Edit Requests",
            "Ask Requests",
            "Agent Requests",
            "Cmd+K Usages",
            "Subscription Included Reqs",
            "API Key Reqs",
            "Usage Based Reqs",
            "Bugbot Usages"
        ]
        var total = 0
        for column in usageColumns {
            if let idx = headers.firstIndex(of: column), idx < row.values.count, let value = Int(row.values[idx]) {
                total += value
            }
        }
        return total
    }
}


