//
//  NativeAlternativePaymentMethodStartedView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2022.
//

import UIKit

final class NativeAlternativePaymentMethodStartedView: UIView {

    init(style: NativeAlternativePaymentMethodStartedViewStyle, logger: POLogger) {
        self.style = style
        self.logger = logger
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureButtonsContainerShadow()
    }

    func configure(with state: NativeAlternativePaymentMethodViewModelState.Started, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(style.title.typography)
                .textStyle(textStyle: .title1)
                .alignment(.center)
                .lineBreakMode(.byWordWrapping)
                .textColor(style.title.color)
                .string(state.title)
                .build()
            parametersView.configure(with: state.parameters, animated: animated)
            buttonsContainerView.configure(
                primaryAction: state.primaryAction, secondaryAction: state.secondaryAction, animated: animated
            )
            layoutIfNeeded()
        }
        currentState = state
        updateFirstResponder()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let inputsVerticalSpacing: CGFloat = 24
        static let maximumCodeLength = 6
        static let titleTopInset: CGFloat = 4
        static let horizontalContentInset: CGFloat = 24
        static let minimumVerticalInputsInset: CGFloat = 8
        static let animationDuration: TimeInterval = 0.25
        static let buttonsContainerShadowVisibilityThreshold: CGFloat = 32 // swiftlint:disable:this identifier_name
    }

    // MARK: - Private Properties

    private let style: NativeAlternativePaymentMethodStartedViewStyle
    private let logger: POLogger

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .always
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var parametersView: NativeAlternativePaymentMethodParametersView = {
        let style = NativeAlternativePaymentMethodParametersViewStyle(input: style.input, codeInput: style.codeInput)
        let view = NativeAlternativePaymentMethodParametersView(
            style: style, maximumCodeLength: Constants.maximumCodeLength
        )
        view.axis = .vertical
        view.spacing = Constants.inputsVerticalSpacing
        view.delegate = self
        return view
    }()

    private lazy var buttonsContainerView: NativeAlternativePaymentMethodButtonsView = {
        let style = NativeAlternativePaymentMethodButtonsViewStyle(
            primaryButton: style.primaryButton, secondaryButton: style.secondaryButton
        )
        let view = NativeAlternativePaymentMethodButtonsView(
            style: style, horizontalInset: Constants.horizontalContentInset
        )
        view.backgroundColor = self.style.backgroundColor
        return view
    }()

    private var currentState: NativeAlternativePaymentMethodViewModelState.Started?
    private var scrollViewContentSizeObservation: NSKeyValueObservation?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        initButtons()
        initScrollView()
        initScrollViewContentView()
    }

    private func initScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        let constraints = [
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor),
            contentView.heightAnchor
                .constraint(equalTo: scrollView.safeAreaLayoutGuide.heightAnchor)
                .with(priority: .defaultHigh)
        ]
        NSLayoutConstraint.activate(constraints)
        observeScrollViewContentSizeChanges()
    }

    private func initScrollViewContentView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(parametersView)
        let parametersContainerLayoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(parametersContainerLayoutGuide)
        let constraints = [
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.horizontalContentInset
            ),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.titleTopInset),
            parametersView.topAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: Constants.minimumVerticalInputsInset
            ),
            parametersView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.horizontalContentInset
            ),
            parametersView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            parametersView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.minimumVerticalInputsInset
            ),
            parametersContainerLayoutGuide.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            parametersContainerLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            parametersView.primaryContentLayoutGuide.centerYAnchor
                .constraint(equalTo: parametersContainerLayoutGuide.centerYAnchor)
                .with(priority: .init(rawValue: 500))
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func initButtons() {
        addSubview(buttonsContainerView)
        let constraints = [
            buttonsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func observeScrollViewContentSizeChanges() {
        let observation = scrollView.observe(\.contentSize, options: [.old]) { [weak self] scrollView, value in
            guard scrollView.contentSize.height != value.oldValue?.height else {
                return
            }
            self?.configureButtonsContainerShadow()
        }
        scrollViewContentSizeObservation = observation
    }

    private func configureButtonsContainerShadow() {
        let minimumContentOffset = scrollView.contentSize.height
            - scrollView.bounds.size.height
            + scrollView.adjustedContentInset.bottom
        let threshold = Constants.buttonsContainerShadowVisibilityThreshold
        let shadowOpacity = max(min(1, (minimumContentOffset - scrollView.contentOffset.y) / threshold), 0)
        buttonsContainerView.apply(style: style.buttonsContainerShadow, shadowOpacity: shadowOpacity)
    }

    // MARK: -

    private func updateFirstResponder() {
        guard let currentState else {
            return
        }
        if currentState.isSubmitting {
            logger.debug("Currently submitting, will end editing")
            endEditing(true)
        } else {
            parametersView.configureFirstResponder()
        }
    }
}

extension NativeAlternativePaymentMethodStartedView: NativeAlternativePaymentMethodParametersViewDelegate {

    func shouldBeginEditing(view: NativeAlternativePaymentMethodParametersView) -> Bool {
        let shouldBeginEditing = currentState?.isSubmitting == false
        if shouldBeginEditing {
            logger.debug("Will begin parameters editing")
        } else {
            logger.debug("Currently submitting, won't begin editing")
        }
        return shouldBeginEditing
    }

    func didCompleteParametersEditing(view: NativeAlternativePaymentMethodParametersView) {
        logger.debug("Did complete parameters editing, will submit")
        currentState?.primaryAction.handler()
    }
}

extension NativeAlternativePaymentMethodStartedView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureButtonsContainerShadow()
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        configureButtonsContainerShadow()
    }
}
