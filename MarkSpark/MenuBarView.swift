//
//  MenuBarView.swift
//  MarkSpark
//
//  Created by Stephen Parker on 8/9/25.
//

import SwiftUI

struct MenuBarView: View {
    @State private var statusMessage: String = ""
    @State private var statusIsError: Bool = false
    @State private var richFlash: Bool = false
    @State private var plainFlash: Bool = false
    @State private var statusToken: UUID = UUID()
    @State private var statusShownAt: Date? = nil

    var body: some View {
        VStack(spacing: 8) {
            // Rich Text Conversion
            Button(action: {
                let result = ClipboardService.convertMarkdownToRichText()
                handle(result)
                flash($richFlash)
            }) {
                Text("Convert Markdown to Rich Text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(statusIsError ? Color.red.opacity(0.4) : Color.green.opacity(0.4), lineWidth: richFlash ? 4 : 0)
                    .animation(.easeOut(duration: 0.25), value: richFlash)
            )

            // Plain Text Conversion
            Button(action: {
                let result = ClipboardService.convertMarkdownToPlainText()
                handle(result)
                flash($plainFlash)
            }) {
                Text("Convert Markdown to Plain Text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(statusIsError ? Color.red.opacity(0.4) : Color.green.opacity(0.4), lineWidth: plainFlash ? 4 : 0)
                    .animation(.easeOut(duration: 0.25), value: plainFlash)
            )

            Divider().padding(.vertical, 4)

            HStack {
                // Bottom-left status indicator
                if !statusMessage.isEmpty {
                    Label(statusMessage, systemImage: statusIsError ? "xmark.octagon.fill" : "checkmark.circle.fill")
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(.white)
                        .background((statusIsError ? Color.red : Color.green).opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    Spacer(minLength: 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .underline()
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
        }
        .padding(12)
        .onAppear {
            if let shownAt = statusShownAt, Date().timeIntervalSince(shownAt) > 5 {
                statusMessage = ""
            }
        }
    }
}

private extension MenuBarView {
    func handle(_ result: ClipboardService.ClipboardResult) {
        switch result {
        case .success(let message):
            statusMessage = message
            statusIsError = false
        case .failure(let message):
            statusMessage = message
            statusIsError = true
        }
        // Show with a small animation and auto-hide after 5 seconds
        withAnimation(.easeInOut(duration: 0.2)) {}
        let token = UUID()
        statusToken = token
        statusShownAt = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if statusToken == token {
                withAnimation(.easeInOut(duration: 0.2)) {
                    statusMessage = ""
                }
            }
        }
    }

    func flash(_ flag: Binding<Bool>) {
        flag.wrappedValue = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            flag.wrappedValue = false
        }
    }
}
