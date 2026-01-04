-- DANGER: This script will DELETE all existing data in these tables.
-- Run this in your Supabase SQL Editor to reset the schema.

-- 1. Drop existing tables
DROP TABLE IF EXISTS fasting_sessions;
DROP TABLE IF EXISTS profiles;

-- 2. Create 'profiles' table
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  avatar_url text
);

alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- 3. Create 'fasting_sessions' table
create table fasting_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  
  -- Encrypted columns (Base64 encoded IV + CipherText)
  encrypted_start_time text, 
  encrypted_end_time text,
  encrypted_duration text,
  encrypted_note text,
  
  -- The user requested updated_at be encrypted too.
  -- Change type to text to store the string.
  updated_at text,
  
  -- Metadata
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table fasting_sessions enable row level security;

create policy "Individuals can view their own fasting sessions." on fasting_sessions
  for select using (auth.uid() = user_id);

create policy "Individuals can create their own fasting sessions." on fasting_sessions
  for insert with check (auth.uid() = user_id);

create policy "Individuals can update their own fasting sessions." on fasting_sessions
  for update using (auth.uid() = user_id);

create policy "Individuals can delete their own fasting sessions." on fasting_sessions
  for delete using (auth.uid() = user_id);
