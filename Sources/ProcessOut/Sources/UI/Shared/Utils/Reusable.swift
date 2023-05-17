//
//  Reusable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

protocol Reusable: AnyObject {

    /// Reuse identifier.
    static var reuseIdentifier: String { get }
}
