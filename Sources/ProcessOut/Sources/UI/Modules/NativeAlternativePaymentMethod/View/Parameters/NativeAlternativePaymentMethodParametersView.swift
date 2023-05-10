//
//  NativeAlternativePaymentMethodParametersView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.12.2022.
//

import UIKit

final class NativeAlternativePaymentMethodParametersView: UIStackView {

    init(style: NativeAlternativePaymentMethodParametersViewStyle, maximumCodeLength: Int) {
        self.style = style
        self.maximumCodeLength = maximumCodeLength
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with parameters: [NativeAlternativePaymentMethodViewModelState.Parameter], animated: Bool) {
        if areInputFormViewsValid(for: parameters) {
            configureExistingInputFormViews(parameters: parameters, animated: animated)
        } else {
            createNewInputFormViews(parameters: parameters)
            if animated {
                UIView.performWithoutAnimation(layoutIfNeeded)
                addTransitionAnimation()
            }
        }
        currentParameters = parameters
    }

    func configureFirstResponder() {
        guard !inputFormViews.contains(where: { $0.textField.control.isFirstResponder }) else {
            return
        }
        let index = currentParameters?.firstIndex(where: { $0.errorMessage != nil }) ?? 0
        guard inputFormViews.indices.contains(index) else {
            return
        }
        inputFormViews[index].textField.control.becomeFirstResponder()
    }

    weak var delegate: NativeAlternativePaymentMethodParametersViewDelegate?

    /// Layout guide that encloses primary content.
    private(set) lazy var primaryContentLayoutGuide = UILayoutGuide()

    // MARK: - Private Properties

    private let style: NativeAlternativePaymentMethodParametersViewStyle
    private let maximumCodeLength: Int

    private var inputFormViews: [InputFormView] {
        // swiftlint:disable:next force_cast
        arrangedSubviews as! [InputFormView]
    }

    private var currentParameters: [NativeAlternativePaymentMethodViewModelState.Parameter]?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addLayoutGuide(primaryContentLayoutGuide)
    }

    private func createNewInputFormViews(parameters: [NativeAlternativePaymentMethodViewModelState.Parameter]) {
        inputFormViews.forEach { view in
            view.removeFromSuperview()
        }
        parameters.enumerated().forEach { offset, parameter in
            let isLastParameter = offset + 1 == parameters.count
            let inputFormView: InputFormView
            if let length = parameter.length, length <= maximumCodeLength, parameter.type == .numeric {
                let codeTextField = CodeTextField(length: length)
                codeTextField.accessibilityIdentifier = "native-alternative-payment.code-input"
                codeTextField.delegate = self
                codeTextField.returnKeyType = isLastParameter ? .done : .next
                inputFormView = InputFormView(textField: codeTextField, style: style.codeInput)
            } else {
                let containerView = TextFieldContainerView()
                containerView.textField.accessibilityIdentifier = "native-alternative-payment.generic-input"
                containerView.textField.delegate = self
                containerView.textField.returnKeyType = isLastParameter ? .done : .next
                inputFormView = InputFormView(textField: containerView, style: style.input)
            }
            inputFormView.textField.control.addTarget(
                self, action: #selector(controlEditingDidChange), for: .editingChanged
            )
            addArrangedSubview(inputFormView)
        }
        verticallyCenterInputFormViews()
        configureExistingInputFormViews(parameters: parameters, animated: false)
    }

    /// Method adds constraints to make sure that center point between first input form's top edge and last input form
    /// text field's bottom edge is located in between title's bottom edge and action button's top edge.
    private func verticallyCenterInputFormViews() {
        guard let firstInputFormView = inputFormViews.first, let lastInputFormView = inputFormViews.last else {
            return
        }
        let constraints = [
            primaryContentLayoutGuide.topAnchor.constraint(equalTo: firstInputFormView.topAnchor),
            primaryContentLayoutGuide.bottomAnchor.constraint(equalTo: lastInputFormView.textField.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureExistingInputFormViews(
        parameters: [NativeAlternativePaymentMethodViewModelState.Parameter], animated: Bool
    ) {
        inputFormViews.enumerated().forEach { offset, inputFormView in
            let parameter = parameters[offset]
            if let textField = inputFormView.textField as? CodeTextField {
                if textField.text != parameter.value {
                    textField.text = parameter.value
                }
                textField.keyboardType = keyboardType(for: parameter.type)
                textField.textContentType = textContentType(for: parameter.type)
            } else if let containerView = inputFormView.textField as? TextFieldContainerView {
                if containerView.textField.text != parameter.value {
                    containerView.textField.text = parameter.value
                }
                containerView.textField.placeholder = parameter.placeholder
                containerView.textField.keyboardType = keyboardType(for: parameter.type)
                containerView.textField.textContentType = textContentType(for: parameter.type)
            }
            let inputFormViewModel = InputFormView.ViewModel(
                title: parameter.name, description: parameter.errorMessage, isInError: parameter.errorMessage != nil
            )
            inputFormView.configure(viewModel: inputFormViewModel, animated: animated)
        }
    }

    private func advanceFirstResponderToNextInput(control: UIControl) {
        guard let index = inputFormViews.firstIndex(where: { $0.textField.control === control }) else {
            return
        }
        let nextIndex = index + 1
        if inputFormViews.indices.contains(nextIndex) {
            inputFormViews[nextIndex].textField.control.becomeFirstResponder()
        } else {
            delegate?.didCompleteParametersEditing(view: self)
        }
    }

    // MARK: - Utils

    /// Returns boolean value that indicates whether input forms are valid for given parameters. When method
    /// returns `false` make sure to recreate input fields from scratch.
    private func areInputFormViewsValid(
        for parameters: [NativeAlternativePaymentMethodViewModelState.Parameter]
    ) -> Bool {
        let valid = currentParameters?.elementsEqual(parameters) { lhs, rhs in
            lhs.name == rhs.name
                && lhs.placeholder == rhs.placeholder
                && lhs.type == rhs.type
                && lhs.length == rhs.length
        }
        return valid ?? false
    }

    private func keyboardType(
        for parameterType: NativeAlternativePaymentMethodViewModelState.ParameterType
    ) -> UIKeyboardType {
        let keyboardTypes: [NativeAlternativePaymentMethodViewModelState.ParameterType: UIKeyboardType] = [
            .text: .asciiCapable, .email: .emailAddress, .numeric: .numberPad, .phone: .phonePad
        ]
        return keyboardTypes[parameterType] ?? .default
    }

    private func textContentType(
        for parameterType: NativeAlternativePaymentMethodViewModelState.ParameterType
    ) -> UITextContentType? {
        switch parameterType {
        case .text:
            return nil
        case .email:
            return .emailAddress
        case .numeric:
            return .oneTimeCode
        case .phone:
            return .telephoneNumber
        }
    }

    // MARK: - Actions

    @objc
    private func controlEditingDidChange(_ control: UIControl) {
        guard let index = inputFormViews.firstIndex(where: { $0.textField.control === control }),
              let parameters = currentParameters,
              parameters.indices.contains(index) else {
            return
        }
        let text: String?
        if let codeTextField = control as? CodeTextField {
            text = codeTextField.text
        } else if let textField = control as? UITextField {
            text = textField.text
        } else {
            return
        }
        parameters[index].update(text ?? "")
    }
}

extension NativeAlternativePaymentMethodParametersView: CodeTextFieldDelegate {

    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool {
        delegate?.shouldBeginEditing(view: self) ?? false
    }

    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool {
        advanceFirstResponderToNextInput(control: textField)
        return true
    }
}

extension NativeAlternativePaymentMethodParametersView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.shouldBeginEditing(view: self) ?? false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        advanceFirstResponderToNextInput(control: textField)
        return true
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
    ) -> Bool {
        guard let index = inputFormViews.map(\.textField.control).firstIndex(of: textField),
              let parameter = currentParameters?[index] else {
            return true
        }
        // swiftlint:disable:next legacy_objc_type
        let updatedText = (textField.text as? NSString)?.replacingCharacters(in: range, with: string) ?? ""
        let formattedText = parameter.formatted(updatedText)
        guard formattedText != updatedText, #available(iOS 13.0, *) else {
            return true
        }
        textField.text = formattedText
        let adjustedOffset = adjustedIndexOffset(
            in: formattedText,
            source: updatedText,
            sourceIndexOffset: range.lowerBound + string.count,
            ignoredCharacters: .decimalDigits.inverted,
            greedy: !string.isEmpty
        )
        if let position = textField.position(from: textField.beginningOfDocument, offset: adjustedOffset) {
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        textField.sendActions(for: .editingChanged)
        return false
    }
}

/// Returns index in formatted string that matches index in `string`.
@available(iOS 13.0, *)
func adjustedIndexOffset(
    in target: String,
    source: String,
    sourceIndexOffset: Int,
    ignoredCharacters: CharacterSet = [],
    greedy: Bool = true
) -> Int {
    let (sourceLhs, sourceRhs) = split(string: source, by: sourceIndexOffset, ignoredCharacters: ignoredCharacters)

    var minimumDistance: Int = .max
    var adjustedCursorIndex = target.count

    for offset in 0 ... target.count {
        let (targetLhs, targetRhs) = split(string: target, by: offset, ignoredCharacters: ignoredCharacters)

        let distance = targetLhs.difference(from: sourceLhs).count + targetRhs.difference(from: sourceRhs).count

        if distance < minimumDistance || (greedy && distance <= minimumDistance) {
            adjustedCursorIndex = offset
            minimumDistance = distance
        }
    }
    return adjustedCursorIndex
}

func split(string: String, by indexOffset: Int, ignoredCharacters: CharacterSet) -> (String, String) {
    let index = string.index(string.startIndex, offsetBy: indexOffset)
    let lhs = string.prefix(upTo: index).removingCharacters(in: ignoredCharacters)
    let rhs = string.suffix(from: index).removingCharacters(in: ignoredCharacters)
    return (lhs, rhs)
}
