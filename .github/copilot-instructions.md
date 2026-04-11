# GitHub Copilot Instructions for pedropcamellon.github.io

## Overview

Static portfolio/blog site built with Jekyll. Uses custom CSS (main.css, pages.css) with GitHub-style markdown rendering. Deployed via GitHub Pages with automatic Jekyll builds.

**Structure:**

- `index.md` - Home page (hero, about, contact)
- `blog.html` - Auto-generated article list (Jekyll Liquid)
- `blog/*.md` - Individual articles (Jekyll converts to HTML)
- `projects.html` - Project showcase with GitHub links
- `assets/img/articles/` - Article thumbnails
- `_layouts/default.html` - Jekyll template for blog posts
- `assets/css/main.css` - Base styles (navigation, typography, tags, footer)
- `assets/css/pages.css` - Component styles (blog cards, hero, responsive)

## Rules

0. **Adding Blog Posts:**

   - Drop `.md` file in `/blog/` with frontmatter:
     ```yaml
     ---
     layout: default
     title: "Article Title"
     date: YYYY-MM-DD
     tags: ["tag1", "tag2"]
     image: "article-slug.webp" # optional
     is_new: true # optional, for NEW badge
     excerpt: "Short description for blog list card" # optional
     ---
     ```
   - Jekyll auto-adds to `/blog/` list on push
   - Articles render directly on site at `/blog/[filename].html`
   - See `BLOG_IMPORT_GUIDE.md` for Notion import workflow (legacy)

1. **CSS Styling:**

   - Custom CSS in `/assets/css/main.css` and `/assets/css/pages.css`
   - GitHub-style markdown rendering
   - Responsive design with `min(1200px, 90vw)` max-width
   - No Bootstrap or Tailwind (removed for cleaner codebase)

2. **Blog Cards (in blog.html):**

   - Auto-generated via Jekyll Liquid
   - Shows: thumbnail, title, NEW badge (if `is_new: true`), excerpt, tags
   - Links to `/blog/[filename].html`
   - Sorted by date (newest first)

3. **Navigation Active State:**

   - Add `link-secondary` class to current page's nav link

4. **NEW Badge:**

   - Add to recent articles (remove after 2-3 weeks)
   - Use Bootstrap `badge` class with custom color

5. **Image Sizing:**

   - Article images: `md:max-w-52`
   - Profile image: `rounded-full`

6. **Analytics:**

   - Microsoft Clarity (`kykpoeffvx`) in all `<head>` sections

7. **Deployment:**
EW Badge:**

   - Set `is_new: true` in frontmatter for recent articles
   - Template automatically displays badge
   - Remove field after 2-3 weeks

4. **Tags:**

   - Define in frontmatter: `tags: ["python", "ai", "aws"]`
   - Displayed below title in articles and in blog cards
   - Styled as pill badges (`.tag` class)

5. **Images:**

   - Store in `/assets/img/articles/` with descriptive names
   - Naming: `{article-slug}-{description}.{ext}`
   - Blog cards: 208px × 150px thumbnails
   - Use gradient placeholder if image missing

6. **Analytics:**

   - Microsoft Clarity (`kykpoeffvx`) in all `<head>` sections

7. **Deployment:**

   - Edit files → commit → push to `main` → GitHub Pages auto-builds
   - Test locally: `bundle exec jekyll serve` or Docker
   - Jekyll builds to `_site/` (git ignored)

8. **Post Ordering:**
   - Controlled by `date: YYYY-MM-DD` in frontmatter
   - Blog list sorts by date, newest first