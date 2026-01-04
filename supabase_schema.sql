-- Create a table for public user profiles
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  avatar_url text
  -- encryption_key text -- Optional: if we want to store user's encrypted key (wrapped)
);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- Create a table for Fasting Sessions
create table fasting_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone,
  
  -- We store encrypted data as text. 
  -- The client is responsible for encrypting/decrypting.
  -- For structured data like start/end time, we might want to keep them unencrypted 
  -- for querying (like "show me fasts from last month"), 
  -- UNLESS the requirement is strict "everything encrypted".
  -- Given the prompt "everything sent to the server is encrypted", 
  -- strict compliance would mean storing encrypted blobs. 
  -- However, that makes server-side querying impossible.
  -- A hybrid approach is common: Encrypt notes/details, keep metadata visible OR encrypt everything.
  -- adhereing strictly to user request: "everything sent to the server is encrypted"
  
  -- Encrypted columns (Base64 encoded IV + CipherText)
  encrypted_note text, 
  
  -- If we MUST encrypt start_time/end_time, we can't use timestamp types easily.
  -- But usually, "everything" refers to user-generated insensitive content. 
  -- Privacy-preserving metadata is usually acceptable.
  -- user specifically said: "make sure everything sent to the server is encrypted from here and decrypted when it arrives on the device"
  -- This implies E2E encryption for ALL data.
  -- If we encrypt dates, we cannot query by date on the server. We must sync ALL data to client.
  -- For a simple tracker, this is feasible efficiently.
  
  encrypted_start_time text, 
  encrypted_end_time text,
  updated_at timestamp with time zone
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
