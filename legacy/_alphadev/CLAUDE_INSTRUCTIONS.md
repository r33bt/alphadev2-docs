# Claude Development Instructions - IGCSE Quiz Project

## Quick Reference for Future Sessions

### Project Context
- **Location**: `C:\Users\User\documents\alphadev\igcse-quiz-v2\`
- **Status**: Phase 1 (Authentication) - 95% Complete
- **Development Server**: `npm run dev` → http://localhost:3000
- **Critical Issue**: Production build fails due to React Context SSR issues

### Key Documentation Files
- `IGCSE_QUIZ_PROJECT_LOG.md` - Complete project history and lessons learned
- `DEVELOPMENT_STATUS.md` - Current status and next steps
- `docs/TECHNICAL_SPECIFICATION.md` - Complete system architecture
- `docs/IMPLEMENTATION_PLAN.md` - 5-phase development roadmap
- `docs/DATABASE_DESIGN.md` - PostgreSQL schema ready for deployment

### Current Working Setup

#### Development Commands
```bash
cd "C:\Users\User\documents\alphadev\igcse-quiz-v2"
npm run dev          # Start development server (WORKS)
npm run build        # Build for production (FAILS - SSR issue)
npm test            # Run Jest tests
npm run type-check  # TypeScript validation
```

#### Environment Configuration
```bash
# .env.local (currently using placeholders)
NEXT_PUBLIC_SUPABASE_URL=https://placeholder.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=placeholder-key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Critical Technical Issues to Remember

#### 1. React Context + Next.js App Router SSR Issue ⚠️
**Problem**: `TypeError: Cannot read properties of null (reading 'useContext')`
**Cause**: AuthContext being accessed during static generation
**Current Status**: Blocks production deployment
**Solutions Attempted**: Dynamic exports, custom error pages, Next config changes
**Working Pattern**:
```typescript
const AuthContext = createContext<AuthContextType | null>(null)
const isConfigured = typeof window !== 'undefined' && 
  process.env.NEXT_PUBLIC_SUPABASE_URL !== 'https://placeholder.supabase.co'
```

#### 2. Framework Version Compatibility
**React**: Must use 18.x (not 19.x) for testing library compatibility
**Tailwind**: Use 3.4.17 (not 4.x) for Next.js 15 compatibility
**Working Dependencies**:
```json
{
  "react": "^18.3.1",
  "react-dom": "^18.3.1", 
  "tailwindcss": "^3.4.17",
  "next": "^15.4.6"
}
```

### Immediate Next Steps (Phase 1 Completion)

#### 1. Create Supabase Project (30 minutes)
- Go to https://supabase.com
- Create new project: "igcse-quiz-v2"
- Copy URL and keys to .env.local
- Test connection with `npm run dev`

#### 2. Deploy Database Schema (45 minutes)
- Open Supabase SQL Editor
- Execute complete schema from `docs/DATABASE_DESIGN.md`
- Verify tables created: users, profiles, topics, questions, quiz_attempts
- Test RLS policies and triggers

#### 3. Test End-to-End Authentication (30 minutes)
- Register new user → verify profile creation
- Sign in/out → verify session handling
- Check XP system → verify triggers working
- Validate all dashboard data

### Code Architecture Patterns That Work

#### Authentication Context Structure
```typescript
// src/lib/auth/AuthContext.tsx
export function AuthProvider({ children }: AuthProviderProps) {
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Safe client-side initialization
  useEffect(() => {
    if (typeof window !== 'undefined' && isConfigured) {
      initializeAuth()
    }
  }, [])

  // Auth state change listener
  useEffect(() => {
    if (!isConfigured) return
    const { data: { subscription } } = supabase.auth.onAuthStateChange(...)
    return () => subscription.unsubscribe()
  }, [])
}
```

#### Component Pattern for Pages
```typescript
// src/app/page.tsx
export default function Home() {
  const { user, loading } = useAuth()
  
  if (loading) return <LoadingState />
  if (!user) return <LoginRedirect />
  return <DashboardContent />
}

export const dynamic = 'force-dynamic' // Prevent static generation
```

### Project File Structure
```
igcse-quiz-v2/
├── docs/                    # Complete specifications
├── src/
│   ├── lib/
│   │   ├── auth/           # Authentication logic
│   │   ├── types.ts        # TypeScript interfaces
│   │   └── supabase.ts     # Database client
│   ├── app/
│   │   ├── layout.tsx      # Root layout with AuthProvider
│   │   ├── page.tsx        # Dashboard (requires auth)
│   │   ├── login/          # Authentication pages
│   │   ├── not-found.tsx   # Custom 404
│   │   └── global-error.tsx # Error boundary
│   └── components/         # Reusable UI components
├── package.json            # Verified working dependencies
└── *.config.js            # Next.js, Tailwind, Jest configs
```

### Development Workflow

#### For Continuing Development
1. **Always check development server first**: `npm run dev`
2. **Read current status**: Review `DEVELOPMENT_STATUS.md`
3. **Check todo list**: Use existing TodoWrite system
4. **Test incrementally**: Don't build large features without testing
5. **Document issues immediately**: Update project logs

#### For Troubleshooting
1. **Check console errors**: Browser devtools for client-side issues
2. **Review server logs**: Terminal output for server-side issues  
3. **Verify environment**: Ensure .env.local values are correct
4. **Test with placeholders**: Use fake data to isolate issues
5. **Reference working patterns**: Follow established code patterns

### Common Commands Reference
```bash
# Development
npm run dev                 # Start dev server
npm run build              # Production build (currently fails)
npm run type-check         # TypeScript validation
npm test                   # Run tests

# Project Navigation  
cd "C:\Users\User\documents\alphadev\igcse-quiz-v2"
code .                     # Open in VS Code

# Git (if initialized)
git add .
git commit -m "Phase 1: Authentication foundation complete"
```

### Quality Checklist for Each Feature
- [ ] TypeScript types defined
- [ ] Error handling implemented  
- [ ] Loading states added
- [ ] Mobile responsive design
- [ ] Development server tested
- [ ] User feedback provided
- [ ] Documentation updated

### Emergency Rollback Information
If major issues occur, the working state is:
- **Commit**: All files as of August 10, 2025
- **Working Features**: Authentication system in development
- **Known Issues**: Production build fails, placeholder Supabase
- **Recovery**: Use `npm run dev` and focus on development-only testing

---

**Remember**: The authentication foundation is solid. Focus on database setup to complete Phase 1, then address the SSR build issues before moving to Phase 2 (Quiz Engine).