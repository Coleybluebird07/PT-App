//
//  PTTextField.swift
//  PT-App
//
//  Created by David Cole on 09/10/2025.
//


import SwiftUI

/// Reusable text input with a BRIGHT white placeholder.
/// We draw the placeholder ourselves so SecureField & TextField behave identically.
public struct PTTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let isSecure: Bool
    private let submit: SubmitLabel
    private let keyboard: UIKeyboardType

    public init(
        _ placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        submitLabel: SubmitLabel = .next,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.submit = submitLabel
        self.keyboard = keyboardType
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            // Custom placeholder (pure white, high opacity)
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white)          // <- strong white
                    .opacity(0.98)                    // <- nearly solid
                    .padding(.horizontal, 14)
            }

            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .textFieldStyle(.plain)                 // <- remove any default styling
            .keyboardType(keyboard)
            .foregroundColor(.white)                // <- typed text color (solid white)
            .tint(.green)                           // cursor & selection
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .submitLabel(submit)
        }
        // Increase contrast of the field container a touch
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.20))    // <- brighter backdrop for legibility
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.30), lineWidth: 1)
        )
    }
}
