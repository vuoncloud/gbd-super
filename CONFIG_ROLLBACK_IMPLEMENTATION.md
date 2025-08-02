# Config Rollback Priority Implementation

## Overview
This implementation addresses the critical issue where WiFi fail-safe logic can override the configuration rollback mechanism. The solution ensures that config rollback always takes priority over WiFi fail-safe mechanisms.

## Key Changes Made

### 1. Database Schema Updates
- Added `config_update_pending` BOOLEAN column to track pending config updates
- Added `rollback_start_time` TIMESTAMP column to track when rollback timer started
- Added `config_rollback_timeout` INTEGER column for customizable rollback timeouts (default: 300s)
- Added database indexes for efficient queries on config rollback status

### 2. Configuration Constants
- `ROLLBACK_TIMEOUT`: 300 seconds (5 minutes) - configurable via environment variable
- `WIFI_REBOOT_TIMEOUT`: 1800 seconds (30 minutes) - configurable via environment variable
- Config rollback timeout is intentionally shorter than WiFi reboot timeout

### 3. Core Functions Added

#### `check_config_rollback_timeouts()`
- Monitors devices with pending config updates
- Automatically triggers rollback when timeout is exceeded
- Sends MQTT rollback commands to devices
- Resets config update pending status after rollback

#### `should_prevent_wifi_reboot(mac_address)`
- Checks if a device has pending config rollback
- Returns True if config rollback should prevent WiFi reboot
- Ensures config rollback takes priority over WiFi fail-safe

#### `start_config_rollback_monitor()`
- Starts background thread to monitor rollback timeouts
- Runs every 30 seconds to check for timeout violations
- Resilient to errors with exponential backoff

### 4. API Endpoints Enhanced

#### `/api/device/<mac_address>/config` (POST)
- **Modified**: Now sets `config_update_pending = TRUE` and `rollback_start_time`
- Initializes rollback timer when config update is made
- Returns rollback timeout information in response

#### `/api/device/<mac_address>/config/commit` (POST)
- **New**: Commits configuration changes and clears rollback timer
- Sets `config_update_pending = FALSE` and clears `rollback_start_time`
- Prevents unnecessary rollbacks for successfully applied configs

#### `/api/device/<mac_address>/config/status` (GET)  
- **New**: Returns current config rollback status
- Shows elapsed time, remaining time, and rollback status
- Useful for monitoring and debugging config update state

#### `/api/device/<mac_address>/reboot` (POST)
- **Modified**: Now checks for config rollback priority before allowing reboot
- Returns 409 Conflict if config rollback is pending
- Includes remaining rollback time in error response

### 5. Priority Logic Implementation

The implementation ensures the following priority order:
1. **Config Rollback** (5 minutes timeout) - HIGHEST PRIORITY
2. **WiFi Fail-safe** (30 minutes timeout) - Lower priority

### 6. Background Monitoring

- Config rollback monitor starts automatically with the application
- Runs in daemon thread to avoid blocking application shutdown
- Checks every 30 seconds for devices needing rollback
- Sends proper MQTT commands for device rollback

## Expected Behavior

### Normal Config Update Flow
1. Admin updates device config via API
2. `config_update_pending` set to TRUE, rollback timer starts
3. Device receives config and applies changes
4. Device sends commit confirmation (optional)
5. Admin calls commit endpoint OR timeout occurs
6. If timeout: device automatically rolls back config and reboots
7. If commit: rollback timer cleared, new config persists

### WiFi Fail-safe Interaction
1. Device loses WiFi connectivity
2. System checks if config rollback is pending
3. If config rollback pending and within timeout: WiFi reboot prevented
4. If no config pending OR rollback timeout exceeded: normal WiFi fail-safe applies

### Error Handling
- Database connection failures are logged and handled gracefully
- MQTT communication errors don't prevent rollback status updates
- Background monitor continues running even after individual errors
- All operations include proper transaction rollback on failure

## Testing Validation

The implementation includes comprehensive test validation:
- ✅ Config rollback priority logic
- ✅ Timeout calculations and comparisons
- ✅ MQTT command structure
- ✅ Configuration update flow
- ✅ Error handling and edge cases

## Files Modified

1. **gbd_multi_super_enhanced.py**: Main application logic
2. **schema_updates.sql**: Database schema changes
3. **test_config_rollback.py**: Test validation script

## Environment Variables

```bash
CONFIG_ROLLBACK_TIMEOUT=300  # 5 minutes (default)
WIFI_REBOOT_TIMEOUT=1800     # 30 minutes (default)
```

## Database Indexes Added

```sql
-- Efficient queries for pending config updates
CREATE INDEX idx_devices_config_pending ON devices(config_update_pending) 
WHERE config_update_pending = TRUE;

-- Efficient queries for rollback timing
CREATE INDEX idx_devices_rollback_time ON devices(rollback_start_time) 
WHERE rollback_start_time IS NOT NULL;
```

This implementation ensures config rollback always takes priority over WiFi fail-safe mechanisms while maintaining system reliability and providing proper monitoring capabilities.