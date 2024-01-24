#!/usr/bin/env swift

import Foundation

let sourceUrl = URL(filePath: CommandLine.arguments[1])
let targetUrl = URL(filePath: CommandLine.arguments[2])

let sourceDocument = try XMLDocument(contentsOf: sourceUrl)
let targetDocument = try XMLDocument(contentsOf: targetUrl)

var sourceUnits: [String: String] = [:]
parseXliff(document: sourceDocument).forEach { unit in
    sourceUnits[unit.file + unit.id] = unit.source
}

processXliff(document: targetDocument) { unit -> Void in
    unit.source = sourceUnits[unit.file + unit.id] ?? unit.source
}

let writeOptions: XMLNode.Options = [.nodePreserveAll, .nodePrettyPrint]
try targetDocument.xmlData(options: writeOptions).write(to: targetUrl)

// MARK: - Types

struct TranslationUnit {

    /// Unit details.
    let id, file: String

    /// Source translation.
    var source: String
}

// MARK: - Processing

@discardableResult
func processXliff<T>(document: XMLDocument, transform: (inout TranslationUnit) -> T) -> [T] {
    guard let xliffElement = document.children?.first as? XMLElement, xliffElement.name == "xliff" else {
        fatalError("Unexpected document definition.")
    }
    let items = xliffElement.elements(forName: "file").flatMap { element in
        guard let bodyElement = element.elements(forName: "body").first,
              let original = element.attribute(forName: "original")?.stringValue else {
            fatalError("Unexpected file definition.")
        }
        return bodyElement.elements(forName: "trans-unit").map { element in
            guard let id = element.attribute(forName: "id")?.stringValue,
                  let sourceElement = element.elements(forName: "source").first else {
                fatalError("Unexpected unit definition.")
            }
            var unit = TranslationUnit(id: id, file: original, source: sourceElement.stringValue ?? "")
            let item = transform(&unit)
            sourceElement.stringValue = unit.source
            return item
        }
    }
    return items
}

// MARK: - Parsing

func parseXliff(document: XMLDocument) -> [TranslationUnit] {
    processXliff(document: document) { $0 }
}
