//
//  TinderFilterToggle.swift
//  CursorStatsTool
//
//  Created by Kyle Bendelow on 6/30/25.
//

import SwiftUI

struct TinderFilterToggle: View {
    @Binding var selectedDomain: EmailDomain

    var body: some View {
        HStack {
            Text("Email domain:")
            Picker("Email domain", selection: $selectedDomain) {
                ForEach(EmailDomain.allCases) { domain in
                    Text(domain.displayName).tag(domain)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.bottom, 8)
    }
}
