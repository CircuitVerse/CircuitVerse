# CircuitVerse Community Features

This document describes the new community features added to CircuitVerse, including the community dashboard, leaderboard, and releases management.

## Features Overview

### 1. Community Dashboard
- **Location**: `/community`
- **Purpose**: Provides an overview of community statistics and recent activity
- **Features**:
  - Community statistics (users, projects, contributions)
  - Recent projects showcase
  - Top contributors preview
  - Navigation to full leaderboard

### 2. Community Leaderboard
- **Location**: `/community/leaderboard`
- **Purpose**: Displays ranked contributors based on contribution points
- **Features**:
  - Time period filtering (Weekly, Monthly, Yearly, All Time)
  - Contribution points breakdown
  - User rank tracking
  - Points explanation tooltip

### 3. Releases Management
- **API Endpoint**: `/api/v1/releases`
- **Purpose**: Provides release information for CircuitVerse and Vue Simulator
- **Features**:
  - Automated release fetching from GitHub
  - Combined releases data
  - Individual repository releases
  - Caching for performance

## Contribution Points System

### Points Calculation
- **PR merged**: +5 points
- **PR opened**: +2 points
- **Issue opened**: +1 point

### Time Periods
- **Weekly**: Contributions from the last 7 days
- **Monthly**: Contributions from the last 30 days
- **Yearly**: Contributions from the last 365 days
- **All Time**: All contributions since user joined

## API Endpoints

### Releases API

#### Get All Releases
```http
GET /api/v1/releases
```

Response:
```json
{
  "circuitverse": [...],
  "vue_simulator": [...],
  "last_updated": "2024-02-12T01:00:00Z",
  "total_releases": 42
}
```

#### Get CircuitVerse Releases Only
```http
GET /api/v1/releases/circuitverse
```

#### Get Vue Simulator Releases Only
```http
GET /api/v1/releases/vue-simulator
```

## Database Schema

### Pull Requests Table
```sql
CREATE TABLE pull_requests (
  id BIGINT PRIMARY KEY,
  author_id BIGINT NOT NULL,
  project_id BIGINT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  state VARCHAR(255) NOT NULL DEFAULT 'open',
  github_url VARCHAR(255),
  github_id BIGINT UNIQUE,
  merged_at TIMESTAMP,
  closed_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (project_id) REFERENCES projects(id)
);
```

### Issues Table
```sql
CREATE TABLE issues (
  id BIGINT PRIMARY KEY,
  author_id BIGINT NOT NULL,
  project_id BIGINT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  state VARCHAR(255) NOT NULL DEFAULT 'open',
  github_url VARCHAR(255),
  github_id BIGINT UNIQUE,
  closed_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (project_id) REFERENCES projects(id)
);
```

## CI/CD Workflow

### Generate Releases Data
- **File**: `.github/workflows/generate-releases.yml`
- **Schedule**: Every hour
- **Triggers**: 
  - Schedule (hourly)
  - Manual dispatch
  - Push to master branch

### Workflow Steps
1. Checkout repository
2. Setup Node.js
3. Create public directory
4. Fetch CircuitVerse releases
5. Fetch Vue Simulator releases
6. Generate combined releases data
7. Generate latest version files
8. Upload artifacts
9. Deploy to GitHub Pages

## Frontend Integration

### JavaScript Requirements
The leaderboard page requires Bootstrap 5 for tooltips and responsive design:

```javascript
// Initialize tooltips
document.addEventListener('DOMContentLoaded', function() {
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl, {
      html: true,
      placement: 'top'
    })
  });
});
```

### CSS Customization
The community features include custom CSS for:
- Gradient backgrounds
- Card hover effects
- Rank badges
- Points breakdown display
- Responsive design

## Testing

### Controller Tests
- `spec/controllers/community_controller_spec.rb`
- Tests for dashboard and leaderboard functionality

### API Tests
- `spec/requests/api/v1/releases_spec.rb`
- Tests for releases API endpoints

### Model Tests
- Tests for PullRequest and Issue models
- Contribution points calculation
- Scopes and methods

## Deployment

### Database Migrations
Run the following migrations to set up the database:

```bash
rails db:migrate
```

### Assets Precompilation
Precompile assets for production:

```bash
rails assets:precompile
```

### Environment Variables
Set the following environment variables:

```bash
GITHUB_TOKEN=your_github_token
```

## Performance Considerations

### Caching
- Releases data is cached for 1 hour
- Database queries are optimized with proper indexes
- Leaderboard calculations use efficient SQL queries

### Database Indexes
- `pull_requests.github_id` (unique)
- `pull_requests.state`
- `pull_requests.created_at`
- `pull_requests.author_id`
- `issues.github_id` (unique)
- `issues.state`
- `issues.created_at`
- `issues.author_id`

## Security

### Authentication
- Community features require user authentication
- API endpoints are publicly accessible for releases data
- Proper authorization checks in controllers

### Data Validation
- Input validation for all user inputs
- SQL injection prevention with parameterized queries
- XSS prevention with proper output escaping

## Future Enhancements

### Planned Features
1. **Achievement System**: Badges and milestones for contributors
2. **Contribution Graph**: GitHub-style contribution visualization
3. **Team Leaderboards**: Organization-based competitions
4. **Integration with GitHub**: Automatic sync of contributions
5. **Notification System**: Alerts for leaderboard changes

### API v2
- GraphQL support for complex queries
- Real-time updates with WebSockets
- Enhanced filtering and sorting options

## Support

For issues or questions about the community features:
1. Check the existing issues on GitHub
2. Create a new issue with detailed description
3. Tag the issue with `community` label

## Contributing

To contribute to the community features:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

These features are licensed under the same terms as the CircuitVerse project.
