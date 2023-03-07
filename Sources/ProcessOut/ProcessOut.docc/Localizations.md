# Localizations

## Overview

Currently SDK supports single language that is English.

If the main application uses a language that we don't support, the implementation would attempt to use strings from
the main bundle's `ProcessOut.strings`. 

| String Key                                             | English Translation                                                |
| ------------------------------------------------------ | ------------------------------------------------------------------ | 
| native-alternative-payment.title                       | "Pay with %@"                                                      |
| native-alternative-payment.awaiting-capture.message    | "To complete the payment please confirm it from your banking app." | 
| native-alternative-payment.success.message             | "Success!\nPayment approved"                                       |
| native-alternative-payment.text.placeholder            | "Lorem Ipsum..."                                                   |
| native-alternative-payment.email.placeholder           | "example@domain.com"                                               |
| native-alternative-payment.phone.placeholder           | "Your phone number..."                                             |
| native-alternative-payment.submit-button.title         | "Pay %@"                                                           |
| native-alternative-payment.submit-button.default-title | "Pay"                                                              |
| native-alternative-payment.cancel-button.title         | "Cancel"                                                           |
| native-alternative-payment.error.required-parameter    | "Parameter is required"                                            |
| native-alternative-payment.error.invalid-number        | "Number is not valid"                                              |
| native-alternative-payment.error.invalid-text          | "Value is not valid"                                               |
| native-alternative-payment.error.invalid-email         | "Email is not valid"                                               |
| native-alternative-payment.error.invalid-phone         | "Phone number is not valid"                                        |
| native-alternative-payment.error.invalid-length        | "Invalid length, expected %d character(s)"                         |

You may add translations to `ProcessOut.stringsdict` file if special rules for plurals are desired.
