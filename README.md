# Sleep Tracker API

A high-performance Rails API for tracking user sleep patterns and statistics, designed to handle large user bases and high data volume efficiently.

## Architecture Overview

This application follows a service-oriented architecture with careful attention to database performance and scalability. It implements various optimization strategies to handle millions of sleep records and thousands of concurrent users.

## Performance & Scalability Features

### 🚀 Database Optimization Strategies

#### 1. Strategic Indexing
- **Users Table**: Unique index on `name` for fast user lookups
- **Follows Table**: 
  - Composite unique index on `[user_id, followed_user_id]` to prevent duplicate follows
  - Index on `followed_user_id` for reverse relationship queries
- **Sleep Records Table**:
  - Composite index on `[user_id, aasm_state, duration]` for efficient filtering and sorting
  - Time-based index on `[user_id, created_at]` with DESC ordering for timeline queries
- **User Statistics Table**:
  - Unique index on `user_id` for one-to-one relationship enforcement
  - Index on `last_calculated_at` for batch processing and cleanup operations

#### 2. Selective Field Loading
All service classes use `.select()` to load only required fields, reducing memory usage and network overhead:

```ruby
# Only load essential fields for sleep records
.select(:id, :user_id, :aasm_state, :sleep_time, :wake_time, :duration)

# Statistics service loads only calculation-relevant fields
.select(:id, :user_id, :total_sleep_records, :total_awake_records, 
        :total_sleep_duration, :average_sleep_duration, :last_calculated_at)
```

#### 3. Efficient Pagination
- Uses Kaminari gem with `.without_count` for faster pagination on large datasets
- Custom logic to determine last page without expensive COUNT queries
- Configurable per-page limits with sensible defaults (10 items per page)

```ruby
# Optimized pagination without COUNT query
sleep_records = query.page(@page).per(@per_page).without_count
[sleep_records, sleep_records.last_page? || sleep_records.empty?]
```

#### 4. Background Job Processing
- **Asynchronous Statistics Calculation**: Uses Sidekiq for non-blocking statistics updates
- **Error Handling**: Comprehensive error logging and retry mechanisms
- **Transaction Safety**: Database operations wrapped in transactions for consistency

```ruby
# Statistics calculated asynchronously after sleep record changes
after_create :refresh_statistics
after_commit :refresh_statistics # On wake_up event

private def refresh_statistics
  CalculateUserStatisticsJob.perform_later(self)
end
```

#### 5. Optimized Queries
- **JOIN Optimization**: Strategic use of joins to fetch related data in single queries
- **State-based Filtering**: Leverages AASM state machine for efficient record filtering
- **Duration-based Sorting**: Pre-calculated duration field for fast ordering

```ruby
# Efficient followed users' sleep records query
SleepRecord
  .select(:id, :user_id, :aasm_state, :sleep_time, :wake_time, :duration)
  .joins(user: :follower_relationships)
  .where(follows: { user_id: @current_user.id }, aasm_state: :awake)
  .order(duration: :desc)
```

### 📊 Data Volume Management

#### Pre-calculated Statistics
- **User Statistics Table**: Maintains aggregated data to avoid expensive calculations
- **Incremental Updates**: Statistics updated incrementally rather than recalculated from scratch
- **Separate Tracking**: Distinguishes between total sleep records and completed (awake) records

#### State Machine Optimization
- **AASM Integration**: Uses state machine for efficient record state management
- **Targeted Queries**: Filters by state to reduce query result sets
- **Lock Protection**: Prevents race conditions during state transitions

### 🔧 Production Considerations

#### Database Configuration
- **PostgreSQL**: Uses PostgreSQL for better performance with large datasets
- **Connection Pooling**: Configured for high-concurrency scenarios
- **Index Maintenance**: Regular index analysis and optimization

#### Background Processing
- **Sidekiq**: Redis-backed job processing for scalability
- **Queue Management**: Separate queues for different job priorities
- **Monitoring**: Built-in error tracking and performance monitoring

#### Memory Optimization
- **Selective Loading**: Minimal memory footprint through field selection
- **Batch Processing**: Large datasets processed in batches
- **Connection Management**: Efficient database connection usage

## Installation & Setup

### Prerequisites
- Ruby 3.3.0
- PostgreSQL 13+
- Redis (for Sidekiq)

### Database Setup
```bash
bundle install
rails db:create
rails db:migrate
```

### Background Jobs
```bash
bundle exec sidekiq
```

### Testing
```bash
bundle exec rspec spec/services/
```

## Service Architecture

### Core Services
- `ClockInService`: Creates new sleep records
- `WakeUpService`: Transitions records to awake state with duration calculation
- `GetUserSleepRecordsService`: Paginated user sleep history
- `GetFollowedUsersSleepRecordsService`: Social feed of followed users' sleep data
- `CalculateUserStatisticsService`: Real-time statistics computation

### Job Processing
- `CalculateUserStatisticsJob`: Asynchronous statistics updates with error handling

### Database Models
- `User`: Core user management with follow relationships
- `Follow`: Many-to-many follow relationships with composite indexing
- `SleepRecord`: Time-tracked sleep sessions with state machine
- `UserStatistic`: Aggregated metrics with incremental updates

## Monitoring & Maintenance

### Performance Monitoring
- Database query performance through Rails logging
- Background job processing metrics via Sidekiq Web UI
- Index usage analysis through PostgreSQL statistics

### Maintenance Tasks
- Regular index analysis and rebuilding
- Archived data cleanup for old sleep records
- Statistics recalculation for data consistency

## Development Guidelines

### Adding New Features
1. **Always use selective field loading** with `.select()`
2. **Add appropriate database indexes** for new query patterns
3. **Consider pagination** for any list endpoints
4. **Use background jobs** for expensive operations
5. **Test with realistic data volumes** (thousands of records)

This architecture ensures the application can scale efficiently while maintaining fast response times and data consistency across a growing user base.