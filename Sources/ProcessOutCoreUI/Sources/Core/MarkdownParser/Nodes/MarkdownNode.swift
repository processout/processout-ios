//
//  MarkdownBaseNode.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

import cmark_gfm

class MarkdownBaseNode: @unchecked Sendable {

    typealias CmarkNode = UnsafeMutablePointer<cmark_node>

    class var cmarkNodeType: cmark_node_type {
        fatalError("Must be implemented by subclass.")
    }

    required init(cmarkNode: CmarkNode, validatesType: Bool = true) {
        if validatesType {
            assert(cmarkNode.pointee.type == Self.cmarkNodeType.rawValue)
        }
        self.children = Self.children(of: cmarkNode)
    }

    /// Returns node children.
    let children: [MarkdownBaseNode]

    /// Accepts given visitor.
    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result { // swiftlint:disable:this unavailable_function
        fatalError("Must be implemented by subclass.")
    }

    // MARK: - Private Methods

    private static func children(of cmarkNode: CmarkNode) -> [MarkdownBaseNode] {
        var cmarkChild = cmarkNode.pointee.first_child
        var children: [MarkdownBaseNode] = []
        while let cmarkNode = cmarkChild {
            let child = MarkdownNodeFactory(cmarkNode: cmarkNode).create()
            children.append(child)
            cmarkChild = cmarkNode.pointee.next
        }
        return children
    }
}
