//
//  ContentView.swift
//  CursorStatsTool
//
//  Created by Kyle Bendelow on 6/30/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var csvData: [CSVRow] = []
    @State private var processedData: [CSVRow] = []
    @State private var isProcessing = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var dragOver = false
    @State private var filterTinderEmails = true
    @State private var exportedFilePaths: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Cursor Stats CSV Processor")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Drag and drop a CSV file to process")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Drag and drop area
            CSVDropArea(
                dragOver: $dragOver,
                onTap: selectFile,
                onDrop: { providers in
                    handleDrop(providers: providers)
                    return true
                }
            )
            
            // File info
            HighLevelStatsView(
                csvData: csvData
            )
            
            // Process button
            if !csvData.isEmpty {
                Button(action: processData) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isProcessing ? "Processing..." : "Process Data")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isProcessing)
            }
            
            // Export button
            if !processedData.isEmpty {
                Button(action: exportData) {
                    Text("Export Processed CSV")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            TinderFilterToggle(
                isTinderFilterEnabled: $filterTinderEmails
            )
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .fileImporter(
            isPresented: .constant(false),
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .sheet(isPresented: $showingExportSheet) {
            SuccessfulExportDialog(
                exportedFilePaths: exportedFilePaths,
                onDismiss: {
                    showingExportSheet = false
                }
            )
        }
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                loadCSV(from: url)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: UTType.commaSeparatedText.identifier, options: nil) { item, error in
            DispatchQueue.main.async {
                if let url = item as? URL {
                    loadCSV(from: url)
                }
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                loadCSV(from: url)
            }
        case .failure(let error):
            print("File selection error: \(error)")
        }
    }
    
    private func loadCSV(from url: URL) {
        do {
            let content = try String(contentsOf: url)
            let parser = CSVParser()
            csvData = parser.parseCSV(content)
        } catch {
            print("Error loading CSV: \(error)")
        }
    }
    
    private func processData() {
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let exporter = CSVExporter()
            // For preview, just show iOS (Swift) data in the UI
            let mergedData = exporter.processDataForPreview(
                csvData: csvData,
                extensionName: "swift",
                filterTinderEmails: filterTinderEmails
            )
            DispatchQueue.main.async {
                processedData = mergedData
                isProcessing = false
            }
        }
    }
    

    
    private func exportData() {
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
            exportURL = iosURL // for backward compatibility, not used in new sheet
            exportedFilePaths = [iosURL.path, androidURL.path]
            showingExportSheet = true
        }
    }
}
