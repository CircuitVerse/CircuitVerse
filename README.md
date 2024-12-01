Fixed issue[#5168](https://github.com/CircuitVerse/CircuitVerse/issues/5168)

Feature request for having an option for translating Non-English comments to English comments.
NOTE: The current implementation utilizes a temporary LibreTranslate API hosted on GitHub Codespaces. This setup is intended for testing and development purposes only.

API Details
Endpoint: Configure `TRANSLATE_API_ENDPOINT` in your environment (see Configuration section)
Purpose: Provides translation of comments from various languages to English.
Limitations:
- This API setup is not stable or permanent
- Hosted on a Codespace with limited availability
- Rate limited to prevent abuse
- Maximum text length: [specify limit]

Request Format:
```json
{
  "text": "Text to translate",
  "source_lang": "auto",
  "target_lang": "en"
}
```

Error Handling:
- 429: Rate limit exceeded
- 413: Text too long
- 503: Service unavailable

### Configuration
To configure the translation API endpoint for production:

### Environment Variables

Create a `.env` file (ensure it's in .gitignore):
```env
# Translation API configuration
TRANSLATE_API_ENDPOINT=your-production-api-endpoint
TRANSLATE_API_KEY=your-api-key  
```

For development, you can set variables in your shell:
```bash
export TRANSLATE_API_ENDPOINT="your-production-api-endpoint"
export TRANSLATE_API_KEY="your-api-key"
```

⚠️ Never commit API keys or endpoints directly to the repository

# Production Setup

Replace this temporary API endpoint with a more stable solution, such as:

## Option 1: Self-hosted LibreTranslate
### System Requirements
- Minimum 2 CPU cores
- 4GB RAM
- 20GB storage

### Docker Setup
```bash
docker run -d \
  --name libretranslate \
  -p 5000:5000 \
  libretranslate/libretranslate
```

### Estimated Costs
- Self-hosting: $20-50/month (cloud VM)
- Maintenance: 2-4 hours/month

## Option 2: Third-party API
### Recommended Providers
1. Google Cloud Translation
   - Setup guide: [link]
   - Pricing: $20 per million characters
   - Features: 200+ languages

2. DeepL API
   - Setup guide: [link]
   - Pricing: $25 per million characters
   - Features: Higher accuracy for supported languages

## Implementation Notes
### Code Updates Required
1. Update `CommentsController`:
   ```ruby
   def translate
     # Add API key to headers
     # Implement retry logic
     # Add error handling
   end
   ```

### Monitoring Setup
1. Add Sentry/NewRelic for error tracking
2. Monitor API usage and costs
3. Set up alerts for:
   - High error rates
   - API quota usage
   - Response time degradation