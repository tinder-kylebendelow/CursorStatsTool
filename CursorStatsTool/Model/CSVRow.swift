import Foundation

struct CSVRow {
    let headers: [String]
    let values: [String]

    init(headers: [String] = [], values: [String] = []) {
        self.headers = headers
        self.values = values
    }

    var email: String {
        if let emailIndex = headers.firstIndex(of: "Email"),
           emailIndex < values.count {
            return values[emailIndex]
        }
        return ""
    }

    func matchesExtension(_ ext: String) -> Bool {
        let applyExtensionIndex = headers.firstIndex(of: "Most Used Apply Extension")
        let tabExtensionIndex = headers.firstIndex(of: "Most Used Tab Extension")
        let applyExtension = applyExtensionIndex.flatMap { index in
            index < values.count ? values[index] : nil
        } ?? ""
        let tabExtension = tabExtensionIndex.flatMap { index in
            index < values.count ? values[index] : nil
        } ?? ""
        if ext == "kotlin" {
            // Android: match both 'kotlin' and 'kt'
            let androidExts = ["kotlin", "kt"]
            return androidExts.contains(applyExtension.lowercased()) || androidExts.contains(tabExtension.lowercased())
        } else {
            return applyExtension.lowercased() == ext || tabExtension.lowercased() == ext
        }
    }

    var isSwiftExtension: Bool {
        let applyExtensionIndex = headers.firstIndex(of: "Most Used Apply Extension")
        let tabExtensionIndex = headers.firstIndex(of: "Most Used Tab Extension")

        let applyExtension = applyExtensionIndex.flatMap { index in
            index < values.count ? values[index] : nil
        } ?? ""

        let tabExtension = tabExtensionIndex.flatMap { index in
            index < values.count ? values[index] : nil
        } ?? ""

        return applyExtension.lowercased() == "swift" || tabExtension.lowercased() == "swift"
    }
}
