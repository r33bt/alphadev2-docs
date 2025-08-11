# Supabase Integration Guide

**AlphaDev2 Development Environment**  
**Date:** 2025-01-11  
**Service:** Supabase (PostgreSQL Backend-as-a-Service)

## 🗄️ **What is Supabase?**

Supabase is an open-source Firebase alternative providing:
- PostgreSQL database with real-time subscriptions
- Authentication & user management
- Auto-generated APIs (REST & GraphQL)
- Storage for files and images
- Edge functions (serverless)
- Dashboard for database management

## 🔑 **Credentials You Need**

### **From Supabase Dashboard** (`https://app.supabase.com/project/YOUR_PROJECT/settings/api`)

1. **Project URL** - `https://your-project-ref.supabase.co`
2. **Anon (Public) Key** - Safe for client-side use
3. **Service Role Key** - Admin access, server-side only
4. **JWT Secret** - For token verification
5. **Database URL** - Direct PostgreSQL connection (optional)

### **Security Levels**
- 🟢 **Anon Key**: Safe in client-side code, respects RLS policies
- 🔴 **Service Key**: Full admin access, server-side ONLY
- 🟡 **Database URL**: Direct PostgreSQL, bypass Supabase features

## 🚀 **Setup Instructions**

### **1. Run Supabase Setup Script**
```powershell
cd "C:\Users\user\alphadev2"
powershell -ExecutionPolicy Bypass -File "scripts\setup-supabase.ps1"
```

This will:
- Securely collect your Supabase credentials
- Store them in encrypted files
- Create project templates
- Update global environment references

### **2. File Structure Created**
```
alphadev2/
├── secrets/
│   ├── credentials/
│   │   ├── supabase.url                # Project URL
│   │   ├── supabase.anon.key          # Public key
│   │   ├── supabase.service.key       # Admin key
│   │   └── supabase.database.url      # Direct DB URL
│   └── templates/
│       └── .env.supabase.template     # Project template
```

### **3. Environment Loading Patterns**

#### **Node.js/Next.js Project**
```javascript
// lib/supabase.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// For server-side admin operations
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY

export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey)
```

#### **React Project**
```javascript
// src/lib/supabase.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

#### **Python/FastAPI Project**
```python
# app/database.py
import os
from supabase import create_client, Client

url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_KEY")
supabase: Client = create_client(url, key)
```

## 📋 **Project-Specific Setup**

### **1. Copy Template to Project**
```powershell
# For a new Next.js project
copy "C:\Users\user\alphadev2\secrets\templates\.env.supabase.template" "C:\Users\user\alphadev2\projects\web\my-app\.env.local"
```

### **2. Load Credentials in Project**
```javascript
// config/loadCredentials.js
import fs from 'fs'
import path from 'path'

function loadCredentialFile(filename) {
  const credentialsPath = path.join(process.cwd(), '../../../secrets/credentials', filename)
  if (fs.existsSync(credentialsPath)) {
    return fs.readFileSync(credentialsPath, 'utf8').trim()
  }
  return null
}

export const supabaseConfig = {
  url: loadCredentialFile('supabase.url') || process.env.SUPABASE_URL,
  anonKey: loadCredentialFile('supabase.anon.key') || process.env.SUPABASE_ANON_KEY,
  serviceKey: loadCredentialFile('supabase.service.key') || process.env.SUPABASE_SERVICE_KEY,
}
```

### **3. Install Supabase Client**
```bash
# JavaScript/TypeScript
npm install @supabase/supabase-js

# Python
pip install supabase

# Flutter/Dart
flutter pub add supabase_flutter

# Swift
# Add to Package.swift: .package(url: "https://github.com/supabase/supabase-swift")
```

## 🔐 **Authentication Setup**

### **Basic Auth Configuration**
```javascript
// lib/auth.js
import { supabase } from './supabase'

// Sign up
export async function signUp(email, password) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })
  return { data, error }
}

// Sign in
export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  return { data, error }
}

// Sign out
export async function signOut() {
  const { error } = await supabase.auth.signOut()
  return { error }
}

// Get current user
export async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}
```

### **OAuth Providers (GitHub, Google, etc.)**
```javascript
// Sign in with GitHub
export async function signInWithGitHub() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'github',
    options: {
      redirectTo: `${window.location.origin}/auth/callback`
    }
  })
  return { data, error }
}
```

## 🗃️ **Database Operations**

### **Basic CRUD Operations**
```javascript
// lib/database.js
import { supabase } from './supabase'

// Insert data
export async function insertUser(userData) {
  const { data, error } = await supabase
    .from('users')
    .insert([userData])
    .select()
  
  return { data, error }
}

// Fetch data
export async function getUsers() {
  const { data, error } = await supabase
    .from('users')
    .select('*')
  
  return { data, error }
}

// Update data
export async function updateUser(userId, updates) {
  const { data, error } = await supabase
    .from('users')
    .update(updates)
    .eq('id', userId)
    .select()
  
  return { data, error }
}

// Delete data
export async function deleteUser(userId) {
  const { data, error } = await supabase
    .from('users')
    .delete()
    .eq('id', userId)
  
  return { data, error }
}
```

### **Real-time Subscriptions**
```javascript
// lib/realtime.js
import { supabase } from './supabase'

export function subscribeToUsers(callback) {
  const subscription = supabase
    .channel('users')
    .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'users' }, 
        callback
    )
    .subscribe()
  
  return subscription
}

// Usage in React component
useEffect(() => {
  const subscription = subscribeToUsers((payload) => {
    console.log('Change received!', payload)
    // Update your state here
  })
  
  return () => {
    subscription.unsubscribe()
  }
}, [])
```

## 📁 **Storage/File Upload**

### **File Upload Setup**
```javascript
// lib/storage.js
import { supabase } from './supabase'

export async function uploadFile(file, path) {
  const { data, error } = await supabase.storage
    .from('files') // Your bucket name
    .upload(path, file)
  
  return { data, error }
}

export async function downloadFile(path) {
  const { data, error } = await supabase.storage
    .from('files')
    .download(path)
  
  return { data, error }
}

export function getPublicUrl(path) {
  const { data } = supabase.storage
    .from('files')
    .getPublicUrl(path)
  
  return data.publicUrl
}
```

## 🔒 **Row Level Security (RLS)**

### **Enable RLS and Create Policies**
```sql
-- Enable RLS on your table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users can insert their own data
CREATE POLICY "Users can insert own data" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);
```

## 🧪 **Testing Setup**

### **Jest + Supabase Testing**
```javascript
// __tests__/setup.js
import { createClient } from '@supabase/supabase-js'

// Use test database
const supabaseUrl = process.env.SUPABASE_TEST_URL || process.env.SUPABASE_URL
const supabaseKey = process.env.SUPABASE_TEST_KEY || process.env.SUPABASE_SERVICE_KEY

export const testSupabase = createClient(supabaseUrl, supabaseKey)

// Clean up test data after tests
afterEach(async () => {
  // Clean up test data
  await testSupabase.from('test_users').delete().neq('id', 0)
})
```

## 🚀 **Deployment Configuration**

### **Vercel Environment Variables**
```bash
# Add to Vercel project settings
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
```

### **Environment-Specific Configuration**
```javascript
// config/supabase.js
const configs = {
  development: {
    url: process.env.SUPABASE_URL,
    anonKey: process.env.SUPABASE_ANON_KEY,
  },
  production: {
    url: process.env.SUPABASE_PROD_URL,
    anonKey: process.env.SUPABASE_PROD_ANON_KEY,
  }
}

const config = configs[process.env.NODE_ENV] || configs.development
export const supabase = createClient(config.url, config.anonKey)
```

## 📊 **Database Schema Management**

### **Using Supabase CLI**
```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Pull current schema
supabase db pull

# Generate TypeScript types
supabase gen types typescript --project-id your-project-ref > types/supabase.ts
```

### **Migration Workflow**
```bash
# Create migration
supabase migration new add_users_table

# Apply migrations
supabase db push

# Reset database (development)
supabase db reset
```

## 🔧 **Common Integration Patterns**

### **Next.js API Routes with Supabase**
```javascript
// pages/api/users.js
import { supabaseAdmin } from '../../lib/supabase-admin'

export default async function handler(req, res) {
  if (req.method === 'GET') {
    const { data, error } = await supabaseAdmin
      .from('users')
      .select('*')
    
    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json(data)
  }
  
  // Handle other methods...
}
```

### **React Query + Supabase**
```javascript
// hooks/useUsers.js
import { useQuery, useMutation, useQueryClient } from 'react-query'
import { supabase } from '../lib/supabase'

export function useUsers() {
  return useQuery('users', async () => {
    const { data, error } = await supabase.from('users').select('*')
    if (error) throw error
    return data
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()
  
  return useMutation(
    (userData) => supabase.from('users').insert([userData]).select(),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('users')
      }
    }
  )
}
```

## 📋 **Security Checklist**

### **Before Going Live:**
- [ ] Enable RLS on all tables
- [ ] Create appropriate security policies
- [ ] Test with different user roles
- [ ] Never expose Service Role Key in client code
- [ ] Set up proper CORS settings
- [ ] Configure email templates for auth
- [ ] Set up proper backup strategy
- [ ] Monitor usage and set up alerts

### **Development Best Practices:**
- [ ] Use separate projects for dev/staging/prod
- [ ] Keep Service Role Key in secure server environments only
- [ ] Use environment variables for all credentials
- [ ] Implement proper error handling
- [ ] Set up monitoring and logging
- [ ] Regular credential rotation

## 🆘 **Troubleshooting**

### **Common Issues:**
1. **"Invalid API key"** - Check if using correct environment variables
2. **RLS blocking queries** - Verify user authentication and policies
3. **CORS errors** - Configure allowed origins in Supabase dashboard
4. **Connection timeouts** - Check network and firewall settings

### **Debug Commands:**
```javascript
// Check current user
console.log(await supabase.auth.getUser())

// Test connection
console.log(await supabase.from('users').select('count'))

// Check RLS policies
console.log(await supabase.rpc('get_my_policies'))
```

---

**🔗 Useful Links:**
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Dashboard](https://app.supabase.com)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli)
- [Next.js + Supabase Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-nextjs)

**Last Updated:** 2025-01-11