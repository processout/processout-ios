# Migration Guides

## Migrating from versions < 5.0.0

- `POCheckout3DSServiceBuilder` was removed, instead use ``POCheckout3DSService/init(delegate:environment:)`` to create
service. Delegate could be passed during initialization or injected later.

- Delegate was migrated to structured concurrency, additionally naming was updated:

  - Method `func configuration(with:)` where delegate was asked to provide service configuration is no longer available.
It was replaced with ``POCheckout3DSServiceDelegate/checkout3DSService(_:willCreateAuthenticationRequestParametersWith:)``.
Passed `configuration` is an inout argument that you could modify to alter styling and behaviour of underlying 3DS
service.

  - Method `func shouldContinue(with warnings:completion:)` became
``POCheckout3DSServiceDelegate/checkout3DSService(_:shouldContinueWith:)``.

  - Method `func didCreateAuthenticationRequest(result:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:didCreateAuthenticationRequestParameters:)``.

  - Method `func willHandle(challenge:)` was replaced with ``POCheckout3DSServiceDelegate/checkout3DSService(_:willPerformChallengeWith:)``.

  - Method `func didHandle3DS2Challenge(result:)` was replaced with ``POCheckout3DSServiceDelegate/checkout3DSService(_:didPerformChallenge:)``.

- `POCheckout3DSService` now holds a weak reference to its delegate.

## Migrating from versions < 4.0.0

- ``POCheckout3DSServiceBuilder`` should be created via init and configured with instance methods. Static factory 
method is deprecated.
