import SwiftUI

struct HighLevelStatsView: View {
    
    let csvData: [CSVRow]
    
    private var tinderUsersCount: Int {
        let emails = csvData.filter { row in
            let email = row.email.lowercased()
            return EmailDomain.tinder.allowedSuffixes.contains(where: { email.hasSuffix($0) })
        }.map { $0.email }
        return Set(emails).count
    }
    
    private var hingeUsersCount: Int {
        let emails = csvData.filter { row in
            let email = row.email.lowercased()
            return EmailDomain.hinge.allowedSuffixes.contains(where: { email.hasSuffix($0) })
        }.map { $0.email }
        return Set(emails).count
    }
    
    var body: some View {
        if !csvData.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Loaded CSV:")
                    .font(.headline)
                
                Text("• Total rows: \(csvData.count)")
                Text("• Unique users: \(Set(csvData.map { $0.email }).count)")
                Text("• Swift extension rows: \(csvData.filter { $0.isSwiftExtension }.count)")
                Text("• Kotlin extension rows: \(csvData.filter { $0.isKotlinExtension }.count)")
                Text("• Tinder users: \(tinderUsersCount)")
                Text("• Hinge users: \(hingeUsersCount)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}


