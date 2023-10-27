//
//  AddressSpecification+StringResource.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.10.2023.
//

import Foundation

extension AddressSpecification.CityUnit {

    var stringResource: StringResource {
        let resources: [Self: StringResource] = [
            .city: StringResource("address-spec.city", tableName: "ProcessOutUI", comment: ""),
            .district: StringResource("address-spec.district", tableName: "ProcessOutUI", comment: ""),
            .postTown: StringResource("address-spec.post-town", tableName: "ProcessOutUI", comment: ""),
            .suburb: StringResource("address-spec.suburb", tableName: "ProcessOutUI", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}

extension AddressSpecification.StateUnit {

    var stringResource: StringResource {
        let resources: [Self: StringResource] = [
            .area: StringResource("address-spec.area", tableName: "ProcessOutUI", comment: ""),
            .county: StringResource("address-spec.county", tableName: "ProcessOutUI", comment: ""),
            .department: StringResource("address-spec.department", tableName: "ProcessOutUI", comment: ""),
            .doSi: StringResource("address-spec.do-si", tableName: "ProcessOutUI", comment: ""),
            .emirate: StringResource("address-spec.emirate", tableName: "ProcessOutUI", comment: ""),
            .island: StringResource("address-spec.island", tableName: "ProcessOutUI", comment: ""),
            .oblast: StringResource("address-spec.oblast", tableName: "ProcessOutUI", comment: ""),
            .parish: StringResource("address-spec.parish", tableName: "ProcessOutUI", comment: ""),
            .prefecture: StringResource("address-spec.prefecture", tableName: "ProcessOutUI", comment: ""),
            .province: StringResource("address-spec.province", tableName: "ProcessOutUI", comment: ""),
            .state: StringResource("address-spec.state", tableName: "ProcessOutUI", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}

extension AddressSpecification.PostcodeUnit {

    var stringResource: StringResource {
        let resources: [Self: StringResource] = [
            .postcode: StringResource("address-spec.postcode", tableName: "ProcessOutUI", comment: ""),
            .eircode: StringResource("address-spec.eircode", tableName: "ProcessOutUI", comment: ""),
            .pin: StringResource("address-spec.pin", tableName: "ProcessOutUI", comment: ""),
            .zip: StringResource("address-spec.zip", tableName: "ProcessOutUI", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}
