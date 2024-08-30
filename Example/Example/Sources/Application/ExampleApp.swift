//
//  ExampleApp.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import SwiftUI

@main
struct ExampleApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeaturesView()
            }
            .toolbarTitleDisplayMode(.automatic)
        }
    }

    // MARK: - Private Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
}
