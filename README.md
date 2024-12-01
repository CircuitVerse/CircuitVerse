Fixed issue[#5168](https://github.com/CircuitVerse/CircuitVerse/issues/5168)

Feature request for having an option for translating Non-English comments to English comments.
NOTE: The current API is hosted from my end on github codespace,
the current implementation of the translation feature utilizes a temporary LibreTranslate API hosted on a GitHub Codespace. This setup is only intended for testing and development purposes.

API Details
Endpoint: https://ubiquitous-couscous-pqj4w5rjv6wf7jjx-5000.app.github.dev/translate
Purpose: Provides translation of comments from various languages to English.
Limitations:
This API setup is not stable or permanent.
It is hosted on a Codespace, which might not always be available.

Action Required for production or long-term usage:
Replace this temporary API endpoint with a more stable solution, such as:
A self-hosted LibreTranslate instance.
A reliable third-party API like Google Translate (paid service).

Update the translate method in the CommentsController to reflect the new API endpoint.
I have added comments around areas which might need to change with API change