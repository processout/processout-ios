//
//  RouterType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2022.
//

protocol RouterType<RouteType>: AnyObject {

    /// `RouteType` defines which routes can be triggered in a certain implementation.
    associatedtype RouteType: ProcessOut.RouteType

    /// Triggers transition for given route.
    /// - Returns: `true` if implementation was able to trigger the transition.
    @discardableResult
    func trigger(route: RouteType) -> Bool
}

protocol RouteType { }
