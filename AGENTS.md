# Agent instructions

## Project documentation

Before you plan, change or review code:

1. Read [`docs/README.md`](docs/README.md) completely.
2. Use its catalog to find every document that applies to the change.
3. Read each applicable document completely.
4. Follow its rules during implementation and review.
5. Before you finish, check the change against each applicable document.

If existing code or text conflicts with a document, follow the document. Report the conflict instead of copying the
existing pattern.

## Verification

- To verify a change, run `./Scripts/Tests/Run.sh`. The script cleans, builds and tests every module.
- To test one module, run the following command with the scheme of that module:

  ```bash
  xcodebuild test -project ProcessOut.xcodeproj -scheme ProcessOut -destination "$(./Scripts/Tests/Destination.swift)"
  ```

- Each build runs SwiftLint in strict mode. A lint violation fails the build. To lint without a build, run
  `./Scripts/Lint.sh`.
- Files in `Sources/*/Sources/Generated/` are generated. Do not edit them.
- `ProcessOut.xcodeproj` is generated. Edit `project.yml`, then run `./Scripts/BootstrapProject.sh`.
- Integration tests in `Tests/*/Sources/Integration/` call the live API with the credentials in `Constants.swift`. If
  they fail because of the network or the credentials, report the failure and use the unit test results.
