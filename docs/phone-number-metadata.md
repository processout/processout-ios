# Phone number metadata

The phone number formatter in `ProcessOut` uses metadata from [libphonenumber][libphonenumber]. We take the metadata
from [PhoneNumberKit][phonenumberkit], a Swift port of libphonenumber, and store a reduced copy in the SDK. This
document describes how to update the copy.

## Files

| File                                                                           | Content                                                    |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| `Sources/ProcessOut/Resources/PhoneNumberMetadata/PhoneNumberMetadata.json`    | Country code, region ID and number formats of each region. |
| `Sources/ProcessOut/Resources/PhoneNumberMetadata/PhoneNumberMetadata.version` | The libphonenumber metadata version, for example `9.0.21`. |
| `Scripts/PhoneNumberMetadata/Update.sh`                                        | Downloads PhoneNumberKit and writes both files.            |
| `Scripts/PhoneNumberMetadata/Postprocess.swift`                                | Removes the fields that the formatter does not use.        |

Do not edit `PhoneNumberMetadata.json` or `PhoneNumberMetadata.version` by hand. Run the update script.

## Requirements

The script needs `git` and Swift. Both come with Xcode. The test step also needs the project setup in
[Development setup](development.md).

## Update

1. Find the PhoneNumberKit release that has the metadata you need. The `.metadata-version` file in the
   `PhoneNumberKit/Resources/` folder of a release shows its libphonenumber version.
2. From the repository root, run the script with the release tag:

   ```bash
   ./Scripts/PhoneNumberMetadata/Update.sh 4.3.0
   ```

   The script clones PhoneNumberKit at that tag, reduces `PhoneNumberMetadata.json`, and replaces both files in
   `Sources/ProcessOut/Resources/PhoneNumberMetadata/`. The script also accepts a branch name.
3. Make sure that `PhoneNumberMetadata.version` shows the expected version.
4. Run the phone number tests:

   ```bash
   xcodebuild test -project ProcessOut.xcodeproj -scheme ProcessOut \
     -destination "$(./Scripts/Tests/Destination.swift)" \
     -only-testing:ProcessOutTests/PhoneNumberFormatterTests \
     -only-testing:ProcessOutTests/DefaultPhoneNumberMetadataProviderTests
   ```

5. In the pull request description, write the PhoneNumberKit tag and the old and new metadata versions. The repository
   does not record the tag anywhere else.

## Review

`PhoneNumberMetadata.json` is a single line, so the diff is not readable. To compare the old and new metadata, format
both versions of the file:

```bash
FILE=Sources/ProcessOut/Resources/PhoneNumberMetadata/PhoneNumberMetadata.json
diff <(git show HEAD:$FILE | python3 -m json.tool) <(python3 -m json.tool $FILE)
```

The command compares the file with your last commit, so run the command before you commit the update. To review a
pull request, replace `HEAD` with the base branch of the pull request, for example `origin/master`.

[libphonenumber]: https://github.com/google/libphonenumber
[phonenumberkit]: https://github.com/marmelroy/PhoneNumberKit
