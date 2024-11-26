//
//  CardAttributeDetector.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

protocol CardAttributeDetector<Attribute> {

    associatedtype Attribute

    /// Attempts to match attribute in given candidates.
    func firstMatch(in candidates: inout [String]) -> Attribute?
}
