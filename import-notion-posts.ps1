# Notion to Jekyll Blog Importer
# Processes exported Notion markdown files and imports them to Jekyll blog
# Usage: Drop Notion export ZIP in blog/ folder and run this script

$notionExportPath = "temp-notion-export"
$blogPath = "blog"
$imagesPath = "img/articles"

# Find ZIP files in blog folder
$zipFiles = Get-ChildItem -Path $blogPath -Filter "*.zip"

if ($zipFiles.Count -eq 0) {
    Write-Host "No ZIP files found in /blog/ folder" -ForegroundColor Red
    Write-Host "Export from Notion and drop the ZIP file into /blog/ then run this script"
    exit
}

Write-Host "Found $($zipFiles.Count) ZIP file(s) in /blog/" -ForegroundColor Cyan

# Clean up existing temp directory
if (Test-Path $notionExportPath) {
    Remove-Item $notionExportPath -Recurse -Force
}
New-Item -ItemType Directory -Path $notionExportPath | Out-Null

# Extract all ZIP files
foreach ($zip in $zipFiles) {
    Write-Host "Extracting: $($zip.Name)" -ForegroundColor Yellow
    Expand-Archive -Path $zip.FullName -DestinationPath $notionExportPath -Force
}

# Extract nested ZIPs if any
$nestedZips = Get-ChildItem -Path $notionExportPath -Filter "*.zip" -Recurse
foreach ($nestedZip in $nestedZips) {
    Write-Host "Extracting nested: $($nestedZip.Name)" -ForegroundColor Yellow
    Expand-Archive -Path $nestedZip.FullName -DestinationPath $nestedZip.DirectoryName -Force
    Remove-Item $nestedZip.FullName -Force
}

# Get all markdown files that are likely blog posts (>1KB)
$mdFiles = Get-ChildItem -Path $notionExportPath -Recurse -Filter "*.md" | Where-Object { $_.Length -gt 1KB }

Write-Host "`nFound $($mdFiles.Count) potential blog posts" -ForegroundColor Green

foreach ($file in $mdFiles) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
    
    # Read file content
    $content = Get-Content $file.FullName -Raw
    
    # Extract title from first H1
    if ($content -match '#\s+(.+?)\r?\n') {
        $title = $matches[1].Trim()
        Write-Host "  Title: $title"
        
        # Create slug from title
        $slug = $title -replace '[^\w\s-]', '' -replace '\s+', '-' -replace '--+', '-'
        $slug = $slug.ToLower().Trim('-')
        $slug = $slug.Substring(0, [Math]::Min(60, $slug.Length))
        Write-Host "  Slug: $slug"
        
        # Extract date from "Created time" or "Last Edited"
        $date = Get-Date -Format "yyyy-MM-dd"
        if ($content -match 'Created time:\s+(.+?)\r?\n') {
            try {
                $createdDate = [DateTime]::Parse($matches[1])
                $date = $createdDate.ToString("yyyy-MM-dd")
                Write-Host "  Date: $date (from Created time)"
            } catch {
                Write-Host "  Could not parse Created time, using today" -ForegroundColor Yellow
            }
        } elseif ($content -match 'Last [Ee]dited:\s+(.+?)\r?\n') {
            try {
                $editedDate = [DateTime]::Parse($matches[1])
                $date = $editedDate.ToString("yyyy-MM-dd")
                Write-Host "  Date: $date (from Last Edited)"
            } catch {
                Write-Host "  Could not parse date, using today" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  Date: $date (today - no Notion date found)"
        }
        
        # Check if post already exists
        $outputPath = Join-Path $blogPath "$slug.md"
        if (Test-Path $outputPath) {
            Write-Host "  WARNING: Already exists - SKIPPING" -ForegroundColor Yellow
            continue
        }
        
        # Remove Notion metadata (title + metadata lines until first ## or content)
        $contentCleaned = $content -replace '(?s)^#[^#].*?(?=(##|\r?\n\r?\n[^#]))', ''
        
        # Adjust heading levels if H1 is present (demote all headings by one level)
        # Since Jekyll uses page title as H1, content H1s should become H2s, etc.
        if ($contentCleaned -match '(^|\r?\n)# [^#]') {
            Write-Host "  Adjusting heading levels (H1 found, demoting all headings)" -ForegroundColor DarkYellow
            # Use reverse order to avoid double-replacements
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)##### ', '$1###### '  # H5 → H6
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)#### ', '$1##### '   # H4 → H5
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)### ', '$1#### '    # H3 → H4
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)## ', '$1### '     # H2 → H3
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)# ([^#])', '$1## $2'      # H1 → H2
        } else {
            Write-Host "  Keeping heading levels as-is (no H1 found)" -ForegroundColor DarkGray
        }
        
        # Wrap code blocks containing {{ }} in {% raw %} to prevent Liquid parsing
        $contentCleaned = $contentCleaned -replace '(```[^`]*\{\{[^`]*```)', '{% raw %}$1{% endraw %}'
        
        # Handle inline images - update paths
        $contentCleaned = $contentCleaned -replace '!\[([^\]]*)\]\(([^)]+)\)', '![$1](/img/articles/$slug-$2)'
        
        # Extract first paragraph for excerpt (first meaningful paragraph)
        $excerpt = ""
        if ($contentCleaned -match '(?:##.*?\r?\n\r?\n)?([^\r\n]{50,}.*?)(?:\r?\n\r?\n|$)') {
            $excerpt = $matches[1].Trim()
        }
        
        # Add Jekyll frontmatter
        $frontmatter = @"
---
layout: default
title: "$title"
date: $date
tags: []
$(if ($excerpt) { "excerpt: `"$excerpt`"" })
---

"@
        
        # Create final content
        $finalContent = $frontmatter + $contentCleaned.Trim()
        
        # Save to blog folder
        Set-Content -Path $outputPath -Value $finalContent -Encoding UTF8
        Write-Host "  ✓ Saved: $outputPath" -ForegroundColor Green
        
        # Handle images - look for folder with same name as MD file
        $imageDir = Join-Path $file.DirectoryName ([System.IO.Path]::GetFileNameWithoutExtension($file.Name))
        if (Test-Path $imageDir) {
            $images = Get-ChildItem -Path $imageDir -File -Include *.png,*.jpg,*.jpeg,*.gif,*.webp
            if ($images.Count -gt 0) {
                Write-Host "  ✓ Found $($images.Count) image(s)" -ForegroundColor Magenta
                foreach ($img in $images) {
                    $newImgName = "$slug-$($img.Name)"
                    $destPath = Join-Path $imagesPath $newImgName
                    Copy-Item $img.FullName -Destination $destPath -Force
                    Write-Host "    - Copied: $newImgName"
                }
            }
        } else {
            Write-Host "  ℹ No images folder found" -ForegroundColor DarkGray
        }
        
    } else {
        Write-Host "  ✗ Skipping: No title found" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Processing complete!" -ForegroundColor Green
Write-Host "`nNext steps:"
Write-Host "  1. Review imported posts in /blog/"
Write-Host "  2. Add tags to frontmatter"
Write-Host "  3. Add featured images if needed"
Write-Host "  4. Clean up ZIP files: Remove-Item blog\*.zip"
Write-Host "  5. Clean up temp: Remove-Item temp-notion-export -Recurse"
