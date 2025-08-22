import Foundation
import AppKit

/// Presents a save destination panel and delegates CSV writing to `CSVExporter`.
/// Returns the written file path on success.
class CSVExportPanel {
    init() {}
    
    /// Prompts for a destination folder and exports a single CSV file using `CSVExporter`.
    /// - Parameters:
    ///   - csvData: The raw `CSVRow` records to export.
    ///   - filterDomain: Optional `EmailDomain` filter applied before exporting.
    /// - Returns: A single-element array with the absolute file path, or `nil` if cancelled.
    func exportCSVData(_ csvData: [CSVRow], filterDomain: EmailDomain?) -> [String]? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        
        if panel.runModal() == .OK, let directoryURL = panel.url {
            let outputURL = directoryURL.appendingPathComponent("cursor_stats.csv")
            let exporter = CSVExporter()
            exporter.export(
                csvData: csvData,
                extensionName: "swift",
                filterDomain: filterDomain,
                url: outputURL
            )
            return [outputURL.path]
        }
        
        return nil
    }
}


