import Foundation

class CSVExporter {
    
    func export(
        csvData: [CSVRow],
        extensionName: String,
        filterTinderEmails: Bool,
        url: URL
    ) {
        // Filter and merge for the given extension
        var filteredRows = csvData.filter { $0.matchesExtension(extensionName) }
        if filterTinderEmails {
            filteredRows = filteredRows.filter { $0.email.lowercased().hasSuffix("@gotinder.com") }
        }
        let groupedData = Dictionary(grouping: filteredRows) { $0.email }
        let mergedData = groupedData.map { email, rows in
            mergeRows(rows, email: email)
        }
        
        guard !mergedData.isEmpty else { return }
        
        var csvContent = ""
        
        // Write headers (excluding unwanted columns)
        let filteredHeaders = mergedData[0].headers.filter { header in
            header != "Is Active" &&
            header != "Client Version" &&
            header != "Date" &&
            header != "Most Used Apply Extension" &&
            header != "Most Used Tab Extension" &&
            header != "API Key Reqs"
        }
        csvContent += filteredHeaders.joined(separator: ",") + "\n"
        
        // Write data rows
        for row in mergedData {
            let filteredValues = row.values.enumerated().compactMap { index, value in
                let header = row.headers[index]
                return (
                    header != "Is Active" &&
                    header != "Client Version" &&
                    header != "Date" &&
                    header != "Most Used Apply Extension" &&
                    header != "Most Used Tab Extension" &&
                    header != "API Key Reqs"
                ) ? value : nil
            }
            csvContent += filteredValues.joined(separator: ",") + "\n"
        }
        
        do {
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing CSV: \(error)")
        }
    }
    
    func processDataForPreview(
        csvData: [CSVRow],
        extensionName: String,
        filterTinderEmails: Bool
    ) -> [CSVRow] {
        var filteredRows = csvData.filter { $0.matchesExtension(extensionName) }
        if filterTinderEmails {
            filteredRows = filteredRows.filter { $0.email.lowercased().hasSuffix("@gotinder.com") }
        }
        let groupedData = Dictionary(grouping: filteredRows) { $0.email }
        let mergedData = groupedData.map { email, rows in
            mergeRows(rows, email: email)
        }
        return mergedData
    }
    
    private func mergeRows(_ rows: [CSVRow], email: String) -> CSVRow {
        guard let firstRow = rows.first else { return CSVRow() }
        
        var mergedValues = firstRow.values
        let headers = firstRow.headers
        
        // Sum numeric columns for all rows with the same email
        for i in 0..<headers.count {
            if isNumericColumn(headers[i]) {
                let sum = rows.compactMap { row in
                    Int(row.values[i])
                }.reduce(0, +)
                mergedValues[i] = String(sum)
            } else if headers[i] == "Email" {
                mergedValues[i] = email
            } else if headers[i] == "User ID" {
                mergedValues[i] = firstRow.values[i] // Keep first user ID
            } else if headers[i] == "Date" {
                mergedValues[i] = "Merged" // Indicate this is merged data
            } else if headers[i] == "Most Used Model" {
                // Calculate the most used model based on total usage across all days
                mergedValues[i] = calculateMostUsedModel(for: rows, headers: headers)
            } else {
                // For non-numeric columns, keep the first non-empty value
                let nonEmptyValues = rows.compactMap { row in
                    let value = row.values[i]
                    return value.isEmpty ? nil : value
                }
                mergedValues[i] = nonEmptyValues.first ?? ""
            }
        }
        
        return CSVRow(headers: headers, values: mergedValues)
    }
    
    private func calculateMostUsedModel(for rows: [CSVRow], headers: [String]) -> String {
        var modelUsage: [String: Int] = [:]
        
        // Find indices for relevant columns
        guard let modelIndex = headers.firstIndex(of: "Most Used Model") else {
            return ""
        }
        
        // Define usage columns that indicate model activity
        let usageColumns = [
            "Edit Requests",
            "Ask Requests", 
            "Agent Requests",
            "Cmd+K Usages",
            "Subscription Included Reqs",
            "API Key Reqs",
            "Usage Based Reqs"
        ]
        
        // Calculate total usage for each model
        for row in rows {
            guard modelIndex < row.values.count else { continue }
            
            let model = row.values[modelIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            if model.isEmpty { continue }
            
            // Calculate total usage for this row
            var totalUsage = 0
            for usageColumn in usageColumns {
                if let columnIndex = headers.firstIndex(of: usageColumn),
                   columnIndex < row.values.count,
                   let usage = Int(row.values[columnIndex]) {
                    totalUsage += usage
                }
            }
            
            // Add to model usage count
            modelUsage[model, default: 0] += totalUsage
        }
        
        // Find the model with the highest usage
        let mostUsedModel = modelUsage.max { $0.value < $1.value }?.key ?? ""
        
        // If no usage found, fall back to the first non-empty model
        if mostUsedModel.isEmpty {
            for row in rows {
                guard modelIndex < row.values.count else { continue }
                let model = row.values[modelIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                if !model.isEmpty {
                    return model
                }
            }
        }
        
        return mostUsedModel
    }
    
    private func isNumericColumn(_ header: String) -> Bool {
        let numericColumns = [
            "Chat Suggested Lines Added",
            "Chat Suggested Lines Deleted",
            "Chat Accepted Lines Added",
            "Chat Accepted Lines Deleted",
            "Chat Total Applies",
            "Chat Total Accepts",
            "Chat Total Rejects",
            "Chat Tabs Shown",
            "Tabs Accepted",
            "Edit Requests",
            "Ask Requests",
            "Agent Requests",
            "Cmd+K Usages",
            "Subscription Included Reqs",
            "API Key Reqs",
            "Usage Based Reqs",
            "Bugbot Usages"
        ]
        return numericColumns.contains(header)
    }
}

