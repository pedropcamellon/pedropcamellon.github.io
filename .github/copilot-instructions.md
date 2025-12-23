# GitHub Copilot Instructions for pedropcamellon.github.io

## Overview

Static portfolio/blog site using vanilla HTML + Bootstrap 5.3.3 + Tailwind CSS (CDN). No build process. Deployed via GitHub Pages.

**Structure:**

- `index.html` - Home page (hero, about, contact)
- `blog.html` - Article listings by series (AWS, CandleWise, Dragons vs Unicorns)
- `projects.html` - Project table with GitHub/Notion links
- `img/articles/` - Article thumbnails

## Rules

1. **CSS Framework Priority:**

   - Use Bootstrap first: `d-flex`, `mb-4`, `container`, `nav-link`, `badge`, `fw-semibold`
   - Use Tailwind for: `text-2xl`, `flex`, `gap-8`, `rounded-lg`, `rounded-full`
   - Use inline styles ONLY for custom values: `style="background-color:#f59e42"`

2. **Article Cards Pattern:**

   ```html
   <article>
     <a href="[notion-url]">
       <div
         class="flex flex-col md:flex-row gap-8 mx-auto p-2 border rounded-lg"
       >
         <img
           src="/img/articles/[name].png"
           class="rounded-lg d-block max-w-full md:max-w-52"
         />
         <div>
           <h3 class="text-2xl font-bold mb-4">
             [Title]
             <span
               class="badge fw-semibold ms-2"
               style="background-color:#f59e42; font-size:0.85rem; letter-spacing:1px;"
               >NEW</span
             >
           </h3>
           <p>[Description]</p>
         </div>
       </div>
     </a>
   </article>
   ```

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

   - Edit HTML directly → commit → push to `main` → auto-deploys
   - Test locally by opening `index.html` in browser

8. **Response Format:**
   - Always include footer with current timestamp in format: `YYYY-MM-DD`
