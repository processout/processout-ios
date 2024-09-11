//
//  DeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 01/11/2022.
//

protocol DeviceMetadataProvider: Sendable {

    /// Returns device metadata.
    var deviceMetadata: DeviceMetadata { get async }
}
