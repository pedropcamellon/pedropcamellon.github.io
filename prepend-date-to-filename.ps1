# ============================================================================
# Blog Post Date Prefix Fixer
# ============================================================================
# 
# DESCRIPTION:
#   Fixes filenames of blog posts by reading the date from Jekyll frontmatter
#   and ensuring the filename starts with YYYY-MM-DD prefix.
#
# USAGE:
#   .\fix-blog-dates.ps1
#
# EXAMPLES:
#   # Fix all blog posts
#   .\fix-blog-dates.ps1
#
#   # Dry run (preview changes without renaming)
#   .\fix-blog-dates.ps1 -DryRun
#
# ============================================================================

param(
    [switch]$DryRun = $false
)

$blogPath = "blog"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Blog Post Date Prefix Fixer" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be renamed`n" -ForegroundColor Yellow
}

# Get all markdown files in blog folder
$mdFiles = Get-ChildItem -Path $blogPath -Filter "*.md" | Sort-Object Name

if ($mdFiles.Count -eq 0) {
    Write-Host "No markdown files found in /$blogPath/ folder" -ForegroundColor Red
    exit
}

Write-Host "Found $($mdFiles.Count) blog post(s) to check`n" -ForegroundColor Green

$processedCount = 0
$renamedCount = 0
$skippedCount = 0
$errorCount = 0

foreach ($file in $mdFiles) {
    $processedCount++
    $currentName = $file.Name
    
    Write-Host "[$processedCount/$($mdFiles.Count)] Checking: $currentName" -ForegroundColor Cyan
    
    try {
        # Read file content
        $content = Get-Content $file.FullName -Raw
        
        # Extract date from Jekyll frontmatter
        if ($content -match '(?m)^date:\s*(\d{4}-\d{2}-\d{2})') {
            $date = $matches[1]
            Write-Host "  Found date: $date" -ForegroundColor DarkGray
            
            # Check if filename already has correct date prefix
            if ($currentName -match "^$date-") {
                Write-Host "  ✓ Already correct" -ForegroundColor Green
                $skippedCount++
            }
            # Check if filename has a date prefix but it's wrong
            elseif ($currentName -match '^\d{4}-\d{2}-\d{2}-(.+)$') {
                $wrongDate = $currentName.Substring(0, 10)
                $slug = $matches[1]
                $newName = "$date-$slug"
                $newPath = Join-Path $file.DirectoryName $newName
                
                Write-Host "  Wrong date prefix: $wrongDate → $date" -ForegroundColor Yellow
                Write-Host "  New name: $newName" -ForegroundColor Magenta
                
                if (-not $DryRun) {
                    if (Test-Path $newPath) {
                        Write-Host "  ✗ ERROR: Target file already exists: $newName" -ForegroundColor Red
                        $errorCount++
                    }
                    else {
                        Rename-Item -Path $file.FullName -NewName $newName
                        Write-Host "  ✓ Renamed" -ForegroundColor Green
                        $renamedCount++
                    }
                }
                else {
                    Write-Host "  [DRY RUN] Would rename" -ForegroundColor Yellow
                    $renamedCount++
                }
            }
            # Filename has no date prefix
            else {
                $newName = "$date-$currentName"
                $newPath = Join-Path $file.DirectoryName $newName
                
                Write-Host "  Adding date prefix" -ForegroundColor Yellow
                Write-Host "  New name: $newName" -ForegroundColor Magenta
                
                if (-not $DryRun) {
                    if (Test-Path $newPath) {
                        Write-Host "  ✗ ERROR: Target file already exists: $newName" -ForegroundColor Red
                        $errorCount++
                    }
                    else {
                        Rename-Item -Path $file.FullName -NewName $newName
                        Write-Host "  ✓ Renamed" -ForegroundColor Green
                        $renamedCount++
                    }
                }
                else {
                    Write-Host "  [DRY RUN] Would rename" -ForegroundColor Yellow
                    $renamedCount++
                }
            }
        }
        else {
            Write-Host "  ✗ No 'date:' field found in frontmatter" -ForegroundColor Red
            $errorCount++
        }
    }
    catch {
        Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Total processed: $processedCount" -ForegroundColor White
Write-Host "Already correct: $skippedCount" -ForegroundColor Green
Write-Host "Renamed: $renamedCount" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })
Write-Host "Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })

if ($DryRun -and $renamedCount -gt 0) {
    Write-Host "`nRun without -DryRun flag to actually rename files" -ForegroundColor Yellow
}
