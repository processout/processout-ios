//
//  MarkdownList.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownList: MarkdownBaseNode {

    enum ListType {

        /// Ordered
        case ordered(delimiter: Character, startIndex: Int)

        /// Bullet aka unordered list.
        case bullet(marker: Character)
    }

    private(set) lazy var type: ListType = {
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
    }()

    private(set) lazy var isTight: Bool = {
        cmarkNode.pointee.as.list.tight
    }()

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_LIST
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(list: self)
    }
}
