//
//  POMarkdown.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.09.2023.
//

import SwiftUI

@_spi(PO)
@MainActor
public struct POMarkdown: View {

    public init(_ string: String) {
        self.string = string
    }

    public var body: some View {
        TextViewRepresentable(string: string)
    }

    // MARK: - Private Properties

    private let string: String
}

@MainActor
private struct TextViewRepresentable: UIViewRepresentable {

    /// The text that the view displays.
    let string: String

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> TextView {
        let textView = TextView()
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.adjustsFontForContentSizeCategory = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        return textView
    }

    // swiftlint:disable:next identifier_name
    func _overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, uiView: UIViewType) {
        let proposal = POBackport<Any>.ProposedSize(proposedSize).replacingUnspecifiedDimensions(by: .zero)
        size = uiView.attributedText.sizeThatFits(proposedSize: proposal)
    }

    @available(iOS 16, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: TextView, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions(by: .zero)
        return uiView.attributedText.sizeThatFits(proposedSize: proposal)
    }

    func updateUIView(_ textView: TextView, context: Context) {
        let builder = AttributedStringBuilder(
            typography: style.typography,
            fontFeatures: fontFeatures,
            sizeCategory: sizeCategory,
            colorScheme: colorScheme,
            color: style.color,
            alignment: .init(multilineTextAlignment),
            lineBreakMode: .byWordWrapping
        )
        textView.attributedText = builder.build(markdown: string)
    }

    // MARK: - Private Properties

    @Environment(\.sizeCategory)
    private var sizeCategory

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.multilineTextAlignment)
    private var multilineTextAlignment

    @Environment(\.textStyle)
    private var style

    @Environment(\.fontFeatures)
    private var fontFeatures
}

private final class TextView: UITextView {

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
}

extension NSAttributedString {

    func sizeThatFits(proposedSize: CGSize) -> CGSize {
        var boundingRectOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin]
        if #available(iOS 16, *) {
            boundingRectOptions.insert(.usesFontLeading)
        }
        let boundingRect = boundingRect(with: proposedSize, options: boundingRectOptions, context: nil)
        return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
}
