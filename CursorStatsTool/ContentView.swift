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

    @State private var dragOver = false
    @State private var selectedEmailDomain: EmailDomain = .all
    @State private var exportedFilePaths: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            titleView
            subtitleView

            if processedData.isEmpty {
                CSVDropArea(
                    dragOver: $dragOver,
                    onTap: selectFile,
                    onDrop: { providers in
                        handleDrop(providers: providers)
                        return true
                    }
                )

                HighLevelStatsView(
                    csvData: csvData
                )
                
                if !csvData.isEmpty {
                    processFileButton
                }
            } else {
                // Processed mode: show charts dashboard
                ProcessedDashboardView(processedData: processedData)
                exportFilesButton
            }
            
            TinderFilterToggle(
                selectedDomain: $selectedEmailDomain
            )
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .fileImporter(
            isPresented: .constant(false),
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: true
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
        .onChange(of: selectedEmailDomain) { _ in
            // Reprocess automatically so charts and export reflect current filter
            if !csvData.isEmpty && !isProcessing {
                processData()
            }
        }
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        
        if panel.runModal() == .OK {
            loadMultipleCSVs(from: panel.urls)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        var allCsvData: [CSVRow] = []
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.commaSeparatedText.identifier, options: nil) { item, error in
                defer { group.leave() }
                
                if let url = item as? URL {
                    do {
                        let content = try String(contentsOf: url)
                        let parser = CSVParser()
                        let data = parser.parseCSV(content)
                        DispatchQueue.main.sync {
                            allCsvData.append(contentsOf: data)
                        }
                    } catch {
                        print("Error loading CSV from \(url): \(error)")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.csvData = allCsvData
            self.processedData = []
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            loadMultipleCSVs(from: urls)
        case .failure(let error):
            print("File selection error: \(error)")
        }
    }
    
    private func loadCSV(from url: URL) {
        do {
            let content = try String(contentsOf: url)
            let parser = CSVParser()
            csvData = parser.parseCSV(content)
            processedData = []
        } catch {
            print("Error loading CSV: \(error)")
        }
    }
    
    private func loadMultipleCSVs(from urls: [URL]) {
        var allCsvData: [CSVRow] = []
        
        for url in urls {
            do {
                let content = try String(contentsOf: url)
                let parser = CSVParser()
                let data = parser.parseCSV(content)
                allCsvData.append(contentsOf: data)
            } catch {
                print("Error loading CSV from \(url): \(error)")
            }
        }
        
        csvData = allCsvData
        processedData = []
    }
    
    private func processData() {
        isProcessing = true

        DispatchQueue.global(qos: .userInitiated).async {
            let exporter = CSVExporter()
            // For preview, just show iOS (Swift) data in the UI
            let mergedData = exporter.processDataForPreview(
                csvData: csvData,
                extensionName: "swift",
                filterDomain: selectedEmailDomain
            )
            DispatchQueue.main.async {
                processedData = mergedData
                isProcessing = false
            }
        }
    }

    private func exportData() {
        let exportPanel = CSVExportPanel()
        if let filePaths = exportPanel.exportCSVData(
            csvData,
            filterDomain: selectedEmailDomain
        ) {
            exportedFilePaths = filePaths
            showingExportSheet = true
        }
    }
}

// MARK: Child Views
private extension ContentView {

    var exportFilesButton: some View {
        Button(action: exportData) {
            Text("Export Processed CSV")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    var processFileButton: some View {
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

    var subtitleView: some View {
        Text("Drag and drop CSV file(s) to process")
            .font(.headline)
            .foregroundColor(.secondary)
    }

    var titleView: some View {
        Text("Cursor Stats CSV Processor")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}
