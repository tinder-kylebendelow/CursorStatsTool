//
//  TinderFilterToggle.swift
//  CursorStatsTool
//
//  Created by Kyle Bendelow on 6/30/25.
//

import SwiftUI

struct TinderFilterToggle: View {
    @Binding var isTinderFilterEnabled: Bool

    var body: some View {
        Toggle("Only include @gotinder.com emails", isOn: $isTinderFilterEnabled)
            .toggleStyle(CheckboxToggleStyle())
            .padding(.bottom, 8)
    }
}
