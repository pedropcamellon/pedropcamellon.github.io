# ============================================================================
# Notion to Jekyll Blog Importer
# ============================================================================
# 
# DESCRIPTION:
#   Automates the process of importing Notion-exported markdown files into a 
#   Jekyll blog with proper formatting, metadata, and image handling.
#
# MAIN FEATURES:
#   ✓ Auto-extracts ZIP files to separate folders (avoids conflicts)
#   ✓ Parses Notion YAML frontmatter (Publish Date, Last Edited, Tags)
#   ✓ Generates Jekyll-compatible frontmatter with date, tags, excerpt, updated
#   ✓ Creates blog/YYYY-MM-DD-slug/ folder structure
#   ✓ Copies images to blog post folder (preserves original filenames)
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

# Ensure blog directory exists
if (-not (Test-Path $blogPath)) {
    New-Item -ItemType Directory -Path $blogPath -Force | Out-Null
    Write-Host "Created blog directory: $blogPath" -ForegroundColor Green
}

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
    # Create a unique folder for each ZIP based on its name
    $zipFolderName = [System.IO.Path]::GetFileNameWithoutExtension($zip.Name)
    $zipExtractPath = Join-Path $notionExportPath $zipFolderName
    Expand-Archive -Path $zip.FullName -DestinationPath $zipExtractPath -Force
}

# Extract nested ZIPs if any (but keep original ZIPs in root)
$nestedZips = Get-ChildItem -Path $notionExportPath -Filter "*.zip" -Recurse | Where-Object { $_.DirectoryName -ne (Resolve-Path $notionExportPath).Path }
foreach ($nestedZip in $nestedZips) {
    Write-Host "Extracting nested: $($nestedZip.Name)" -ForegroundColor Yellow
    Expand-Archive -Path $nestedZip.FullName -DestinationPath $nestedZip.DirectoryName -Force
    Remove-Item $nestedZip.FullName -Force
    Write-Host "  Removed nested ZIP: $($nestedZip.Name)" -ForegroundColor DarkGray
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
            Write-Host "  [ERROR] SKIPPING: Publish Date is required but not found or invalid" -ForegroundColor Red
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
        # Create article folder and output path
        # -----------------------------------------------------------------------
        $articleFolder = Join-Path $blogPath "$date-$slug"
        $outputPath = Join-Path $articleFolder "$date-$slug.md"
        
        if (Test-Path $outputPath) {
            Write-Host "  WARNING: Already exists - SKIPPING" -ForegroundColor Yellow
            continue
        }
        
        # Create article folder
        if (-not (Test-Path $articleFolder)) {
            New-Item -ItemType Directory -Path $articleFolder -Force | Out-Null
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
        # Copy images to blog post folder (preserve original filenames)
        # -----------------------------------------------------------------------
        # Notion exports images to the same folder as the markdown file
        $imageDir = $file.DirectoryName
        Write-Host "  Looking for images in: $imageDir" -ForegroundColor DarkGray
        
        $images = Get-ChildItem -Path $imageDir -File -Include *.png, *.jpg, *.jpeg, *.gif, *.webp
        if ($images.Count -gt 0) {
            Write-Host "  Found $($images.Count) image(s)" -ForegroundColor DarkGray
            # Copy all images directly to article folder
            foreach ($imgFile in $images) {
                $destPath = Join-Path $articleFolder $imgFile.Name
                Copy-Item $imgFile.FullName -Destination $destPath -Force
                Write-Host "    Copied: $($imgFile.Name)" -ForegroundColor DarkGray
            }
            Write-Host "  ✓ Copied $($images.Count) image(s)" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  No images found" -ForegroundColor DarkGray
        
    }
    else {
        Write-Host "  [ERROR] Skipping: No title found" -ForegroundColor Yellow
    }
}
