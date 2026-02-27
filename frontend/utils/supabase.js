import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY

// Creating supabase client to get realtime updates from the database
export const supabase = createClient(supabaseUrl, supabaseKey)
