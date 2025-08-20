# Blog CMS Metadata System Design

## Overview

This document outlines a proper Content Management System (CMS) approach for handling blog post metadata in Next.js, ensuring consistent date handling, author tracking, and content updates.

## Current Issues

1. **Inconsistent Date Sources**: Homepage shows hardcoded `publishedDate` while individual posts use `dateTime` attributes
2. **No Update Tracking**: No system to track when articles are modified
3. **Missing Author System**: No consistent author attribution across posts
4. **Manual Metadata Management**: All metadata is hardcoded in individual page files

## Proposed Solution: Centralized Metadata System

### 1. Post Metadata Schema

Create a standardized metadata interface for all blog posts:

```typescript
interface BlogPostMetadata {
  slug: string;
  title: string;
  excerpt: string;
  content: string;
  author: {
    name: string;
    bio?: string;
    avatar?: string;
  };
  dates: {
    published: string; // ISO 8601 format
    modified?: string; // ISO 8601 format
    created?: string;  // ISO 8601 format
  };
  seo: {
    metaTitle?: string;
    metaDescription: string;
    keywords?: string[];
  };
  categories: string[];
  tags?: string[];
  status: 'draft' | 'published' | 'archived';
  featured?: boolean;
}
```

### 2. Centralized Data Store

#### Option A: JSON-based Metadata Store
- **File**: `data/blog-metadata.json`
- **Benefits**: Simple, version-controllable, no database needed
- **Structure**: Array of `BlogPostMetadata` objects

#### Option B: Markdown with Frontmatter
- **Structure**: Individual `.md` files with YAML frontmatter
- **Benefits**: Content and metadata together, easy editing
- **Tools**: Use `gray-matter` library to parse

#### Option C: TypeScript Configuration
- **File**: `data/blog-posts.ts`
- **Benefits**: Type safety, IntelliSense support
- **Export**: Typed array of post metadata

### 3. Implementation Architecture

#### Core Components

1. **Metadata Manager** (`lib/metadata.ts`)
   ```typescript
   export class BlogMetadataManager {
     static getAllPosts(): BlogPostMetadata[]
     static getPostBySlug(slug: string): BlogPostMetadata | null
     static getRecentPosts(limit: number): BlogPostMetadata[]
     static updatePostDates(slug: string, modified: string): void
   }
   ```

2. **Date Utilities** (`lib/dates.ts`)
   ```typescript
   export function formatDisplayDate(isoDate: string): string
   export function getRelativeTime(isoDate: string): string
   export function isDateValid(isoDate: string): boolean
   ```

3. **Content Synchronizer** (`scripts/sync-metadata.js`)
   - Extracts dates from existing HTML content
   - Updates centralized metadata store
   - Validates data consistency

#### Page Generation Pattern

```typescript
// app/blog/[slug]/page.tsx
import { BlogMetadataManager } from '@/lib/metadata'

export async function generateMetadata({ params }) {
  const post = BlogMetadataManager.getPostBySlug(params.slug)
  return {
    title: post.seo.metaTitle || post.title,
    description: post.seo.metaDescription,
    // ... other meta tags
  }
}

export default function BlogPost({ params }) {
  const post = BlogMetadataManager.getPostBySlug(params.slug)
  return (
    <article>
      <time dateTime={post.dates.published}>
        {formatDisplayDate(post.dates.published)}
      </time>
      {post.dates.modified && (
        <time dateTime={post.dates.modified}>
          Updated: {formatDisplayDate(post.dates.modified)}
        </time>
      )}
      <div>By {post.author.name}</div>
      {/* Content */}
    </article>
  )
}
```

### 4. Update Workflow

#### Content Update Process
1. **Detect Changes**: Git hooks or build-time comparison
2. **Update Metadata**: Automatically set `dates.modified`
3. **Validate Content**: Ensure metadata consistency
4. **Rebuild Pages**: Trigger static regeneration

#### Author Attribution System
```typescript
// data/authors.ts
export const AUTHORS = {
  'john-doe': {
    name: 'John Doe',
    bio: 'Senior UX Designer with 10 years experience',
    avatar: '/images/authors/john-doe.jpg'
  }
} as const

// In blog posts
author: AUTHORS['john-doe']
```

### 5. Migration Strategy

#### Phase 1: Data Extraction
1. Run script to extract all existing dates from HTML content
2. Create initial `blog-metadata.json` with current data
3. Add author information for all posts

#### Phase 2: Component Updates
1. Update all blog components to use centralized metadata
2. Remove hardcoded dates and metadata from page files
3. Implement consistent date formatting

#### Phase 3: Enhancement
1. Add modified date tracking system
2. Implement author pages and attribution
3. Add category and tag functionality

### 6. Benefits of This Approach

1. **Single Source of Truth**: All metadata in one place
2. **Type Safety**: TypeScript interfaces prevent errors
3. **Consistency**: Unified date formatting and display
4. **Maintainability**: Easy to update and extend
5. **SEO Optimization**: Consistent structured data
6. **Performance**: No runtime date parsing needed

### 7. File Structure

```
lib/
├── metadata.ts          # Metadata manager class
├── dates.ts            # Date utility functions
└── authors.ts          # Author definitions

data/
├── blog-metadata.json  # Centralized post metadata
└── authors.json       # Author information

scripts/
├── extract-metadata.js # Extract existing dates
├── sync-metadata.js   # Sync and validate data
└── update-dates.js    # Bulk date updates

components/
├── BlogPost.tsx       # Individual post component
├── BlogCard.tsx       # Post preview card
└── AuthorInfo.tsx     # Author attribution
```

This system transforms the blog from hardcoded metadata to a proper CMS-like architecture while maintaining Next.js static generation benefits.