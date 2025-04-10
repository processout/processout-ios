//
//  AddressSpecification+StringResource.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.10.2023.
//

import Foundation
@_spi(PO) import ProcessOut

extension AddressSpecification.Unit.City {

    var stringResource: POStringResource {
        let resources: [Self: POStringResource] = [
            .city: POStringResource("address-spec.city", comment: ""),
            .district: POStringResource("address-spec.district", comment: ""),
            .postTown: POStringResource("address-spec.post-town", comment: ""),
            .suburb: POStringResource("address-spec.suburb", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}

extension AddressSpecification.Unit.State {

    var stringResource: POStringResource {
        let resources: [Self: POStringResource] = [
            .area: POStringResource("address-spec.area", comment: ""),
            .county: POStringResource("address-spec.county", comment: ""),
            .department: POStringResource("address-spec.department", comment: ""),
            .doSi: POStringResource("address-spec.do-si", comment: ""),
            .emirate: POStringResource("address-spec.emirate", comment: ""),
            .island: POStringResource("address-spec.island", comment: ""),
            .oblast: POStringResource("address-spec.oblast", comment: ""),
            .parish: POStringResource("address-spec.parish", comment: ""),
            .prefecture: POStringResource("address-spec.prefecture", comment: ""),
            .province: POStringResource("address-spec.province", comment: ""),
            .state: POStringResource("address-spec.state", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}

extension AddressSpecification.Unit.Postcode {

    var stringResource: POStringResource {
        let resources: [Self: POStringResource] = [
            .postcode: POStringResource("address-spec.postcode", comment: ""),
            .eircode: POStringResource("address-spec.eircode", comment: ""),
            .pin: POStringResource("address-spec.pin", comment: ""),
            .zip: POStringResource("address-spec.zip", comment: "")
        ]
        return resources[self]!  // swiftlint:disable:this force_unwrapping
    }
}
