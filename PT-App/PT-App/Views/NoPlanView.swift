//
//  NoPlanView.swift
//  PT-App
//
//  Created by David Cole on 06/10/2025.
//


import SwiftUI

struct NoPlanView: View {
    let onAdd: () -> Void

    var body: some View {
        // Centered “card”
        VStack(spacing: 16) {
            Text("You have no plan")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Button(action: onAdd) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.plus")
                        .imageScale(.medium)
                    Text("Add your first plan")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(PrimaryPillButtonStyle())
            .accessibilityLabel("Add your first plan")
        }
        .padding(22)
        .frame(maxWidth: 360) // keeps it tidy on larger devices
        .background(
            // Soft, modern card
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(radius: 18, y: 6)
        )
        .padding(.horizontal, 24)
        // Prefer being vertically centered on first run
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
    }
}

/// A nice green, tappable pill with press feedback
struct PrimaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.95),
                                Color.green.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundStyle(Color.black.opacity(0.9))
            .shadow(radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.black, Color(white: 0.08)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        NoPlanView(onAdd: {})
    }
    .preferredColorScheme(.dark)
}
