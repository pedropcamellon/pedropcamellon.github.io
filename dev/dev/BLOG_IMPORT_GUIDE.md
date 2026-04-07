# Blog Post Import Template

Use this template for importing Notion posts to Jekyll.

## Frontmatter Template

```markdown
---
layout: default
title: "Your Article Title"
date: YYYY-MM-DD
tags: ["tag1", "tag2", "tag3"]
image: "article-slug.webp"
is_new: true  # Optional, set to true for recent posts
---

Your first paragraph becomes the excerpt (shows in blog list).

---

Rest of your article content here...
```

## Import Workflow

1. **Export from Notion:**
   - Select "Export" → "Markdown & CSV"
   - Download the zip file

2. **Prepare the file:**
   - Rename to kebab-case: `article-title.md`
   - Move to `/blog/` folder
   - Add frontmatter at top (use template above)
   - Everything before first `---` separator becomes the excerpt

3. **Handle images:**
   - Extract images from Notion export
   - Rename with article prefix: `article-slug-image-name.png`
   - Move to `/img/articles/`
   - Update markdown image paths: `![Alt](/img/articles/article-slug-image-name.webp)`
   - Optional: Convert to WebP using image optimizer

4. **Add featured image:**
   - Create/select a featured image for the article card
   - Save as `/img/articles/article-slug.webp`
   - Reference in frontmatter `image:` field

5. **Test locally:**
   ```bash
   bundle exec jekyll serve
   # Visit: http://localhost:4000/blog/
   ```

6. **Push to deploy:**
   ```bash
   git add blog/ img/articles/
   git commit -m "Add new article: [title]"
   git push origin main
   ```

## Auto-generated list

The `/blog/` page now automatically:
- Lists all posts from `/blog/*.md`
- Sorts by date (newest first)  
- Shows featured image from `image:` frontmatter
- Displays excerpt (first paragraph before `---`)
- Shows "NEW" badge if `is_new: true`
- Uses existing card layout (Bootstrap + Tailwind)

## Series Organization

To group posts by series (like CandleWise, AWS, etc.), add to frontmatter:
```yaml
series: "CandleWise"
series_part: 1
```

Then update `blog-auto.html` to group by series if needed.
