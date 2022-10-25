//
//  RouterType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 23.10.2022.
//

protocol RouterType: AnyObject {

    /// `RouteType` defines which routes can be triggered in a certain implementation.
    associatedtype RouteType: Example.RouteType

    /// Triggers transition for given route.
    /// - Returns: `true` if implementation was able to trigger the transition.
    @discardableResult
    func trigger(route: RouteType) -> Bool
}

protocol RouteType { }
