import SwiftUI
import UniformTypeIdentifiers

struct CSVDropArea: View {
    @Binding var dragOver: Bool
    let onTap: () -> Void
    let onDrop: ([NSItemProvider]) -> Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(dragOver ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .stroke(dragOver ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(height: 200)
            
            VStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 50))
                    .foregroundColor(dragOver ? .blue : .gray)
                
                Text("Drop CSV file(s) here")
                    .font(.title2)
                    .foregroundColor(dragOver ? .blue : .gray)
                
                Text("or click to select")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture {
            onTap()
        }
        .onDrop(of: [UTType.commaSeparatedText], isTargeted: $dragOver) { providers in
            onDrop(providers)
        }
    }
}

