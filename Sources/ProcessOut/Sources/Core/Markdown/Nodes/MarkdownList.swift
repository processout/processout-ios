//
//  MarkdownList.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownList: MarkdownBaseNode, @unchecked Sendable {

    enum ListType {

        /// Ordered
        case ordered(delimiter: Character, startIndex: Int)

        /// Bullet aka unordered list.
        case bullet(marker: Character)
    }

    /// List type.
    let type: ListType

    // MARK: - MarkdownBaseNode

    required init(cmarkNode: MarkdownBaseNode.CmarkNode, validatesType: Bool = true) {
        type = Self.listType(cmarkNode: cmarkNode)
        super.init(cmarkNode: cmarkNode, validatesType: validatesType)
    }

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_LIST
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(list: self)
    }

    // MARK: - Private Methods

    private static func listType(cmarkNode: CmarkNode) -> ListType {
        let listNode = cmarkNode.pointee.as.list
        switch UInt32(listNode.list_type) {
        case CMARK_BULLET_LIST.rawValue:
            let marker = Character(Unicode.Scalar(listNode.bullet_char))
            return .bullet(marker: marker)
        case CMARK_ORDERED_LIST.rawValue:
            let delimiter: Character
            switch cmark_node_get_list_delim(cmarkNode) {
            case CMARK_PERIOD_DELIM:
                delimiter = "."
            case CMARK_PAREN_DELIM:
                delimiter = ")"
            default:
                assertionFailure("Unexpected delimiter type")
                delimiter = "."
            }
            let startIndex = Int(listNode.start)
            return .ordered(delimiter: delimiter, startIndex: startIndex)
        default:
            preconditionFailure("Unsupported list type: \(listNode.list_type)")
        }
    }
}
