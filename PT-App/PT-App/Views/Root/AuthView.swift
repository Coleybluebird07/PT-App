//
//  AuthView.swift
//  PT-App
//
//  Created by David Cole on 09/10/2025.
//


import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var role: UserRole = .client

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("PT-App")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    if isSignUp {
                        TextField("Display name (optional)", text: $displayName)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        Picker("Role", selection: $role) {
                            ForEach(UserRole.allCases) { Text($0.displayName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Button {
                    Task {
                        if isSignUp {
                            await session.signUp(email: email, password: password, displayName: displayName, role: role)
                        } else {
                            await session.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    HStack {
                        if session.isBusy { ProgressView() }
                        Text(isSignUp ? "Create account" : "Sign in")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.black)
                }
                .disabled(session.isBusy || email.isEmpty || password.isEmpty)

                Button(isSignUp ? "Have an account? Sign in" : "New here? Create an account") {
                    withAnimation { isSignUp.toggle() }
                }
                .foregroundStyle(.secondary)

                if let error = session.authError {
                    Text(error).foregroundStyle(.red).font(.footnote).multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(20)
            .background(LinearGradient(colors: [Color.black, Color(white: 0.08)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            .navigationTitle(isSignUp ? "Create Account" : "Sign In")
        }
    }
}

#Preview {
    AuthView().environmentObject(SessionStore())
        .preferredColorScheme(.dark)
}