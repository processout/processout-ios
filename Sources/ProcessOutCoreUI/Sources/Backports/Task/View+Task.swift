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
    @available(iOS 14, *)
    @ViewBuilder
    public func task<T>(
        id value: T, priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void
    ) -> some View where T: Equatable {
        if #available(iOS 15, *) {
            wrapped.task(id: value, priority: priority, action)
        } else {
            wrapped.modifier(TaskModifier(id: value, priority: priority, action: action))
        }
    }

    @ViewBuilder
    @available(iOS, deprecated: 15)
    @available(iOS 14, *)
    public func task(
        priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void
    ) -> some View {
        task(id: 0, priority: priority, action)
    }
}

@available(iOS 14, *)
private struct TaskModifier<Id: Equatable>: ViewModifier {

    let id: Id
    let priority: TaskPriority
    let action: @Sendable () async -> Void

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content
            .onAppear {
                task?.cancel()
                task = Task(priority: priority, operation: action)
            }
            .backport.onChange(of: id, perform: {
                task?.cancel()
                task = Task(priority: priority, operation: action)
            })
            .onDisappear {
                task?.cancel()
                task = nil
            }
    }

    // MARK: - Private Properties

    @State
    private var task: Task<Void, Never>?
}
