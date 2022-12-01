# ``ProcessOut``

## Overview

Before using ProcessOut SDK make sure to configure it.

```swift
import ProcessOut

let configuration = ProcessOutApiConfiguration.production(projectId: "your_project_id")
ProcessOutApi.configure(configuration: configuration)
```

## Topics

### Framework

- ``ProcessOutApi``
- ``ProcessOutApiConfiguration``
- ``ProcessOutApiType``

### Native Alternative Payment Method

- <doc:NativeAlternativePaymentMethod>
- ``PONativeAlternativePaymentMethodViewControllerBuilder``
- ``PONativeAlternativePaymentMethodStyle``
- ``PONativeAlternativePaymentMethodUiConfiguration``

### Alternative Payment Method

- ``POAlternativePaymentMethodViewControllerBuilder``

### Appearance

Types that describe properties such as shadow and border. And style of higher level components, for example buttons and inputs.

- ``POTextStyle``
- ``POInputFormStyle``
- ``POInputFormStateStyle``
- ``POTextFieldStyle``
- ``POButtonStyle``
- ``POButtonStateStyle``
- ``POActivityIndicatorStyle``
- ``POActivityIndicatorViewType``
- ``POShadowStyle``
- ``POBorderStyle``
- ``POTypography``
