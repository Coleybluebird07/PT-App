//
//  WhitePlaceholderTextFieldStyle.swift
//  PT-App
//
//  Created by David Cole on 09/10/2025.
//


import SwiftUI

/// Consistent dark-mode text field styling (background, stroke, padding).
/// Placeholder color is set via the `prompt:` parameter on TextField/SecureField.
public struct WhitePlaceholderTextFieldStyle: TextFieldStyle {
    public init() {}

    public func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .foregroundColor(.white)      // typed text
            .tint(.white)                 // cursor & accent
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .font(.body)
            .colorScheme(.dark)           // ensure white system elements
    }
}
