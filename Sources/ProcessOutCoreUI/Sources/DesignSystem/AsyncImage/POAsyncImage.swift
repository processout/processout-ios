//
//  POAsyncImage.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

@_spi(PO)
@MainActor
@available(iOS 14, *)
public struct POAsyncImage<Content: View>: View {

    /// - Parameters:
    ///   - content: A closure that takes the load phase as an input,
    ///   and returns the view to display for the specified phase.
    public init(
        image: @Sendable @escaping () async throws -> Image?,
        transaction: Transaction,
        @ViewBuilder content: @escaping (POAsyncImagePhase) -> Content
    ) {
        self.image = image
        self.transaction = transaction
        self.content = content
        phase = .empty
    }

    public var body: some View {
        content(phase).backport.task(priority: .userInitiated, resolveImage)
    }

    // MARK: - Private Properties

    private let image: @Sendable () async throws -> Image?
    private let transaction: Transaction
    private let content: (POAsyncImagePhase) -> Content

    @State
    private var phase: POAsyncImagePhase

    @Environment(\.colorScheme)
    private var colorScheme

    // MARK: - Private Methods

    /// Implementation resolves image and updates phase.
    @Sendable
    private func resolveImage() async {
        let newPhase: POAsyncImagePhase
        do {
            guard let image = try await image() else {
                return
            }
            newPhase = .success(image)
        } catch {
            newPhase = .failure(error)
        }
        withTransaction(transaction) { phase = newPhase }
    }
}
