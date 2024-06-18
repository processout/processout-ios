//
//  View+Notification.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 18.06.2024.
//

import SwiftUI

extension View {

    /// Adds an action to perform when this view detects notification broadcasted by the given center.
    func onReceive(
        notification name: Notification.Name,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        perform: @escaping (Notification) -> Void
    ) -> some View {
        onReceive(center.publisher(for: name, object: object), perform: perform)
    }
}
