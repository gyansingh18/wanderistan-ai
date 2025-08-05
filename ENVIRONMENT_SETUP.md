# Environment Setup Guide

## API Keys Security

⚠️ **IMPORTANT**: Never commit API keys to version control. Always use environment variables.

## Required Environment Variables

Create a `.env` file in your project root with the following variables:

```bash
# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# YouTube API Key
YOUTUBE_API_KEY=your_youtube_api_key_here

# Mapbox Access Token
MAPBOX_API_KEY=your_mapbox_access_token_here

# Redis URL (for Sidekiq)
REDIS_URL=redis://localhost:6379/0
```

## How to Set Environment Variables

### Option 1: Using .env file (Recommended)
1. Create a `.env` file in your project root
2. Add your API keys to the file
3. The `.env` file is already in `.gitignore` and won't be committed

### Option 2: Using Rails credentials
```bash
rails credentials:edit
```

Add your API keys to the credentials file:
```yaml
openai_api_key: your_openai_api_key_here
youtube_api_key: your_youtube_api_key_here
mapbox_api_key: your_mapbox_access_token_here
```

Then access them in your code as:
```ruby
Rails.application.credentials.openai_api_key
```

### Option 3: System environment variables
```bash
export OPENAI_API_KEY=your_openai_api_key_here
export YOUTUBE_API_KEY=your_youtube_api_key_here
export MAPBOX_API_KEY=your_mapbox_access_token_here
```

## Security Best Practices

1. **Never hardcode API keys** in your source code
2. **Never commit API keys** to version control
3. **Use environment variables** for all sensitive data
4. **Rotate API keys** regularly
5. **Use different keys** for development and production
6. **Monitor API usage** to detect unauthorized access

## Getting API Keys

### OpenAI API Key
1. Go to https://platform.openai.com/
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key

### YouTube API Key
1. Go to https://console.developers.google.com/
2. Create a new project or select existing
3. Enable YouTube Data API v3
4. Create credentials (API Key)

### Mapbox Access Token
1. Go to https://account.mapbox.com/
2. Sign up or log in
3. Navigate to Access Tokens
4. Create a new token

## Testing Your Setup

Run the API connection test:
```bash
ruby test_api_connections.rb
```

This will verify that all your API keys are working correctly.
