---
layout: default
title: "Migrating My Portfolio to Jekyll: Why and How"
date: 2026-04-07
tags: ["jekyll", "github-pages", "web-development", "devops"]
image: "jekyll_pages.png"
is_new: true
excerpt: "I was embedding Notion pages in my site. Simple, but too dependent. I wanted content in Git, not locked in Notion's database. Jekyll's native GitHub Pages support made the switch effortless. Now I write markdown, commit, and it's live."
---

## The Problem: Too Dependent on Notion

My original workflow was simple by design. I'd write in Notion, leverage Notion AI for faster edits, publish the page, and embed a link to it from my site. The blog itself was just HTML, CSS, and JavaScript—intentionally minimal. This kept the code clean and gave me more time to write.

But over time, I realized I was too dependent on Notion. My content lived in their database. Every post was a published Notion page that I linked to. If Notion went down, my blog was broken links. I had no version control over my content. No history of edits. No way to track how my writing evolved.

I wanted my content in Git, tracked natively alongside my code. Markdown felt like the obvious choice—simple, portable, perfect for technical writing.

## Why Jekyll?

I was already using GitHub Pages for hosting. Jekyll has native, out-of-the-box support there. No configuration. No build pipelines. Just push markdown files and it works. That alone was compelling.

But the real reason? Jekyll is mature. It's been around since 2008. The ecosystem is stable. The documentation is thorough. I didn't want to spend time fighting a new framework or debugging alpha-stage tooling. I wanted to write.

**Markdown as source of truth.** My content lives in Git now. Every post is a markdown file. Every edit is a commit. I can track how my writing evolved, roll back mistakes, and branch for experiments.

**Native GitHub Pages integration.** Push to `main` and it's live. GitHub handles the build. No CI/CD config needed. No deployment scripts. It just works.

**Static site generators made sense.** My blog was already static HTML. Static site generators are perfect for this—fast, simple, and well-suited for content-focused sites.

**Automated everything.** Posts sort themselves by date. Tags display automatically. Excerpts appear in blog cards but not in articles. The "NEW" badge shows up based on a simple frontmatter flag.

**Keep it minimal.** I didn't want framework hacks. No endless plugin dependencies. No complex build setups. Jekyll lets me focus on writing, not on tooling. The site does one thing well: display markdown content.

## The Migration Journey

The migration happened in phases over a weekend. My old site was intentionally simple—HTML, CSS, JavaScript. Blog posts were just links to published Notion pages. Clean, but not sustainable.

I started by setting up Jekyll's basic structure—a `_config.yml` file, a simple Gemfile, and the essential `_layouts/default.html` template. That template became the heart of the site, handling navigation, analytics, and the footer for every page.

Next came the CSS. I kept it minimal. Two focused files: `main.css` for base styles (typography, navigation, code blocks, tables) and `pages.css` for components (hero section, blog cards, responsive design). No frameworks. No bloat. Just what I needed.

The blog list transformation was where Jekyll really shined. What used to be manual HTML became a simple Liquid template that filters, sorts, and displays posts automatically. Jekyll handles the heavy lifting—I just write markdown.

Migrating 20+ existing posts from Notion could have been tedious, so I automated it with a PowerShell script. The script extracts excerpts, adjusts heading levels, renames images with descriptive prefixes, and generates consistent frontmatter. What would have taken days took an afternoon. That was the last time I pulled content from Notion.

Now, I still brainstorm in Notion—it's great for messy thinking. But when it's time to write, I open VS Code, create a markdown file, and the content lives in Git from day one.

Even the projects page got simpler. Instead of maintaining an HTML table with inline styles, I converted it to markdown with badge-style GitHub and blog links. Jekyll's built-in table rendering handled the rest.

You can see all the code in the [GitHub repository](https://github.com/pedropcamellon/pedropcamellon.github.io)—it's cleaner than any tutorial could show.

## The Frontmatter Philosophy

Every blog post now starts with consistent frontmatter that tells Jekyll everything it needs to know:

```yaml
---
layout: default
title: "Article Title"
date: 2026-04-07
tags: ["web-dev", "jekyll"]
image: "thumbnail.webp"
is_new: true
excerpt: "One-sentence summary for blog cards"
---
```

The `date` field controls sorting. The `is_new` flag shows the "NEW" badge (I remove it after a few weeks). The `excerpt` appears only in blog cards, never in the article itself. It's metadata-driven content management at its simplest.

## Local Development: Docker Saves the Day

Setting up Ruby environments can be painful. Version conflicts, gem dependencies, platform-specific issues—it's a rabbit hole. Docker solved all of it.

I created a simple `docker-compose.yml` that spins up Jekyll 4.2.2 with live reload. No Ruby installation needed. No version conflicts. Just `docker compose up` and start writing. The development server runs at `localhost:4000` with instant preview of changes.

The only hiccup? SSL certificate errors when Docker tried to fetch gems from `https://rubygems.org`. The fix was simple: change the Gemfile source to `http://rubygems.org`. Not ideal for production, but perfectly fine for local development.

## Deployment: Git Push and Forget

The deployment workflow is delightfully simple. Edit files locally. Commit changes. Push to the `main` branch. GitHub Pages automatically builds and deploys the site. I don't even commit the `_site/` build directory—GitHub handles it server-side.

For preview environments, I set up a GitHub Actions workflow that deploys the `dev` branch to a separate URL. It's useful for testing major changes before they go live.

## What I Learned

**Convenience can become dependency.** Embedding Notion links was easy. Too easy. I traded control for convenience and didn't realize it until I wanted my content in Git.

**Maturity matters.** Jekyll isn't the newest or flashiest static site generator. But it's battle-tested. The documentation is solid. The ecosystem is stable. That's worth more than cutting-edge features.

**Keep it minimal to focus on writing.** I could have added a dozen frameworks and plugins. But every dependency is a potential distraction. Minimal tooling means more time writing, less time debugging.

**Notion for brainstorming, Git for publishing.** Notion is still valuable for messy thinking. But polished content belongs in version control. Separate the tools, keep both useful.

**Docker is worth the setup.** I avoided days of Ruby environment troubleshooting by starting with Docker. The consistency across machines is invaluable.

**Automation compounds.** That PowerShell import script saved hours on the initial migration. But more importantly, it'll save hours every time I import new posts. Time spent on automation is time invested.

**Frontmatter is powerful.** Separating metadata from content keeps everything clean. Tags, excerpts, dates, badges—all controlled through simple YAML fields.

**Static site generators are perfect for blogs.** My site was already static HTML. Jekyll just formalized it. Fast, simple, and perfectly suited for content-focused sites.

## The Results

Before: Write in Notion → Publish Notion page → Embed link in site → Hope Notion stays up.  
Now: Write markdown → Commit to Git → Push. Done.

My content is version controlled. Every post has edit history. The site is faster (no external dependencies on Notion). And I'm not locked into one platform anymore.

More importantly, I'm writing more. The friction of "where does this content live?" is gone. Markdown files in Git feel right. The mental overhead vanished.

## What's Next?

I'm keeping a list of potential enhancements—search functionality, pagination, dark mode, WebP image optimization as a part of the GitHub Action, reading time estimates. But I'm not rushing. The site works. It's minimal by design. Every feature I don't add is one less thing to maintain.

So far, keeping it minimal has been the right choice. I'm focused on writing, not on framework hacks. That was the whole point.

## Resources

- **GitHub Repository:** [pedropcamellon.github.io](https://github.com/pedropcamellon/pedropcamellon.github.io)

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages + Jekyll Guide](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll)
- [Liquid Template Language](https://shopify.github.io/liquid/)
- [Testing Your GitHub Pages Site Locally with Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll)
