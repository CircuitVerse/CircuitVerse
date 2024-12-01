Fixed issue[#5168](https://github.com/CircuitVerse/CircuitVerse/issues/5168)

Feature request for having an option for translating Non-English comments to English comments.
NOTE: The current API is hosted from my end on github codespace,
the current implementation of the translation feature utilizes a temporary LibreTranslate API hosted on a GitHub Codespace. This setup is only intended for testing and development purposes.

API Details
Endpoint: Configure `TRANSLATE_API_ENDPOINT` in your environment (see Configuration section)
Purpose: Provides translation of comments from various languages to English.
Limitations:
This API setup is not stable or permanent.
It is hosted on a Codespace, which might not always be available.


## Configuration
To configure the translation API endpoint for production:

Set the TRANSLATE_API_ENDPOINT environment variable:
TRANSLATE_API_ENDPOINT=https://your-production-api-endpoint.com/translate

or simple use shell to enter 

export TRANSLATE_API_ENDPOINT=https://your-production-api-endpoint.com/translate

# Production Setup

Replace this temporary API endpoint with a more stable solution, such as:

## Option 1: Self-hosted LibreTranslate
- System requirements
- Docker setup instructions
- Estimated costs

## Option 2: Third-party API
- Supported providers (Google Translate, DeepL, etc.)
- Authentication setup
- Pricing considerations

## Implementation Notes
- Update the translation method in `CommentsController`
- Configure error handling
- Set up monitoring