# Agent instructions

## Project documentation

Before you plan, change or review code:

1. Read [`docs/README.md`](docs/README.md) completely.
2. Use its "Documents" section to find every document that applies to the change.
3. Read each applicable document completely.
4. Follow its rules during implementation and review.
5. Before you finish, check the change against each applicable document.

If existing code or text conflicts with a document, follow the document. Report the conflict instead of copying the
existing pattern.

## Verification

Set up, build and test the project as [`docs/development.md`](docs/development.md) describes. In addition:

- Do not edit generated files. These files include `Sources/*/Sources/Generated/` and `ProcessOut.xcodeproj`.
- If integration tests fail because of the network or the credentials, report the failure. Then test each module
  separately, as `docs/development.md` describes. Use the unit test results of each module.
