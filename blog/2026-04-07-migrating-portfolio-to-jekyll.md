---
layout: default
title: "Migrating My Portfolio to Jekyll: Why and How"
date: 2026-04-07
tags: ["jekyll", "github-pages", "web-development", "devops"]
image: "jekyll_pages.jpg"
is_new: true
excerpt: "How I transformed my portfolio from manual HTML updates to an automated Jekyll workflow. A journey from Bootstrap/Tailwind bloat to clean custom CSS, from repetitive tasks to 'git push and forget' deployment."
---

When I first launched my portfolio, it was a simple static site built with HTML, Bootstrap, and Tailwind. It looked great and was easy to set up. But as I added more blog posts, projects, and updates, the maintenance became more and more tedious. Every new blog post meant: write it in Notion, spend an hour polishing it, and then... the real work begins. Copy the HTML. Create a new card in `blog.html`. Update the navigation. Copy the footer. Test locally. Push to GitHub. Repeat for every single post.

I was managing my portfolio as a static HTML site with Bootstrap and Tailwind doing the heavy lifting. Every new blog post meant manually creating HTML card entries, copying navigation code across pages, and keeping my Notion content in sync with my site. It worked, but it didn't scale.

The breaking point came when I wanted to add tags to all my posts. The thought of updating 20+ individual HTML files made me realize: there has to be a better way.

## Why Jekyll?

I'd heard about Jekyll before—GitHub Pages' built-in static site generator—but dismissed it as overkill. Turns out, I was wrong. Jekyll solved every pain point I had:

**Write once, deploy everywhere.** Blog posts became simple markdown files. Drop a `.md` file in the `/blog/` folder, push to GitHub, and it automatically appears on my site. No more HTML wrangling.

**One template to rule them all.** Instead of copying navigation and footer code across dozens of pages, I created a single layout template. Change it once, update everywhere. The DRY principle in action.

**Framework independence.** I wanted to keep things simple. Bootstrap and Tailwind meant learning their conventions and fighting their defaults. Custom CSS gave me exactly what I needed, nothing more.

**Automated everything.** Posts sort themselves by date. Tags display automatically. Excerpts appear in blog cards but not in articles. The "NEW" badge shows up based on a simple frontmatter flag.

But the real catalyst? My blog was growing. Jekyll is fully supported by GitHub Pages with minimal setup—it felt like the obvious choice for spending more time writing and less time on dev work.

## The Migration Journey

The migration happened in phases over a weekend. I started by setting up Jekyll's basic structure—a `_config.yml` file, a simple Gemfile, and the essential `_layouts/default.html` template. That template became the heart of the site, handling navigation, analytics, and the footer for every page.

Next came the CSS overhaul. I replaced Bootstrap and Tailwind with two focused files: `main.css` for base styles (typography, navigation, code blocks, tables) and `pages.css` for components (hero section, blog cards, responsive design). The key insight? Using `min(1200px, 90vw)` for responsive max-width instead of fixed breakpoints made the layout adapt automatically to any screen size.

The blog list transformation was where Jekyll really shined. What used to be dozens of manually-coded HTML cards became a simple Liquid template that filters, sorts, and displays posts automatically. Jekyll handles all the heavy lifting—I just write markdown.

Migrating 20+ existing posts from Notion could have been tedious, so I automated it with a PowerShell script. The script extracts the first paragraph as an excerpt, adjusts heading levels, wraps Liquid syntax properly, renames images with descriptive slug prefixes, and generates consistent frontmatter. What would have taken days took an afternoon.

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

**Docker is worth the setup.** I avoided days of Ruby environment troubleshooting by starting with Docker. The consistency across machines is invaluable.

**Custom CSS beats frameworks for static sites.** Bootstrap and Tailwind are great for applications, but overkill for a portfolio. Custom CSS gave me exactly what I needed with none of the bloat.

**Automation compounds.** That PowerShell import script saved hours on the initial migration. But more importantly, it'll save hours every time I import new posts. Time spent on automation is time invested.

**Frontmatter is powerful.** Separating metadata from content keeps everything clean. Tags, excerpts, dates, badges—all controlled through simple YAML fields.

**Simple wins.** I could have added search, pagination, RSS feeds, dark mode, and a dozen other features. But I didn't need them yet. The site does one thing well: display blog posts. Everything else can wait.

## The Results

Before this migration, adding a blog post took 30 minutes of HTML wrangling. Now it takes 5 minutes—just write markdown and push. The site loads dramatically faster without framework bloat. Making global changes (like updating the footer) is a one-line edit instead of a multi-file search-and-replace.

More importantly, the friction is gone. I'm writing more because writing is easier. The technical debt that accumulated over months of manual updates? Paid off in a weekend.

## What's Next?

I'm keeping a list of potential enhancements—search functionality, pagination, dark mode, WebP image optimization as a part of the GitHub Action, reading time estimates, related posts. But I'm not rushing to implement any of them. The site works beautifully as-is.

The real lesson? Sometimes the best feature is the one you don't add yet.

## Try It Yourself

If you're maintaining a static portfolio or blog with manual HTML updates, Jekyll is worth considering. The initial setup takes a few hours, but you'll save that time back on your first few posts.

Check out my [GitHub repo](https://github.com/pedropcamellon/pedropcamellon.github.io) for the complete implementation. The code speaks louder than any tutorial.

## Resources

- **GitHub Repository:** [pedropcamellon.github.io](https://github.com/pedropcamellon/pedropcamellon.github.io)

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages + Jekyll Guide](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll)
- [Liquid Template Language](https://shopify.github.io/liquid/)
- [Testing Your GitHub Pages Site Locally with Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll)
