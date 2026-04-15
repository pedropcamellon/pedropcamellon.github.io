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
is_new: true # Optional, set to true for recent posts
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
   - Move to each article's folder (e.g. `/blog/article-title/`)

4. **Add featured image:**

   - Reference in frontmatter `image:` field
