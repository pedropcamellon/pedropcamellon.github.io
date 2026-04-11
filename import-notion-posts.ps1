# ============================================================================
# Notion to Jekyll Blog Importer
# ============================================================================
# 
# DESCRIPTION:
#   Automates the process of importing Notion-exported markdown files into a 
#   Jekyll blog with proper formatting, metadata, and image handling.
#
# MAIN FEATURES:
#   ✓ Auto-extracts ZIP files (including nested archives)
#   ✓ Parses Notion YAML frontmatter (Publish Date, Last Edited, Tags)
#   ✓ Generates Jekyll-compatible frontmatter with date, tags, excerpt, updated
#   ✓ Creates date-prefixed filenames (YYYY-MM-DD-slug.md)
#   ✓ Copies and renames images with date-slug prefix
#   ✓ Updates image references in markdown
#   ✓ Auto-detects common tags from content (Python, AWS, React, etc.)
#   ✓ Adjusts heading levels (demotes H1→H2, etc.)
#   ✓ Wraps Liquid syntax in {% raw %} tags
#   ✓ Skips duplicate posts (checks existing files)
#
# USAGE:
#   1. Export pages from Notion (Markdown & CSV format)
#   2. Drop ZIP file(s) into /temp-notion-export/ folder
#   3. Run: .\import-notion-posts.ps1
#   4. Review imported posts in /blog/
#   5. Clean up: Remove temp-notion-export folder
#
# ============================================================================

Add-Type -AssemblyName System.Web

# Configuration
$notionExportPath = "temp-notion-export"
$blogPath = "blog"
$imagesPath = "assets/img/articles"

# ============================================================================
# FUNCTION: Detect Common Tags from Content
# ============================================================================
# Scans post content for common keywords and returns matching tags
# ============================================================================
function Get-ContentTags {
    param([string]$content)
    
    $detectedTags = @()
    
    # Define tag patterns (case-insensitive regex patterns)
    $tagPatterns = @{
        'python'     = '\b(python|django|flask|pandas|numpy)\b'
        'javascript' = '\b(javascript|js|node\.?js|npm|yarn)\b'
        'react'      = '\b(react|reactjs|jsx|next\.?js)\b'
        'aws'        = '\b(aws|amazon web services)\b'
        's3'         = '\b(s3|amazon s3)\b'
        'lambda'     = '\b(lambda|aws lambda)\b'
        'terraform'  = '\b(terraform|tf|infrastructure as code)\b'
        'docker'     = '\b(docker|container|dockerfile)\b'
        'kubernetes' = '\b(kubernetes|k8s|kubectl)\b'
        'ai'         = '\b(ai|artificial intelligence|machine learning|ml)\b'
        'llm'        = '\b(llm|large language model|gpt|chatgpt)\b'
        'azure'      = '\b(azure|microsoft azure)\b'
        'api'        = '\b(api|rest|rest(ful)? api|graphql)\b'
        'devops'     = '\b(devops|ci/cd|continuous integration)\b'
        'typescript' = '\b(typescript|ts)\b'
        'css'        = '\b(css|sass|scss|tailwind)\b'
        'html'       = '\b(html|html5)\b'
        'database'   = '\b(database|sql|mysql|postgresql|mongodb|dynamodb)\b'
        'bedrock'    = '\b(bedrock|amazon bedrock)\b'
        'transcribe' = '\b(transcribe|amazon transcribe|speech-to-text)\b'
        'cloudwatch' = '\b(cloudwatch|aws cloudwatch)\b'
    }
    
    # Check each pattern against content
    foreach ($tag in $tagPatterns.Keys) {
        if ($content -match $tagPatterns[$tag]) {
            $detectedTags += $tag
        }
    }
    
    return $detectedTags
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# ----------------------------------------------------------------------------
# Step 1: Find and validate ZIP files
# ----------------------------------------------------------------------------
# Create temp directory if it doesn't exist
if (-not (Test-Path $notionExportPath)) {
    New-Item -ItemType Directory -Path $notionExportPath | Out-Null
}

$zipFiles = Get-ChildItem -Path $notionExportPath -Filter "*.zip"

if ($zipFiles.Count -eq 0) {
    Write-Host "No ZIP files found in /$notionExportPath/ folder" -ForegroundColor Red
    Write-Host "Export from Notion and drop the ZIP file into /$notionExportPath/ then run this script"
    exit
}

Write-Host "Found $($zipFiles.Count) ZIP file(s) in /$notionExportPath/" -ForegroundColor Cyan

# ----------------------------------------------------------------------------
# Step 2: Extract all ZIP files (including nested archives)
# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# Step 3: Find markdown files (filter out small files like README.md)
# ----------------------------------------------------------------------------
$mdFiles = Get-ChildItem -Path $notionExportPath -Recurse -Filter "*.md" | Where-Object { $_.Length -gt 1KB }

Write-Host "`nFound $($mdFiles.Count) potential blog posts" -ForegroundColor Green

# ============================================================================
# PROCESSING LOOP: Each Markdown File
# ============================================================================

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
        $slug = $slug.Substring(0, [Math]::Min(100, $slug.Length))
        Write-Host "  Slug: $slug"
        
        # -----------------------------------------------------------------------
        # Extract metadata from Notion YAML frontmatter
        # -----------------------------------------------------------------------
        $date = $null
        $updated = $null
        $tags = @()
        
        # Extract Publish Date (required) - search anywhere in content
        if ($content -match 'Publish Date:\s*(\d{1,2}/\d{1,2}/\d{4})') {
            $publishDateStr = $matches[1].Trim()
            try {
                # Parse MM/dd/yyyy format with multiple attempts
                $formats = @('MM/dd/yyyy', 'M/d/yyyy', 'M/dd/yyyy', 'MM/d/yyyy', 'dd/MM/yyyy', 'd/M/yyyy')
                $parsed = $false
                
                foreach ($format in $formats) {
                    try {
                        $publishDate = [DateTime]::ParseExact($publishDateStr, $format, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None)
                        $date = $publishDate.ToString("yyyy-MM-dd")
                        Write-Host "  Date: $date (from Publish Date: $publishDateStr using format: $format)" -ForegroundColor Green
                        $parsed = $true
                        break
                    }
                    catch {
                        # Try next format
                    }
                }
                
                if (-not $parsed) {
                    Write-Host "  ERROR: Could not parse Publish Date '$publishDateStr' with any known format" -ForegroundColor Red
                    Write-Host "  Expected formats: MM/dd/yyyy, M/d/yyyy, M/dd/yyyy, MM/d/yyyy" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "  ERROR: Could not parse Publish Date '$publishDateStr' - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "  ERROR: No 'Publish Date:' field found in markdown file" -ForegroundColor Red
            Write-Host "  Expected format: 'Publish Date: MM/dd/yyyy' (e.g., 'Publish Date: 04/28/2025')" -ForegroundColor Yellow
        }
        
        # Fail if no valid date was extracted
        if ([string]::IsNullOrWhiteSpace($date)) {
            Write-Host "  ✗ SKIPPING: Publish Date is required but not found or invalid" -ForegroundColor Red
            continue
        }
        
        # Extract Last Edited for updated field
        if ($content -match 'Last Edited:\s*(.+?)(?:\r?\n|$)') {
            $editedDateStr = $matches[1].Trim()
            try {
                $editedDate = [DateTime]::Parse($editedDateStr)
                $updated = $editedDate.ToString("yyyy-MM-dd")
                Write-Host "  Updated: $updated (from Last Edited: $editedDateStr)"
            }
            catch {
                Write-Host "  Could not parse Last Edited date '$editedDateStr'" -ForegroundColor Yellow
            }
        }
        
        # Extract Tags from Notion metadata (search anywhere in content)
        if ($content -match 'Tags:\s*(.+?)(?:\r?\n|$)') {
            $tagsString = $matches[1].Trim()
            $tags = $tagsString -split ',\s*' | ForEach-Object { $_.Trim().ToLower() }
            Write-Host "  Notion Tags: $($tags -join ', ')"
        }
        
        # Auto-detect additional tags from content
        $detectedTags = Get-ContentTags -content $content
        if ($detectedTags.Count -gt 0) {
            Write-Host "  Detected Tags: $($detectedTags -join ', ')" -ForegroundColor DarkCyan
            # Merge with existing tags (remove duplicates)
            $tags = ($tags + $detectedTags) | Select-Object -Unique
        }
        
        Write-Host "  Final Tags: $($tags -join ', ')" -ForegroundColor Green
        
        # -----------------------------------------------------------------------
        # Check for duplicates (skip if already imported)
        # -----------------------------------------------------------------------
        $outputPath = Join-Path $blogPath "$date-$slug.md"
        if (Test-Path $outputPath) {
            Write-Host "  WARNING: Already exists - SKIPPING" -ForegroundColor Yellow
            continue
        }
        
        # -----------------------------------------------------------------------
        # Clean content: Remove Notion metadata and title
        # -----------------------------------------------------------------------
        # Remove the --- YAML block if present
        $contentCleaned = $content -replace '(?s)^---\r?\n.+?\r?\n---\r?\n', ''
        # Remove the H1 title (Jekyll will display it from frontmatter)
        $contentCleaned = $contentCleaned -replace '(?s)^#[^#].*?(?=(##|\r?\n\r?\n[^#]))', ''
        # Remove Notion metadata lines (Tags:, Created time:, Last Edited:, Publish Date:, Series Name:, Status:)
        $contentCleaned = $contentCleaned -replace '(?m)^(Tags|Created time|Last Edited|Publish Date|Series Name|Status):.+?$\r?\n', ''
        # Clean up extra blank lines at the start
        $contentCleaned = $contentCleaned -replace '^\s+', ''
        
        # -----------------------------------------------------------------------
        # Adjust heading levels (H1→H2, H2→H3, etc.)
        # Jekyll displays page title as H1, so demote all content headings
        # -----------------------------------------------------------------------
        if ($contentCleaned -match '(^|\r?\n)# [^#]') {
            Write-Host "  Adjusting heading levels (H1 found, demoting all headings)" -ForegroundColor DarkYellow
            # Use reverse order to avoid double-replacements
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)##### ', '$1###### '  # H5 → H6
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)#### ', '$1##### '   # H4 → H5
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)### ', '$1#### '    # H3 → H4
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)## ', '$1### '     # H2 → H3
            $contentCleaned = $contentCleaned -replace '(^|\r?\n)# ([^#])', '$1## $2'      # H1 → H2
        }
        else {
            Write-Host "  Keeping heading levels as-is (no H1 found)" -ForegroundColor DarkGray
        }
        
        # -----------------------------------------------------------------------
        # Protect Liquid syntax in code blocks
        # -----------------------------------------------------------------------
        $contentCleaned = $contentCleaned -replace '(```[^`]*\{\{[^`]*```)', '{% raw %}$1{% endraw %}'
        
        # -----------------------------------------------------------------------
        # Fix image paths: Extract filename and update to Jekyll asset path
        # -----------------------------------------------------------------------
        # Notion exports images with full paths or encoded names, we just want the filename
        $contentCleaned = $contentCleaned -replace '!\[([^\]]*)\]\(([^)]*)\)', {
            param($match)
            $alt = $match.Groups[1].Value
            $path = $match.Groups[2].Value.Trim()
            
            # Skip empty or whitespace-only paths
            if ([string]::IsNullOrWhiteSpace($path)) {
                return "![$alt]()"
            }
            
            # Extract just the filename (after last / or \)
            $filename = Split-Path $path -Leaf
            # URL decode the filename if needed
            $filename = [System.Web.HttpUtility]::UrlDecode($filename)
            "![$alt](/assets/img/articles/$date-$slug-$filename)"
        }
        
        # -----------------------------------------------------------------------
        # Extract excerpt (first meaningful paragraph, 50+ chars)
        # -----------------------------------------------------------------------
        $excerpt = ""
        if ($contentCleaned -match '(?:##.*?\r?\n\r?\n)?([^\r\n]{50,}.*?)(?:\r?\n\r?\n|$)') {
            $excerpt = $matches[1].Trim()
        }
        
        # -----------------------------------------------------------------------
        # Build Jekyll frontmatter
        # -----------------------------------------------------------------------
        $tagsJson = if ($tags.Count -gt 0) { 
            '["' + ($tags -join '", "') + '"]' 
        }
        else { 
            '[]' 
        }
        
        # Add Jekyll frontmatter
        $frontmatter = @"
---
layout: default
title: "$title"
date: $date
tags: $tagsJson
$(if ($excerpt) { "excerpt: `"$excerpt`"" })
$(if ($updated -and $updated -ne $date) { "updated: $updated" })
---

"@
        
        # Create final content
        $finalContent = $frontmatter + $contentCleaned.Trim()
        
        # -----------------------------------------------------------------------
        # Save markdown file
        # -----------------------------------------------------------------------
        Set-Content -Path $outputPath -Value $finalContent -Encoding UTF8
        Write-Host "  ✓ Saved: $outputPath" -ForegroundColor Green
        
        # -----------------------------------------------------------------------
        # Copy images to assets folder
        # -----------------------------------------------------------------------
        $imageDir = Join-Path $file.DirectoryName ([System.IO.Path]::GetFileNameWithoutExtension($file.Name))
        if (Test-Path $imageDir) {
            $images = Get-ChildItem -Path $imageDir -File -Include *.png, *.jpg, *.jpeg, *.gif, *.webp
            if ($images.Count -gt 0) {
                Write-Host "  ✓ Found $($images.Count) image(s)" -ForegroundColor Magenta
                foreach ($img in $images) {
                    $newImgName = "$date-$slug-$($img.Name)"
                    $destPath = Join-Path $imagesPath $newImgName
                    Copy-Item $img.FullName -Destination $destPath -Force
                    Write-Host "    - Copied: $newImgName"
                }
            }
        }
        else {
            Write-Host "  ℹ No images folder found" -ForegroundColor DarkGray
        }
        
    }
    else {
        Write-Host "  ✗ Skipping: No title found" -ForegroundColor Yellow
    }
}

# ============================================================================
# COMPLETION SUMMARY
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Processing complete!" -ForegroundColor Green
Write-Host "`nNext steps:"
Write-Host "  1. Review imported posts in /$blogPath/"
Write-Host "  2. Verify tags and add more if needed"
Write-Host "  3. Add featured images if needed (set 'image:' in frontmatter)"
Write-Host "  4. Clean up temp folder: Remove-Item $notionExportPath -Recurse"
Write-Host "`n" -NoNewline

# ============================================================================
# NOTES & POTENTIAL ENHANCEMENTS
# ============================================================================
# - Add support for featured image detection (first image in post)
# - Support for series/collection metadata
# - Automatic slug collision resolution
# - Dry-run mode to preview changes
# - Interactive tag editing
# - Custom tag pattern configuration file
# ============================================================================
