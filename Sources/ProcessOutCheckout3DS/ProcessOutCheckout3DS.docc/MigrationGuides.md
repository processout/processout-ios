# Migration Guides

## Migrating from versions < 4.22.0

- `POCheckout3DSServiceBuilder` was deprecated, instead use ``POCheckout3DSService/init(delegate:environment:)`` to
create service. Delegate could be passed during initialization.

- Delegate was migrated to structured concurrency, additionally naming was updated:

- Method `func willCreateAuthenticationRequest(configuration:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:willCreateAuthenticationRequestParametersWith:)``.

  - Method `func configuration(with:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:configurationWith:)``.

  - Method `func shouldContinue(with warnings:completion:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:shouldContinueWith:)``.

  - Method `func didCreateAuthenticationRequest(result:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:didCreateAuthenticationRequestParameters:)``.

  - Method `func willHandle(challenge:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:willPerformChallengeWith:)``.

  - Method `func didHandle3DS2Challenge(result:)` was replaced with
``POCheckout3DSServiceDelegate/checkout3DSService(_:didPerformChallenge:)``.

## Migrating from versions < 4.0.0

- ``POCheckout3DSServiceBuilder`` should be created via init and configured with instance methods. Static factory 
method is deprecated.
