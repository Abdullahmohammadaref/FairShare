import express from 'express'
import cors from 'cors';
import { createClient } from '@supabase/supabase-js'
import "dotenv/config";

const app = express()

app.use(cors());
app.use(express.json())

// Initializing supabase client to interact with the database
createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY)

app.listen(3000, () => {
    console.log('Server running on http://localhost:3000')
})



