//
//  AuthView.swift
//  PT-App
//
//  Created by David Cole on 09/10/2025.
//

import SwiftUI

enum AuthMode: String, CaseIterable {
    case signIn = "Sign in"
    case signUp = "Sign up"
}

struct AuthView: View {
    @EnvironmentObject private var session: SessionStore

    // UI state
    @State private var mode: AuthMode = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var role: UserRole = .client

    @FocusState private var focused: Field?
    @State private var showError = false

    enum Field { case email, password, name }

    // simple validation
    private var canSubmitSignIn: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }
    private var canSubmitSignUp: Bool {
        canSubmitSignIn // same check is fine; display name optional
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(white: 0.08)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(mode == .signIn ? "Sign In" : "Create Account")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Mode selector
                    HStack(spacing: 12) {
                        ForEach(AuthMode.allCases, id: \.self) { m in
                            Button {
                                mode = m
                                session.authError = nil
                            } label: {
                                Text(m.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(mode == m ? .white : .clear, in: Capsule())
                                    .foregroundStyle(mode == m ? .black : .white.opacity(0.7))
                                    .overlay(
                                        Capsule().stroke(.white.opacity(0.16), lineWidth: 1)
                                    )
                            }
                        }
                    }

                    groupFields

                    primaryButton
                        .disabled(session.isBusy || (mode == .signIn ? !canSubmitSignIn : !canSubmitSignUp))
                        .opacity(session.isBusy ? 0.85 : 1)

                    if mode == .signIn {
                        footerLink
                    } else {
                        footerBackToSignIn
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
                        .padding(.horizontal, 20)
                )
            }
        }
        .onChange(of: session.authError) { _, new in showError = (new != nil) }
        .alert("Authentication error",
               isPresented: $showError,
               actions: { Button("OK", role: .cancel) {} },
               message: { Text(session.authError ?? "Unknown error") })
        .onAppear {
            // Focus email initially
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                focused = .email
            }
        }
    }

    // MARK: - Subviews

    private var groupFields: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                Text("Email")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    .overlay( RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1) )
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Password")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                    .overlay( RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1) )
                    .focused($focused, equals: .password)
                    .submitLabel(mode == .signIn ? .go : .next)
                    .onSubmit {
                        if mode == .signIn {
                            Task { await submit() }
                        } else {
                            focused = .name
                        }
                    }
            }

            if mode == .signUp {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Display name (optional)")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))

                    TextField("Your name", text: $displayName)
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(.white)
                        .tint(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        .overlay( RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1) )
                        .focused($focused, equals: .name)
                        .submitLabel(.done)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Role")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))

                    HStack(spacing: 10) {
                        rolePill(.client, label: "Client")
                        rolePill(.pt,     label: "PT")
                        rolePill(.both,   label: "Both")
                    }
                }
            }
        }
    }

    private func rolePill(_ value: UserRole, label: String) -> some View {
        Button {
            role = value
        } label: {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(role == value ? .white : .clear, in: Capsule())
                .foregroundStyle(role == value ? .black : .white.opacity(0.7))
                .overlay(
                    Capsule().stroke(.white.opacity(0.16), lineWidth: 1)
                )
        }
    }

    private var primaryButton: some View {
        Button {
            Task { await submit() }
        } label: {
            HStack {
                if session.isBusy { ProgressView().progressViewStyle(.circular) }
                Text(mode == .signIn ? "Sign in" : "Create account")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.black)
        }
    }

    private var footerLink: some View {
        HStack(spacing: 6) {
            Text("New here?")
                .foregroundStyle(.white.opacity(0.7))
            Button("Create an account") { withAnimation { mode = .signUp } }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }

    private var footerBackToSignIn: some View {
        HStack(spacing: 6) {
            Text("Have an account?")
                .foregroundStyle(.white.opacity(0.7))
            Button("Sign in") { withAnimation { mode = .signIn } }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func submit() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty, password.count >= 6 else { return }

        switch mode {
        case .signIn:
            await session.signIn(email: trimmedEmail, password: password)
        case .signUp:
            await session.signUp(email: trimmedEmail,
                                 password: password,
                                 displayName: displayName,
                                 role: role)
        }
    }
}
