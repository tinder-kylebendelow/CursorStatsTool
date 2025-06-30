import SwiftUI

struct HighLevelStatsView: View {
    
    let csvData: [CSVRow]
    
    var body: some View {
        if !csvData.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Loaded CSV:")
                    .font(.headline)
                
                Text("• Total rows: \(csvData.count)")
                Text("• Unique users: \(Set(csvData.map { $0.email }).count)")
                Text("• Swift extension rows: \(csvData.filter { $0.isSwiftExtension }.count)")
                Text("• Kotlin extension rows: \(csvData.filter { $0.isKotlinExtension }.count)")
                Text("• Tinder users: \(Set(csvData.filter { $0.email.lowercased().contains("@gotinder.com") }.map { $0.email }).count)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}


