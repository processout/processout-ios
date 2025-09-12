//
//  POFailureCode+Namespace.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.02.2025.
//

extension POFailureCode {

    /// A namespace that categorizes failure codes into specific error domains.
    public struct Namespace: Sendable, Equatable {

        /// The raw string value of the namespace.
        public let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue.lowercased()
        }
    }

    /// The namespace associated with the failure code.
    public var namespace: Namespace? {
        let knownNamespaces: [Namespace] = [
            .authentication, .card, .requestValidation, .request, .customer, .gateway, .resource, .mobile
        ]
        for namespace in knownNamespaces where rawValue.hasPrefix(namespace.rawValue) {
            return namespace
        }
        return nil
    }
}

extension POFailureCode.Namespace {

    /// Authentication errors.
    public static let authentication = POFailureCode.Namespace(rawValue: "request.authentication")

    /// Card errors.
    public static let card = POFailureCode.Namespace(rawValue: "card")

    /// Request validation errors.
    public static let requestValidation = POFailureCode.Namespace(rawValue: "request.validation")

    /// Request errors.
    public static let request = POFailureCode.Namespace(rawValue: "request")

    /// Customer errors.
    public static let customer = POFailureCode.Namespace(rawValue: "customer")

    /// Gateway errors.
    public static let gateway = POFailureCode.Namespace(rawValue: "gateway")

    /// Resource errors.
    public static let resource = POFailureCode.Namespace(rawValue: "resource")

    /// Mobile SDK errors.
    public static let mobile = POFailureCode.Namespace(rawValue: "processout-mobile")
}
