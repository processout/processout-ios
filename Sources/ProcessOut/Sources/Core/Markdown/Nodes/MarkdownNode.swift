//
//  MarkdownNode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

import cmark

class MarkdownNode {

    init(node: NodePointer, validateType: Bool = true) {
        if validateType {
            assert(node.pointee.type == Self.rawType.rawValue)
        }
        self.rawNode = node
    }

    /// Returns node children.
    private(set) lazy var children: [MarkdownNode] = {
        var rawNextChild = rawNode.pointee.first_child
        var children: [MarkdownNode] = []
        while let rawNode = rawNextChild {
            let child = MarkdownNodeFactory(rawNode: rawNode).create()
            children.append(child)
            rawNextChild = rawNode.pointee.next
        }
        return children
    }()

    /// Accepts given visitor.
    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result { // swiftlint:disable:this unavailable_function
        fatalError("Must be implemented by subclass.")
    }

    // MARK: - Raw Content

    typealias NodePointer = UnsafeMutablePointer<cmark_node>

    class var rawType: cmark_node_type {
        CMARK_NODE_NONE
    }

    let rawNode: NodePointer
}
