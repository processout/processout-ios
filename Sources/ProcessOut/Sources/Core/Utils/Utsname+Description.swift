//
//  Utsname+Description.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.04.2024.
//

import Foundation

extension utsname {

    /// Returns description for utsname property at a given key path.
    func description(keyPath: PartialKeyPath<utsname>) -> String? {
        let property = self[keyPath: keyPath]
        let description = withUnsafePointer(to: property) { pointer in
            let capacity = Int(_SYS_NAMELEN)
            return pointer.withMemoryRebound(to: CChar.self, capacity: capacity) { charPointer in
                String(validatingUTF8: charPointer)
            }
        }
        return description
    }
}
