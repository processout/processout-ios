//
//  View+F.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.12.2024.
//

import SwiftUI

extension View {

    /// Automatically adjusts presentation detents based on content height if possible.
    @ViewBuilder
    @_spi(PO)
    public func fittedPresentationDetent() -> some View {
        if #available(iOS 16, *) {
            modifier(ContentModifier())
        } else {
            self
        }
    }
}

@available(iOS 16, *)
private struct ContentModifier: ViewModifier {

    init() {
        self.selectedDetent = Constants.defaultDetent
        self.detents = [Constants.defaultDetent]
        presentationSizing = .init()
    }

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        FittedPresentationLayout {
            Color.clear
                .onSizeChange { newValue in
                    presentationSizing.idealContentHeight = newValue.height
                }
            _UnaryViewAdaptor(content)
        }
        .backport.geometryGroup()
        .onWindowChange { window in
            // If the detent height exceeds the container window's height, it can cause UI glitches.
            // Since SwiftUI does not provide a way to constrain a fixed-height detent to a maximum value,
            // this workaround retrieves the window associated with the view and uses its height as the limit.
            presentationSizing.maxDetentHeight = window?.bounds.size.height
        }
        .backport.onChange(of: presentationSizing) {
            updateDetents()
        }
        .presentationDetents(detents, selection: $selectedDetent)
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Private Nested Types

    @MainActor
    private final class Storage: ObservableObject {

        /// Currently scheduled task that removes obsolete detents.
        var obsoleteDetentsRemovalTask: Task<Void, Error>?
    }

    @MainActor
    private struct PresentationSizing: Equatable {

        /// The maximum height for a presentation detent.
        var maxDetentHeight: CGFloat?

        /// Ideal content height.
        var idealContentHeight: CGFloat?
    }

    @MainActor
    private enum Constants {
        static let defaultDetent = PresentationDetent.height(1)
    }

    // MARK: - Private Properties

    @State
    private var presentationSizing: PresentationSizing

    @State
    private var detents: Set<PresentationDetent>

    @State
    private var selectedDetent: PresentationDetent

    @ObservedObject
    private var storage = Storage()

    // MARK: - Private Methods

    private func updateDetents() {
        guard let maxDetentHeight = presentationSizing.maxDetentHeight,
              let idealContentHeight = presentationSizing.idealContentHeight else {
            return
        }
        var newDetent = PresentationDetent.height(idealContentHeight)
        if idealContentHeight >= maxDetentHeight {
            newDetent = .large
        }
        // Directly changing the detent to new value does not animate the transition.
        // Instead new detent is added to existing values and selection is changed.
        detents.insert(newDetent)
        selectedDetent = newDetent
        removeObsoleteDetents(keeping: newDetent)
    }

    private func removeObsoleteDetents(keeping newDetent: PresentationDetent) {
        // Workaround to delay the removal of obsolete detents, ensuring
        // the detent change animation goes smoothly.
        let task = Task { @MainActor in
            try await Task.sleep(for: .milliseconds(300))
            if selectedDetent == newDetent {
                detents = [selectedDetent]
            } else {
                // If the new detent differs from the currently selected one, it usually means the user manually
                // changed it during the workaround. In this case, we should update the detents again.
                updateDetents()
            }
        }
        storage.obsoleteDetentsRemovalTask?.cancel()
        storage.obsoleteDetentsRemovalTask = task
    }
}
