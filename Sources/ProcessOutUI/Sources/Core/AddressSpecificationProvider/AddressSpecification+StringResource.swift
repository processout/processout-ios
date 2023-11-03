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
            .city: StringResource("address-spec.city", comment: ""),
            .district: StringResource("address-spec.district", comment: ""),
            .postTown: StringResource("address-spec.post-town", comment: ""),
            .suburb: StringResource("address-spec.suburb", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}

extension AddressSpecification.StateUnit {

    var stringResource: StringResource {
        let resources: [Self: StringResource] = [
            .area: StringResource("address-spec.area", comment: ""),
            .county: StringResource("address-spec.county", comment: ""),
            .department: StringResource("address-spec.department", comment: ""),
            .doSi: StringResource("address-spec.do-si", comment: ""),
            .emirate: StringResource("address-spec.emirate", comment: ""),
            .island: StringResource("address-spec.island", comment: ""),
            .oblast: StringResource("address-spec.oblast", comment: ""),
            .parish: StringResource("address-spec.parish", comment: ""),
            .prefecture: StringResource("address-spec.prefecture", comment: ""),
            .province: StringResource("address-spec.province", comment: ""),
            .state: StringResource("address-spec.state", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}

extension AddressSpecification.PostcodeUnit {

    var stringResource: StringResource {
        let resources: [Self: StringResource] = [
            .postcode: StringResource("address-spec.postcode", comment: ""),
            .eircode: StringResource("address-spec.eircode", comment: ""),
            .pin: StringResource("address-spec.pin", comment: ""),
            .zip: StringResource("address-spec.zip", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}
