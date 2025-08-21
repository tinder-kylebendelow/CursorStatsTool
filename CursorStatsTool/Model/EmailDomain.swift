import Foundation

/// Supported email domain filters for analysis and export.
///
/// Powers the UI picker and downstream filtering logic.
/// - ``tinder``: Only emails ending with `@gotinder.com`.
/// - ``hinge``: Only emails ending with `@hinge.co`.
/// - ``okcupid``: Only emails ending with `@okcupid.com`.
/// - ``match``: Only emails ending with `@match.com`.
/// - ``theLeague``: Only emails ending with `@theleagueapp.co`.
/// - ``eureka``: Only emails ending with `@eure.jp`.
/// - ``meetic``: Only emails ending with `@meetic-corp.com`.
/// - ``all``: Includes all supported domains.
enum EmailDomain: String, CaseIterable, Identifiable {
    /// Only `@gotinder.com` email addresses.
    case tinder = "gotinder.com"
    /// Only `@hinge.co` email addresses.
    case hinge = "hinge.co"
    /// Only `@okcupid.com` email addresses.
    case okcupid = "okcupid.com"
    /// Only `@match.com` email addresses.
    case match = "match.com"
    /// Only `@theleagueapp.co` email addresses.
    case theLeague = "theleagueapp.co"
    /// Only `@eure.jp` email addresses (Eureka / Pairs).
    case eureka = "eure.jp"
    /// Only `@meetic-corp.com` email addresses (Meetic).
    case meetic = "meetic-corp.com"
    /// Includes all supported domains.
    case all = "all"

    /// Stable identifier for SwiftUI pickers.
    var id: String { rawValue }

    /// Human-readable label for use in the domain picker UI.
    var displayName: String {
        switch self {
        case .tinder:
            return "Tinder (@gotinder.com)"
        case .hinge:
            return "Hinge (@hinge.co)"
        case .okcupid:
            return "OKCupid (@okcupid.com)"
        case .match:
            return "Match (@match.com)"
        case .theLeague:
            return "The League (@theleagueapp.co)"
        case .eureka:
            return "Eureka (@eure.jp)"
        case .meetic:
            return "Meetic (@meetic-corp.com)"
        case .all:
            return "All (Tinder, Hinge, OKCupid, Match, The League, Eureka, Meetic)"
        }
    }

    /// Convenience `@domain` suffix for single-domain cases.
    /// For ``both``, this value is not used.
    var suffix: String { "@" + rawValue }

    /// All email suffixes permitted for this selection.
    var allowedSuffixes: [String] {
        switch self {
        case .tinder:
            return ["@gotinder.com"]
        case .hinge:
            return ["@hinge.co"]
        case .okcupid:
            return ["@okcupid.com"]
        case .match:
            return ["@match.com"]
        case .theLeague:
            return ["@theleagueapp.co"]
        case .eureka:
            return ["@eure.jp"]
        case .meetic:
            return ["@meetic-corp.com"]
        case .all:
            // Include all supported domains except the synthetic `.all` case.
            return EmailDomain.allCases
                .filter { $0 != .all }
                .flatMap { $0.allowedSuffixes }
        }
    }
}


