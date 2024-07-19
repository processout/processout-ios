//
//  POAsyncImage.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
public struct POAsyncImage<Content: View>: View {

    /// - Parameters:
    ///   - content: A closure that takes the load phase as an input,
    ///   and returns the view to display for the specified phase.
    public init(
        id: AnyHashable,
        image: @Sendable @escaping () async throws -> Image?,
        transaction: Transaction,
        @ViewBuilder content: @escaping (POAsyncImagePhase) -> Content
    ) {
        self.id = id
        self.image = image
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        ZStack {
            content(phase)
        }
        .backport.task(id: id, priority: .userInitiated, resolveImage)
    }

    // MARK: - Private Properties

    private let id: AnyHashable
    private let image: @Sendable () async throws -> Image?
    private let transaction: Transaction
    private let content: (POAsyncImagePhase) -> Content

    @State
    private var phase: POAsyncImagePhase = .empty

    @Environment(\.colorScheme)
    private var colorScheme

    // MARK: - Private Methods

    /// Implementation resolves image and updates phase.
    @Sendable
    @MainActor
    private func resolveImage() async {
        guard !Task.isCancelled else {
            return
        }
        withTransaction(transaction) {
            phase = .empty
        }
        let newPhase: POAsyncImagePhase
        do {
            if let image = try await image() {
                newPhase = .success(image)
            } else {
                newPhase = .empty
            }
        } catch {
            newPhase = .failure(error)
        }
        guard !Task.isCancelled else {
            return
        }
        withTransaction(transaction) { phase = newPhase }
    }
}
