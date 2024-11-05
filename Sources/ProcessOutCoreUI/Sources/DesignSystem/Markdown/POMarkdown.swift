//
//  POMarkdown.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.09.2023.
//

import SwiftUI

@available(iOS 14, *)
@_spi(PO)
public struct POMarkdown: View {

    public init(_ string: String) {
        self.string = string
    }

    public var body: some View {
        if #unavailable(iOS 16) {
            HorizontalSizeReader { width in
                TextViewRepresentable(string: string, preferredWidth: width)
            }
        } else {
            TextViewRepresentable(string: string, preferredWidth: 0)
        }
    }

    // MARK: - Private Properties

    private let string: String
}

@available(iOS 14, *)
private struct TextViewRepresentable: UIViewRepresentable {

    /// The text that the view displays.
    let string: String

    /// The preferred maximum width, in points.
    /// - NOTE: value of this property is ignored when iOS 16 is available.
    @available(iOS, deprecated: 16)
    let preferredWidth: CGFloat

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
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: TextView, context: Context) -> CGSize? {
        if let width = proposal.width {
            return uiView.attributedText.sizeThatFits(width: width)
        }
        return uiView.attributedText.sizeThatFits(height: proposal.height ?? 0)
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
        textView.preferredWidth = preferredWidth
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

    /// - NOTE: value of this property is ignored when iOS 16 is available.
    var preferredWidth: CGFloat = 0 {
        didSet { invalidateIntrinsicContentSize() }
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    override var attributedText: NSAttributedString! {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        if #unavailable(iOS 16) {
            // todo(andrii-vysotskyi): decide if size should be cached
            return attributedText.sizeThatFits(width: preferredWidth)
        }
        return super.intrinsicContentSize
    }
}

extension NSAttributedString {

    // swiftlint:disable:next strict_fileprivate
    fileprivate func sizeThatFits(width: CGFloat) -> CGSize {
        let proposedSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingRect = boundingRect(
            with: proposedSize, options: boundingRectOptions, context: nil
        )
        return CGSize(width: max(ceil(boundingRect.width), width), height: ceil(boundingRect.height))
    }

    // swiftlint:disable:next strict_fileprivate
    fileprivate func sizeThatFits(height: CGFloat) -> CGSize {
        let proposedSize = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingRect = boundingRect(
            with: proposedSize, options: boundingRectOptions, context: nil
        )
        return CGSize(width: ceil(boundingRect.width), height: max(ceil(boundingRect.height), height))
    }

    // MARK: -

    private var boundingRectOptions: NSStringDrawingOptions {
        var options: NSStringDrawingOptions = [.usesLineFragmentOrigin]
        if #available(iOS 16, *) {
            options.insert(.usesFontLeading)
        }
        return options
    }
}
