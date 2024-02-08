//
//  POCardCvcCheck.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2024.
//

/// Current card CVC verification status.
public enum POCardCvcCheck: Decodable, Hashable { // sourcery: AutoStringRepresentable

    /// The CVC was sent and was correct.
    case passed

    /// The CVC was sent but was incorrec/t
    case failed

    /// The CVC was sent but wasn't checked by the issuing bank.
    case unchecked

    /// The CVC wasn't sent as it either wasn't specified by the user, or the
    /// transaction is recurring and the CVC was previously deleted/
    case unavailable

    /// The CVC wasn't available, but the card/issuer required the CVC to be provided to process the transaction.
    case `required`

    /// Some payment providers sometimes don't have the final result of CVC checks,
    /// in which case the CVC check status will be unknown.
    case unknown(String)
}
