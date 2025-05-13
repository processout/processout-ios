//
//  AddressSpecification.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.10.2023.
//

// swiftlint:disable nesting

struct AddressSpecification: Sendable, Decodable {

    enum Unit: Sendable {

        enum City: String, Sendable {
            case city, district, postTown, suburb
        }

        enum State: String, Sendable {
            case area, county, department, doSi, emirate, island, oblast, parish, prefecture, province, state
        }

        enum Postcode: String, Sendable {
            case postcode, eircode, pin, zip
        }

        case street, city(City), state(State), postcode(Postcode)
    }

    /// Available address units.
    /// - NOTE: Order defines how components will later be positioned in UI.
    /// Address units.
    let units: [Unit]
}

extension AddressSpecification.Unit {

    enum Plain {
        case street, city, state, postcode
    }

    var plain: Plain {
        switch self {
        case .street:
            return .street
        case .city:
            return .city
        case .state:
            return .state
        case .postcode:
            return .postcode
        }
    }
}

extension AddressSpecification.Unit: Decodable {

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let unit = Self(rawValue: rawValue) else {
            let debugDescription = "Unknown raw value: \(rawValue)."
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: debugDescription)
            throw DecodingError.dataCorrupted(context)
        }
        self = unit
    }

    // MARK: - Private Methods

    private init?(rawValue: String) {
        if rawValue == "street" {
            self = .street
        } else if let city = City(rawValue: rawValue) {
            self = .city(city)
        } else if let state = State(rawValue: rawValue) {
            self = .state(state)
        } else if let postcode = Postcode(rawValue: rawValue) {
            self = .postcode(postcode)
        } else {
            return nil
        }
    }
}

extension AddressSpecification {

    /// Default address specification.
    static var `default`: AddressSpecification {
        .init(units: [.street, .city(.city), .state(.province), .postcode(.postcode)])
    }
}

// swiftlint:enable nesting
