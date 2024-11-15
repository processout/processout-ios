//
//  Environment+Sendable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2024.
//

import Checkout3DS

#if hasFeature(RetroactiveAttribute)
extension Checkout3DS.Environment: @retroactive @unchecked Sendable { }
#else
extension Checkout3DS.Environment: @unchecked Sendable { }
#endif
