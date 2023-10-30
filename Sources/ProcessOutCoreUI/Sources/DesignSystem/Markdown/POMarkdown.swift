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
        HorizontalSizeReader { width in
            TextViewRepresentable(string: string, preferredWidth: width)
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
    let preferredWidth: CGFloat

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
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

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.typography
                builder.sizeCategory = UIContentSizeCategory(sizeCategory)
                builder.color = UIColor(style.color)
                builder.lineBreakMode = .byWordWrapping
                builder.alignment = NSTextAlignment(multilineTextAlignment)
                builder.text = .markdown(string)
            }
            .build()
        updateWidthConstraint(textView: textView)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let widthConstraintId = UUID().uuidString
    }

    // MARK: - Private Properties

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.multilineTextAlignment) private var multilineTextAlignment
    @Environment(\.textStyle) private var style: POTextStyle

    // MARK: - Private Methods

    private func updateWidthConstraint(textView: UITextView) {
        var widthConstraint: NSLayoutConstraint?
        for constraint in textView.constraints where constraint.identifier == Constants.widthConstraintId {
            widthConstraint = constraint
            break
        }
        if let widthConstraint {
            widthConstraint.constant = preferredWidth
            return
        }
        let constraint = textView.widthAnchor.constraint(equalToConstant: preferredWidth)
        constraint.identifier = Constants.widthConstraintId
        constraint.isActive = true
    }
}
