import Foundation
import AppKit

class FileSaver {
    init() {}
    
    func exportCSVData(_ csvData: [CSVRow], filterTinderEmails: Bool) -> [String]? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        
        if panel.runModal() == .OK, let directoryURL = panel.url {
            let iosURL = directoryURL.appendingPathComponent("iOS_cursor_stats.csv")
            let androidURL = directoryURL.appendingPathComponent("android_cursor_stats.csv")
            let exporter = CSVExporter()
            
            exporter.export(csvData: csvData, extensionName: "swift", filterTinderEmails: filterTinderEmails, url: iosURL)
            exporter.export(csvData: csvData, extensionName: "kotlin", filterTinderEmails: filterTinderEmails, url: androidURL)
            
            return [iosURL.path, androidURL.path]
        }
        
        return nil
    }
}


