# Article Writing Guidelines

## Your Voice & Style

Your writing is **personal, practical, and grounded in real experience**. You don't pretend to be an expert—you share what you learned while building things. This authenticity is what makes your content valuable.

### Core Principles

1. **Write from experience, not theory** - Share what you actually built, not what could theoretically be built
2. **Lead with the problem** - Start with pain points before solutions
3. **Be honest about mistakes** - "Turns out, I was wrong" moments build trust
4. **Focus on outcomes** - What worked, what didn't, what you'd do differently
5. **Keep it conversational** - Write like you're explaining to a colleague, not lecturing

### Tone Checklist

- Use "I" liberally - this is your journey
- Share frustrations and wins equally
- Admit when something was harder than expected
- Explain _why_ you made decisions, not just _what_ you did
- Use phrases like "I realized", "The breaking point came when", "Turns out"
- Be opinionated but humble - "This worked for me" not "This is the only way"
- Write conversationally and accessibly - explain complex ideas in plain language
- Show your learning journey - share how your understanding evolved
- Surface obstacles openly - describe challenges and how you solved them
- Talk naturally to readers - imagine explaining over coffee, not presenting to an audience
- Define technical terms clearly - assume readers are smart but may not know your specific domain

---

## Article Structure

### Required Frontmatter

Every article must include:

```yaml
---
layout: default
title: "Descriptive Title: Problem → Solution"
date: YYYY-MM-DD
tags: ["tag1", "tag2", "tag3"]
image: "descriptive-slug.webp"
excerpt: "One compelling sentence summarizing the key insight or outcome. Focus on the 'so what' not the 'what'."
---
```

**Optional fields:**

- `is_new: true` - Add for recent articles (remove after 2-3 weeks)

### Standard Sections

1. **Opening Hook** (Required)

Start with one of these approaches:

- **The Problem** - Describe the pain point that sparked the project
- **The Realization** - A key insight that changed your approach
- **The Context** - Set the stage for why this matters

**Examples from your work:**

- "When I first launched my portfolio, it looked great... but as I added more blog posts, the maintenance became tedious."
- "I was managing my portfolio as a static HTML site... Every new blog post meant manually creating HTML card entries."

2. **Why [Technology/Approach]?** (Required for technical posts)

Explain your decision-making process:

- What alternatives did you consider?
- What made you choose this path?
- What problem does it solve that others don't?

Use **bold subheadings** for key points:

- **Write once, deploy everywhere.**
- **One template to rule them all.**
- **Automated everything.**

3. **The Journey/Implementation** (Required)

Walk through the actual work:

- Describe the phases/steps chronologically
- Include the hiccups and how you solved them
- Show code snippets with context (not just dumps)
- Add screenshots where they clarify the process

**Keep it real:**

- "The only hiccup? SSL certificate errors..."
- "This step was vital for testing before moving on to more complex operations."

4. **Code Examples** (When applicable)

- Always include language specification: `python`, `yaml`, `csharp`
- Add brief explanations before or after code blocks
- Show don't tell - let code demonstrate concepts
- Keep examples focused and runnable when possible

5. **What I Learned** or **Key Learnings** (Highly Recommended)

Distill insights as actionable takeaways:

- **Docker is worth the setup.** Specific reason why.
- **Custom CSS beats frameworks for static sites.** Context for when this applies.
- **Automation compounds.** The long-term benefit.

Format as bold statement + explanation pattern.

6. **Results/Outcomes** (Recommended)

Quantify the impact where possible:

- "Adding a blog post took 30 minutes... now it takes 5 minutes"
- "The site loads dramatically faster without framework bloat"
- Before/after comparisons

7. **What's Next** (Optional)

- Only include if genuinely planning follow-up work
- Keep it brief (2-3 sentences max)
- Don't overpromise

8. **Links & Resources** (Required for projects)

At the top or bottom, include:

- **GitHub Repository:** [repo-name](url)
- **Live Demo:** (if applicable)

## Writing Process Checklist

### Before Writing

- [ ] What problem am I solving?
- [ ] What's the core insight/outcome?
- [ ] Who is this for? (Usually: developers with similar challenges)

### During Writing

- [ ] Am I explaining _why_, not just _what_?
- [ ] Would past-me understand this?
- [ ] Am I showing, not just telling? (Code, screenshots, examples)
- [ ] Is this authentic to my experience?

### Before Publishing

- [ ] Frontmatter complete and accurate
- [ ] All code blocks have language specified
- [ ] Images named descriptively and stored in `/img/articles/`
- [ ] Links work (especially GitHub repos and external resources)
- [ ] Excerpt is compelling (appears in blog cards)
- [ ] Proofread for typos, but keep conversational tone
- [ ] Tags are consistent with existing articles

---

## Common Patterns From Your Best Work

### The "Breaking Point" Opening

Start with accumulating frustration → the moment you decided to change:

> "The breaking point came when I wanted to add tags to all my posts. The thought of updating 20+ individual HTML files made me realize: there has to be a better way."

### The "Turns Out I Was Wrong" Admission

Show growth by acknowledging misconceptions:

> "I'd heard about Jekyll before—but dismissed it as overkill. Turns out, I was wrong."

### The "Docker Saved the Day" Practical Win

Highlight specific tools/decisions that made life easier:

> "Setting up Ruby environments can be painful... Docker solved all of it."

### The Quantified Outcome

Give concrete before/after metrics:

> "Before this migration, adding a blog post took 30 minutes. Now it takes 5 minutes."

### The "Here's the Code" Transparency

Always link to working examples:

> "You can see all the code in the GitHub repository—it's cleaner than any tutorial could show."

---

## Length Guidelines

**Full Tutorial Posts:** 1,200-2,000 words

- Include: Problem → Solution → Implementation → Learnings → Results

**Technical Deep Dives:** 800-1,500 words

- Focus on one specific concept or technique in depth

**Quick Insights/Project Showcases:** 400-800 words

- Overview with link to full Notion article or GitHub repo

**Don't artificially inflate.** If you've said what needs saying in 600 words, stop there.

---

## Final Reminders

1. **Your best writing happens when you're sharing what you actually learned while building something real.**

2. **The excerpt is crucial** - it appears in blog cards and determines if people click. Make it count.

3. **"NEW" badges are temporary** - Set `is_new: true` for recent posts, remove after 2-3 weeks.

4. **Consistency > perfection** - Following these guidelines creates a cohesive reading experience even if individual posts aren't perfect.

---

_These guidelines should evolve as your writing style develops. Review and update quarterly._
