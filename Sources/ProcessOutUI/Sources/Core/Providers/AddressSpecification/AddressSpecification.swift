//
//  AddressSpecification.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.10.2023.
//

struct AddressSpecification: Sendable {

    enum Unit: String, CaseIterable, Decodable, Sendable {
        case street, city, state, postcode
    }

    enum CityUnit: String, Decodable, Sendable {
        case city, district, postTown, suburb
    }

    enum StateUnit: String, Decodable, Sendable {
        case area, county, department, doSi, emirate, island, oblast, parish, prefecture, province, state
    }

    enum PostcodeUnit: String, Decodable, Sendable {
        case postcode, eircode, pin, zip
    }

    struct State: Decodable, Sendable {
        let abbreviation, name: String
    }

    /// Available address units.
    /// - NOTE: Order defines how components will later be positioned in UI.
    let units: [Unit]

    /// City unit.
    let cityUnit: CityUnit

    /// State unit.
    let stateUnit: StateUnit

    /// Available states.
    let states: [State]

    /// Postal code unit.
    let postcodeUnit: PostcodeUnit
}

extension AddressSpecification: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        units = try container.decodeIfPresent([Unit].self, forKey: .units) ?? Unit.allCases
        cityUnit = try container.decodeIfPresent(CityUnit.self, forKey: .cityUnit) ?? .city
        stateUnit = try container.decodeIfPresent(StateUnit.self, forKey: .stateUnit) ?? .province
        states = try container.decodeIfPresent([State].self, forKey: .states) ?? []
        postcodeUnit = try container.decodeIfPresent(PostcodeUnit.self, forKey: .postcodeUnit) ?? .postcode
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case units, cityUnit, stateUnit, states, postcodeUnit
    }
}

extension AddressSpecification {

    /// Default address specification.
    static var `default`: AddressSpecification {
        .init(units: Unit.allCases, cityUnit: .city, stateUnit: .province, states: [], postcodeUnit: .postcode)
    }
}
