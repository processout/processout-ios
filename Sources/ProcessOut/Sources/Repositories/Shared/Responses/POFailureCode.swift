//
//  POFailureCode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.02.2025.
//

public struct POFailureCode: Sendable, Equatable {

    public struct Namespace: Sendable, Equatable {

        public let rawValue: String
    }

    public let rawValue: String, namespace: Namespace?

    init(rawValue: String) {
        self.rawValue = rawValue
        self.namespace = Namespace.namespace(for: rawValue)
    }
}

extension POFailureCode.Namespace {

    static func namespace(for rawErrorCode: String) -> Self? {
        nil
    }
}
