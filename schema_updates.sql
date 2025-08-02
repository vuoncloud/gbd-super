-- Schema updates for config rollback priority implementation
-- Add fields to track config rollback timeouts and prevent WiFi override

ALTER TABLE devices 
ADD COLUMN IF NOT EXISTS config_update_pending BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS rollback_start_time TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS config_rollback_timeout INTEGER DEFAULT 300; -- 5 minutes in seconds

-- Add index for efficient queries on pending config updates
CREATE INDEX IF NOT EXISTS idx_devices_config_pending ON devices(config_update_pending) WHERE config_update_pending = TRUE;

-- Add index for rollback timing queries  
CREATE INDEX IF NOT EXISTS idx_devices_rollback_time ON devices(rollback_start_time) WHERE rollback_start_time IS NOT NULL;