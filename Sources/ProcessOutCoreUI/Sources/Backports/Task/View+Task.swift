//
//  View+Task.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import Combine
import SwiftUI

extension POBackport where Wrapped: View {

    @available(iOS, deprecated: 15)
    @ViewBuilder
    public func task<T>(
        id value: T = 0,
        priority: TaskPriority = .userInitiated,
        @_inheritActorContext _ action: @escaping @Sendable () async -> Void
    ) -> some View where T: Equatable {
        if #available(iOS 15, *) {
            wrapped.task(id: value, priority: priority, action)
        } else {
            wrapped.modifier(TaskModifier(id: value, priority: priority, action: action))
        }
    }
}

@MainActor
private struct TaskModifier<Id: Equatable>: ViewModifier {

    let id: Id, priority: TaskPriority, action: @Sendable () async -> Void

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content
            .onAppear {
                task?.cancel()
                task = Task(priority: priority, operation: action)
            }
            .backport.onChange(of: id) {
                task?.cancel()
                task = Task(priority: priority, operation: action)
            }
            .onDisappear {
                task?.cancel()
                task = nil
            }
    }

    // MARK: - Private Properties

    @State
    private var task: Task<Void, Never>?
}
