#  FairShare

## Overview
FairShare is a software solution designed to help friends easily split bills 
between each other in a fair and easy manner. It provides Realtime collaborative
interface, data storage, and transfer plan generator to settle debt with the least
possible transfers and reducing overall transaction fees.

## Requirements
- Node.js: 22.12.0 (or newer).

## Setup
1. Open terminal and run "git clone https://github.com/Abdullahmohammadaref/FairShare" inside preferred directory.
2. Run "`cd FairShare`"
3. Run "`cd frontend`"
4. Run "`npm install`"
5. Run "`npm run dev`" in development environment

Note: Run"`npm run build`" to build static files of the frontend application. Those files are in a dist folder and can be hosted on a server


## How to clone supabase schema
1. Create an account on [Supabase](https://supabase.com/) and then create a new project.
2. Install [Supabase CLI](https://supabase.com/docs/guides/local-development)
3. Open terminal in the "database" directory that is inside the root project directory.
4. Run "`supabase login`" and follow instructions.
5. Run "`supabase link`" and choose newly created supabase project.
6. Run "`supabase db push`" to push database schema into cloud database
7. Go to ".env" file inside "frontend" directory and replace "VITE_SUPABASE_URL" and "VITE_SUPABASE_KEY" with those of the new cloud database project.

## How to run database locally
1. Install docker
2. Open terminal inside the "database" directory
3. Run "`supabase start`"
4. User url shown in terminal to access supabase interface locally
5. Go to ".env" file inside "frontend" directory and replace "VITE_SUPABASE_URL" and "VITE_SUPABASE_KEY" with those of the new local database project.
Note: server might not start if there is an issue with docker.

## Running unit tests:
Head into the "frontend" directory and run "`npx vitest`" in terminal.










