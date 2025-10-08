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
        VStack(spacing: 18) {
            Image(systemName: "calendar.badge.plus")
                .imageScale(.large)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(PT.accent)

            Text("You have no plan")
                .font(.title3.weight(.semibold))

            Text("Create a weekly plan to see today’s workout here.")
                .font(.callout)
                .foregroundStyle(PT.textSub)
                .multilineTextAlignment(.center)

            Button(action: { Haptics.tap(); onAdd() }) {
                Text("Add your first plan")
            }
            .buttonStyle(PillButtonStyle())
            .padding(.top, 6)
        }
        .ptCard()
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [PT.bgTop, PT.bgBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        NoPlanView(onAdd: {})
            .padding()
    }
    .preferredColorScheme(.dark)
}
