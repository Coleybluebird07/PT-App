//
//  UIStyles.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//

import SwiftUI
import UIKit

// MARK: - Palette
enum PT {
    static let bgTop    = Color.black
    static let bgBottom = Color(white: 0.08)
    static let cardBg   = Color.white.opacity(0.05)
    static let cardStroke = Color.white.opacity(0.08)
    static let textSub  = Color.white.opacity(0.7)
    static let accent   = Color.green
    static let danger   = Color.red
}

// MARK: - Card background
struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PT.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(PT.cardStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 16, y: 6)
            )
    }
}
extension View { func ptCard() -> some View { modifier(CardBackground()) } }

// MARK: - Buttons
struct PillButtonStyle: ButtonStyle {
    var tint: Color = PT.accent
    var fg: Color = .black
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.85 : 1))
            )
            .foregroundStyle(fg.opacity(0.95))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct SubtleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(PT.cardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(PT.cardStroke, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// MARK: - Haptics
enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}
