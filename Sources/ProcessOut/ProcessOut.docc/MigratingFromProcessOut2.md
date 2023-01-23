# Migrating from ProcessOut v2

## Overview

Version 3 is not backward compatible with previous versions, although migration from version 2 should be pretty
straightforward. There are two minor changes that should be addressed when migrating:

1. Instead of `ProcessOut.Setup(projectId: String)` there is new method that should be used to configure
SDK ``ProcessOutApi/configure(configuration:)``.

2. `ProcessOut` was renamed to ``ProcessOutLegacyApi`` to avoid shadowing module name as it may cause issues. For more
information, see [Swift Issue](https://github.com/apple/swift/issues/56573).
