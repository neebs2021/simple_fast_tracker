-- Run this in your Supabase SQL Editor to fix the missing column error
ALTER TABLE fasting_sessions ADD COLUMN updated_at timestamp with time zone;
