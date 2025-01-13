//
//  Backport+ProposedSize.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.01.2025.
//

import Foundation
import SwiftUI

extension POBackport where Wrapped: Any {

    public struct ProposedSize: Sendable, BitwiseCopyable, Hashable {

        public init(_ proposedSize: _ProposedSize) {
            self = unsafeBitCast(proposedSize, to: ProposedSize.self)
        }

        public init(width: CGFloat?, height: CGFloat?) {
            self.width = width
            self.height = height
        }

        /// Proposed width and height.
        public let width, height: CGFloat?
    }
}

extension POBackport.ProposedSize {

    /// A size proposal that contains zero in both dimensions.
    public static var zero: POBackport.ProposedSize {
        .init(width: 0, height: 0)
    }

    /// The proposed size with both dimensions left unspecified.
    public static var unspecified: POBackport.ProposedSize {
        .init(width: nil, height: nil)
    }

    /// A size proposal that contains infinity in both dimensions.
    public static var infinity: POBackport.ProposedSize {
        .init(width: .infinity, height: .infinity)
    }
}

extension POBackport.ProposedSize {

    /// Creates a new proposal that replaces unspecified dimensions in this
    /// proposal with the corresponding dimension of the specified size.
    public func replacingUnspecifiedDimensions(by size: CGSize = CGSize(width: 10, height: 10)) -> CGSize {
        .init(width: width ?? size.width, height: height ?? size.height)
    }
}
