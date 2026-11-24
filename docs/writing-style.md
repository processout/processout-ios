# Writing style guide

This guide defines 1 consistent language for text in this repository, for contributors, developers who integrate the SDK, and tools.

## Scope

| Text                                          | Location                    |
| --------------------------------------------- | --------------------------- |
| Internal documentation                        | `docs/`                     |
| DocC articles                                 | `Sources/*/*.docc/`         |
| Code documentation                            | Comments that document code |
| READMEs                                       | `README.md` files           |
| Commit messages and pull request descriptions | Git history and GitHub      |

Localized strings in `Resources/` follow the product copy instead.

---

## 1. Conciseness

Use the fewest words that keep the meaning clear. If a shorter sentence says the same thing, use the shorter sentence.

- Cut filler: "in order to" becomes "to", "is able to" becomes "can". Delete "simply", "just", "basically" and "note that".
- Do not repeat what a heading, a symbol name or a previous sentence already says.
- Do not explain what the reader can see in the code sample.

---

## 2. Modal verbs

Each verb has 1 meaning. Use no other verb of obligation.

| Verb       | Meaning                                              | Example                                                       |
| ---------- | ---------------------------------------------------- | ------------------------------------------------------------- |
| **must**   | Mandatory.                                           | The release tag must match the version in `Version.resolved`. |
| **should** | Recommended. A documented alternative is acceptable. | Your scene delegate should call `processDeepLink(url:)`.      |
| **may**    | Permitted. The reader chooses.                       | You may provide a custom style for the submit button.         |
| **can**    | A capability, not an obligation.                     | ``POCardTokenizationView`` can collect a billing address.     |
| **will**   | A fact about the future or an external system.       | Apple will reject a build that uses a private API.            |

**Do not use:** shall, needs to, has to, is required to, ought to.

---

## 3. Sentences

1. Write 1 topic per sentence.
2. Use at most 20 words in an instruction and 25 in a description.
3. Use the active voice: "The SDK sends the request", not "The request is sent".
4. Use the present tense for descriptions and the imperative for instructions.
5. Start an instruction with the verb: "Run `./Scripts/BootstrapProject.sh`", not "You should run `./Scripts/BootstrapProject.sh`".
6. Write 1 instruction per sentence or list item.
7. Put the condition first: "If the build fails, delete `DerivedData`."
8. Do not use fragments as sentences in prose. Labels, table cells, checklist items and code documentation summaries (section 7) are exceptions.

---

## 4. Words

1. Use 1 term for 1 concept everywhere. Prefer the term the public API uses.
2. Define an acronym on first use in each document. API, SDK, UI, iOS, URL, JSON, UTC, ID, 3DS and README need no definition.
3. Use digits for numbers: "3 retries", not "three retries". A number that starts a sentence is the exception.
4. Repeat the noun when a pronoun's referent is not in the same sentence.
5. Do not start a sentence with "this", "that" or "it" to refer to the previous sentence.
6. Do not use vague quantifiers: "some", "various", "appropriate", "as needed", "etc.".
7. Do not put a slash between words. Write "or", "and", or both cases.
8. Do not use em-dashes. Use a full stop, a comma or parentheses.
9. Use short, common words: "use", not "utilize"; "start", not "initiate".
10. Use American English to match Apple APIs: "color", "behavior". Keep the spelling of an existing public API term, for example "cancelled" (`POFailureCode.cancelled`).
11. Write proper names as their owners do: Apple Pay, SwiftUI, UIKit, Xcode, Swift Package Index, Checkout.com.
12. Write "API", "ID" and "URL" in capitals in prose. Symbols keep their own spelling, for example `projectId`.

### Reader

- In DocC and code documentation, address the developer as "you" and their app as "your app".
- In `docs/`, use "we" for the team that maintains the SDK.
- Do not write "user". Write "customer" for the person who pays and "developer" for the person who integrates the SDK.

---

## 5. Structure

1. Lead with the conclusion. Put the rationale after.
2. Use bullets for parallel items, numbers for ordered steps and tables for items with the same attributes.
3. Keep a paragraph to 1 idea and at most 6 sentences.
4. Write headings as noun phrases.
5. Use sentence case for headings in `docs/`. Use title case for DocC titles and topic groups, as Apple documentation does.
6. Put code, commands, paths, field names and values in backticks or fenced code blocks.
7. Give every fenced code block a language: `swift`, `bash`, `yaml`.
8. Align the columns of Markdown tables so the raw file is readable.

---

## 6. DocC articles

1. Start with an overview of 1 to 3 sentences: what the feature does and when to use it.
2. Put steps in a numbered list, with each code sample right after its step.
3. Link symbols with double backticks: ``` ``POInvoicesService`` ```. DocC checks these links at build time.
4. Link articles with `<doc:ArticleName>`.
5. Use code samples that compile against the current API, with obvious placeholders: `"your_project_id"`.
6. Use callouts for text the reader must not miss: `> Note:`, `> Important:`, `> Warning:`.
7. Write "the SDK" for the whole SDK and the module name for 1 module: `ProcessOutUI`.

---

## 7. Code documentation

### Summary

The summary is the first line of a comment. Tools such as DocC show the summary in symbol lists. Use these patterns and end the summary with a full stop.

| Declaration      | Pattern                                                     | Example                                                              |
| ---------------- | ----------------------------------------------------------- | -------------------------------------------------------------------- |
| Type             | Noun phrase: what the type is.                              | A customer token that links a card to a customer.                    |
| Protocol         | Noun phrase: what a conforming type does.                   | A service that handles 3DS authentication.                           |
| Function         | Third-person verb: what the function does.                  | Authorizes an invoice with the given source.                         |
| Initializer      | "Creates" and the result.                                   | Creates a configuration for the production environment.              |
| Property         | Noun phrase: what the value is.                             | The currency of the invoice.                                         |
| Boolean property | "A Boolean value that indicates whether" and the condition. | A Boolean value that indicates whether the gateway supports refunds. |
| Identifier       | "The unique identifier of" and the owner.                   | The unique identifier of the invoice.                                |
| Enumeration case | What the case means.                                        | The customer cancelled the payment.                                  |

### Details

1. Do not repeat the summary.
2. Document every parameter, return value and thrown error, unless the summary already covers it.
3. Name the failure codes the caller can handle.
4. Describe behavior the caller can see, not the implementation.
5. Make every deprecation name its replacement. If there is no replacement, say why.
6. Start each script with a comment that says what the script does.

---

## 8. Commit messages and pull requests

Commit subjects follow [Conventional Commits](https://www.conventionalcommits.org). Commit bodies and pull request descriptions follow the prose rules of this guide.

---

## 9. Review checklist

- [ ] Every sentence is as short as the meaning allows
- [ ] Modal verbs have the meanings in section 2
- [ ] Each concept has 1 term throughout
- [ ] No vague quantifiers, slashes between words or em-dashes
- [ ] The conclusion comes first
- [ ] Symbols are linked with double backticks
- [ ] Code documentation follows section 7
