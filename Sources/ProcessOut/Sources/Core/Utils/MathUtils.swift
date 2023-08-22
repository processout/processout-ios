//
//  MathUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.08.2023.
//

/// Returns an integer number raised to a given power.
/// - NOTE: Implementation uses exponentiation by squaring algorithm.
func pow(_ x: Int, _ y: Int) -> Int { // swiftlint:disable:this identifier_name
    assert(y >= 0, "Negative exponent is not supported.")
    var base = x, exp = y, result = 1
    while true {
        if exp & 1 == 1 {
            result *= base
        }
        exp >>= 1
        if exp == 0 {
            break
        }
        base *= base
    }
    return result
}
