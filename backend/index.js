import express from 'express'
import cors from 'cors';
import { createClient } from '@supabase/supabase-js'
import "dotenv/config";

const app = express()

app.use(cors());
app.use(express.json())

// Initializing supabase client to interact with the database
createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY)

const port = process.env.PORT || 4025
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`)
})



