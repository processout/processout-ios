//
//  PONetcetera3DS2ServiceConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.04.2025.
//

import Foundation
import ThreeDS_SDK

/// Configuration options for customizing the behavior and appearance of
/// `PONetcetera3DS2Service`.
///
/// Use this struct to tailor how the 3DS2 service behaves, including UI customization,
/// localization, challenge timeout, and support for Out-of-Band (OOB) challenges.
public struct PONetcetera3DS2ServiceConfiguration {

    /// Defines the mode of device information collection, influencing which parameters are included
    /// in the authentication request.
    public enum AuthenticationMode {

        /// Omits certain parameters to ensure the authentication request is compliant with
        /// wider range of payment providers. This is the default mode.
        case compatibility

        /// Collects all available parameters without restrictions.
        case full
    }

    /// Creates configuration instance.
    public init(
        authenticationMode: AuthenticationMode = .compatibility,
        locale: Locale? = nil,
        uiCustomizations: [String: UiCustomization]? = nil,
        showsProgressView: Bool = true,
        bridgingExtensionVersion: BridgingExtensionVersion? = nil,
        returnUrl: URL? = nil,
        challengeTimeout: TimeInterval = 5 * 60
    ) {
        self.authenticationMode = authenticationMode
        self.locale = locale
        self.uiCustomizations = uiCustomizations
        self.showsProgressView = showsProgressView
        self.bridgingExtensionVersion = bridgingExtensionVersion
        self.returnUrl = returnUrl
        self.challengeTimeout = challengeTimeout
    }

    /// Defines the mode of device information collection.
    public let authenticationMode: AuthenticationMode

    /// String that represents the locale for the app’s user interface.
    public let locale: Locale?

    /// UI configuration information that is used to specify the UI layout and theme. For example, font
    /// style and font size. Use UICustomizationType raw values as String keys for the uiCustomizations
    /// dictionary. Each key represents a UI customization for a particular iOS appearance.
    public let uiCustomizations: [String: UiCustomization]?

    /// Indicates whether progress view is going to be presented to user during authentication.
    public let showsProgressView: Bool

    /// The Bridging Message Extension describes how existing EMV® 3-D Secure v2.1 and v2.2 components
    /// can provide or consume additional data related to the EMV® 3-D Secure Protocol and Core Functions
    /// Specification v2.3.1.
    ///
    /// When Bridging Message Extension is used, the 3DS SDK will process the Bridging Message Extension
    /// and if the required elements are present it will enable the OOB Automatic Switching Feature for
    /// Out of Band v2.2 challenges and masking of the challenge input for TEXT v2.2 challenges.
    public let bridgingExtensionVersion: BridgingExtensionVersion?

    /// This is the URL of the application with which it can be called from another application during OOB challenge.
    public let returnUrl: URL?

    /// Timeout interval within which the challenge process must be completed.
    /// The minimum timeout interval is defined to be 5 minutes.
    public let challengeTimeout: TimeInterval
}
