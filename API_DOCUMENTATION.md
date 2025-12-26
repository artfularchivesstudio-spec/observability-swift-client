# 🔌 API Documentation

## Monitoring Service API

### Base URL
- **HTTP**: `https://api-router.cloud/monitoring/custom/`
- **WebSocket**: `wss://api-router.cloud/monitoring/custom/`

### Authentication

All requests require an API key provided either:
- As query parameter: `?api_key=your-api-key`
- As header: `X-API-Key: your-api-key`

### Endpoints

#### GET /api/logs/stream

Stream logs via Server-Sent Events (SSE).

**Query Parameters:**
- `sources` (optional): Comma-separated list of sources (`strapi`, `supabase`, `docker`, `all`)

**Response Format:**
```
data: {"id":"...","timestamp":"...","source":"strapi","level":"error","message":"..."}

data: {"id":"...","timestamp":"...","source":"supabase","level":"info","message":"..."}
```

**Example:**
```bash
curl -N "https://api-router.cloud/monitoring/custom/api/logs/stream?sources=all&api_key=your-key"
```

#### GET /api/pm2/status/{serviceName}

Get PM2 process status for a service.

**Path Parameters:**
- `serviceName`: PM2 process name (`strapi`, `website`, `python-api`, `monitoring`)

**Response:**
```json
{
  "name": "strapi",
  "status": "online",
  "cpu": 15.5,
  "memory": 125.3,
  "restarts": 2,
  "uptime": 86400,
  "pid": 12345
}
```

#### GET /api/logs/historical

Get historical logs.

**Query Parameters:**
- `source` (optional): Filter by source
- `level` (optional): Filter by log level
- `limit` (optional): Number of logs to return (default: 100)

### WebSocket Events

#### Connection

Connect to WebSocket endpoint:
```
wss://api-router.cloud/monitoring/custom/?api_key=your-key
```

#### Message Types

**Metrics:**
```json
{
  "type": "metrics",
  "data": {
    "cpu": 25.5,
    "memory": 150.2,
    "service": "strapi"
  }
}
```

**Health Update:**
```json
{
  "type": "health",
  "data": {
    "serviceId": "...",
    "status": "operational",
    "responseTime": 0.05
  }
}
```

**Alert:**
```json
{
  "type": "alert",
  "data": {
    "id": "...",
    "title": "Service Down",
    "severity": "critical",
    "serviceName": "Strapi CMS"
  }
}
```

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message"
  }
}
```

### Error Codes

- `UNAUTHORIZED`: Invalid or missing API key
- `SERVICE_NOT_FOUND`: Requested service doesn't exist
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `INTERNAL_ERROR`: Server error

## Rate Limits

- **API Requests**: 100 requests per minute per API key
- **WebSocket Connections**: 5 concurrent connections per API key
- **SSE Streams**: 2 concurrent streams per API key

## Best Practices

1. **Use WebSocket for real-time updates**: More efficient than polling
2. **Implement reconnection logic**: Network issues are common
3. **Cache health data**: Don't fetch on every screen update
4. **Batch log requests**: Use historical endpoint for bulk data
5. **Handle errors gracefully**: Show user-friendly error messages

---

*For more information, see the main [DOCUMENTATION.md](DOCUMENTATION.md)*

