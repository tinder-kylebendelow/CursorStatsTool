//
//  CSVExporter.swift
//  CursorStatsTool
//
//  Created by Kyle Bendelow on 6/30/25.
//

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
            mergeRows(rows)
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
    
    private func mergeRows(_ rows: [CSVRow]) -> CSVRow {
        guard let firstRow = rows.first else {
            return CSVRow(headers: [], values: [])
        }
        
        if rows.count == 1 {
            return firstRow
        }
        
        var mergedValues = firstRow.values
        
        for i in 0..<firstRow.headers.count {
            let header = firstRow.headers[i]
            
            if isNumericColumn(header) {
                let sum = rows.compactMap { row in
                    guard i < row.values.count else { return 0 }
                    return Int(row.values[i])
                }.reduce(0, +)
                mergedValues[i] = String(sum)
            } else {
                // For non-numeric columns, keep the first non-empty value
                for row in rows {
                    if i < row.values.count && !row.values[i].isEmpty {
                        mergedValues[i] = row.values[i]
                        break
                    }
                }
            }
        }
        
        return CSVRow(headers: firstRow.headers, values: mergedValues)
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

