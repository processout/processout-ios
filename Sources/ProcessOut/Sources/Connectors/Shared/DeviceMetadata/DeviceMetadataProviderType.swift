//
//  DeviceMetadataProviderType.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 01/11/2022.
//

import Foundation

protocol DeviceMetadataProviderType {

    /// Returns device metadata.
    var deviceMetadata: DeviceMetadata { get }
}
