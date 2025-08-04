# 🔧 Wanderistan AI - API Setup Guide

## 📋 Current Status

Based on the API connection test, here's the current status:

| API | Status | Action Required |
|-----|--------|----------------|
| **Database** | ✅ Working | None |
| **Network** | ✅ Working | None |
| **OpenAI** | ❌ Not Configured | Add API Key |
| **YouTube** | ❌ Not Configured | Add API Key |
| **Mapbox** | ❌ Not Configured | Add API Key |

## 🚀 Setup Instructions

### 1. OpenAI API Setup

**Step 1: Get API Key**
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to "API Keys" section
4. Click "Create new secret key"
5. Copy the generated key

**Step 2: Configure in Rails**
```bash
# Edit config/local_env.yml
OPENAI_API_KEY: "sk-your-actual-openai-key-here"
```

### 2. YouTube Data API Setup

**Step 1: Get API Key**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable "YouTube Data API v3"
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy the generated key

**Step 2: Configure in Rails**
```bash
# Edit config/local_env.yml
YOUTUBE_API_KEY: "your-youtube-api-key-here"
```

### 3. Mapbox API Setup

**Step 1: Get Access Token**
1. Go to [Mapbox](https://account.mapbox.com/)
2. Sign up or log in
3. Navigate to "Access Tokens"
4. Copy your default public token or create a new one

**Step 2: Configure in Rails**
```bash
# Edit config/local_env.yml
MAPBOX_ACCESS_TOKEN: "pk.your-mapbox-token-here"
```

## 🔄 Update Configuration

After getting your API keys, update the `config/local_env.yml` file:

```yaml
# API Keys (replace with your actual keys)
OPENAI_API_KEY: "sk-your-actual-openai-key-here"
YOUTUBE_API_KEY: "your-youtube-api-key-here"
MAPBOX_ACCESS_TOKEN: "pk.your-mapbox-token-here"

# Redis (for Sidekiq)
REDIS_URL: "redis://localhost:6379/0"
```

## 🧪 Test Your Setup

After updating the API keys, run the test script:

```bash
ruby test_api_connections.rb
```

You should see:
```
✅ OPENAI_API_KEY: SET
✅ YOUTUBE_API_KEY: SET
✅ Mapbox: TOKEN SET
✅ OpenAI: WORKING
✅ YouTube: WORKING
🎉 ALL SYSTEMS OPERATIONAL!
```

## 💰 API Costs & Limits

| API | Free Tier | Cost |
|-----|-----------|------|
| **OpenAI** | $0.03/1K tokens | GPT-4: ~$0.03/1K tokens |
| **YouTube** | 10,000 units/day | Free tier usually sufficient |
| **Mapbox** | 50,000 map loads/month | Free tier usually sufficient |

## 🔒 Security Notes

1. **Never commit API keys** to version control
2. The `config/local_env.yml` file is already in `.gitignore`
3. For production, use environment variables or Rails credentials
4. Monitor API usage to avoid unexpected charges

## 🚨 Troubleshooting

### OpenAI Issues
- **Error**: "Invalid API key" → Check your key format (starts with `sk-`)
- **Error**: "Rate limit exceeded" → Wait and retry
- **Error**: "Insufficient credits" → Add billing information

### YouTube Issues
- **Error**: "API key not valid" → Check your key in Google Cloud Console
- **Error**: "Quota exceeded" → Wait for daily reset or upgrade quota
- **Error**: "API not enabled" → Enable YouTube Data API v3

### Mapbox Issues
- **Error**: "Invalid token" → Check your public token format
- **Error**: "Token expired" → Generate new token
- **Error**: "Usage limit exceeded" → Check your monthly usage

## 📱 Testing Features

Once APIs are configured, test these features:

1. **AI Trip Planner**: Go to `/planner` and try a prompt
2. **YouTube Videos**: Check place pages for embedded videos
3. **Interactive Map**: Visit `/explore/map` to see places on map

## 🎯 Next Steps

After setting up APIs:

1. **Test AI Planner**: Create a trip with AI
2. **Explore Places**: Browse and add places to trips
3. **Check Videos**: Verify YouTube integration works
4. **Test Map**: Ensure map markers display correctly

---

**Need Help?** Check the Rails logs for detailed error messages when API calls fail.
