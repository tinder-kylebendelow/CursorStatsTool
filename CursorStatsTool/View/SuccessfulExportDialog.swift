//
//  SuccessfulExportDialog.swift
//  CursorStatsTool
//
//  Created by Kyle Bendelow on 6/30/25.
//

import SwiftUI

struct SuccessfulExportDialog: View {
    let exportedFilePaths: [String]
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Export Successful!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your processed CSV files have been saved:")
                .font(.body)
                .foregroundColor(.secondary)
            
            ForEach(exportedFilePaths, id: \.self) { path in
                Text(path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("OK") {
                onDismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(40)
        .frame(width: 500, height: 350)
    }
}
