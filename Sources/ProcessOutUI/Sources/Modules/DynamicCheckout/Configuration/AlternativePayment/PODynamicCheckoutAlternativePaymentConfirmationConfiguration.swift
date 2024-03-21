//
//  PODynamicCheckoutAlternativePaymentConfirmationConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import Foundation

// swiftlint:disable:next type_name
public struct PODynamicCheckoutAlternativePaymentConfirmationConfiguration {

    public struct CancelAction {

        /// Action title. Pass `nil` title to use default value.
        public var title: String?

        /// By default user can interact with action immediately after it becomes visible, it is
        /// possible to make it initialy disabled for given amount of time.
        public var disabledFor: TimeInterval = 0
    }

    /// Boolean value that specifies whether module should wait for payment confirmation from PSP or will
    /// complete right after all user's input is submitted. Default value is `true`.
    public var waitsConfirmation = true

    /// Amount of time (in seconds) that module is allowed to wait before receiving final payment confirmation.
    /// Maximum value is 180 seconds.
    public var timeout: TimeInterval = 180

    /// Action that could be optionally presented to user during payment confirmation stage. To remove action
    /// use `nil`, this is default behaviour.
    public var cancelAction: CancelAction?
}
