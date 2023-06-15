//
//  MarkdownBaseNode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

class MarkdownBaseNode {

    typealias CmarkNode = UnsafeMutablePointer<cmark_node>

    class var cmarkNodeType: cmark_node_type {
        fatalError("Must be implemented by subclass.")
    }

    init(cmarkNode: CmarkNode, validatesType: Bool = true) {
        if validatesType {
            assert(cmarkNode.pointee.type == Self.cmarkNodeType.rawValue)
        }
        self.cmarkNode = cmarkNode
    }

    /// Returns node children.
    private(set) lazy var children: [MarkdownBaseNode] = {
        var rawNextChild = cmarkNode.pointee.first_child
        var children: [MarkdownBaseNode] = []
        while let rawNode = rawNextChild {
            let child = MarkdownNodeFactory(rawNode: rawNode).create()
            children.append(child)
            rawNextChild = rawNode.pointee.next
        }
        return children
    }()

    let cmarkNode: CmarkNode

    /// Accepts given visitor.
    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result { // swiftlint:disable:this unavailable_function
        fatalError("Must be implemented by subclass.")
    }
}
