//
//  ActivityIndicatorViewFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2022.
//

import UIKit

@available(*, deprecated)
final class ActivityIndicatorViewFactory {

    func create(style: POActivityIndicatorStyle) -> POActivityIndicatorView {
        let view: POActivityIndicatorView
        switch style {
        case .custom(let customView):
            view = customView
        case let .system(style, color):
            let indicatorView = UIActivityIndicatorView(style: style)
            indicatorView.color = color
            view = indicatorView
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
