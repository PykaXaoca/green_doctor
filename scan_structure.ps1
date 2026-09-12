# scan_structure.ps1
# Сканирует структуру проекта и сохраняет в папку structure_report в корне проекта

$reportFolder = "structure_report"
$reportFile = "structure.txt"

$outputDir = Join-Path -Path (Get-Location) -ChildPath $reportFolder
$outputFile = Join-Path -Path $outputDir -ChildPath $reportFile

Write-Host "Сканирование структуры проекта..." -ForegroundColor Cyan
Write-Host "Корень проекта: $(Get-Location)" -ForegroundColor Yellow

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "Создана папка: $outputDir" -ForegroundColor Green
}

$excludePatterns = @(
    "\.git$",
    "\.dart_tool$",
    "\.idea$",
    "\.vscode$",
    "build$",
    "\.flutter-plugins$",
    "\.pub$",
    "\.packages$",
    "\.symlinks$",
    "Pods$",
    "\.gradle$",
    "\.settings$",
    "\.metadata$",
    "structure_report$"
)

function IsExcluded {
    param([string]$Path)
    $name = Split-Path $Path -Leaf
    foreach ($pattern in $excludePatterns) {
        if ($name -match $pattern) {
            return $true
        }
    }
    return $false
}

function Get-DirectoryTree {
    param(
        [string]$Directory,
        [string]$Indent = "",
        [bool]$IsLast = $false
    )

    $lines = @()
    $items = Get-ChildItem -Path $Directory -Force | Where-Object { -not (IsExcluded $_.FullName) } | Sort-Object -Property @{Expression = { $_.PSIsContainer }; Descending = $true }, Name
    $count = $items.Count
    $i = 0

    foreach ($item in $items) {
        $i++
        $isLastItem = ($i -eq $count)
        $connector = if ($isLastItem) { "+-- " } else { "|-- " }

        if ($item.PSIsContainer) {
            $lines += "$Indent$connector$($item.Name)/"
            $newIndent = if ($isLastItem) { "$Indent    " } else { "$Indent|   " }
            $lines += Get-DirectoryTree -Directory $item.FullName -Indent $newIndent -IsLast $isLastItem
        }
        else {
            $lines += "$Indent$connector$($item.Name)"
        }
    }
    return $lines
}

$root = Get-Location
$header = @"
Структура проекта
Корень: $root
Дата: $(Get-Date)
------------------------------------------------------------

"@

$treeLines = Get-DirectoryTree -Directory $root

$totalFolders = ($treeLines | Where-Object { $_ -match "/\s*$" }).Count
$totalFiles = ($treeLines | Where-Object { $_ -notmatch "/\s*$" }).Count
$footer = @"

------------------------------------------------------------
Итого: папок - $totalFolders, файлов - $totalFiles
"@

$fullReport = $header + ($treeLines -join "`r`n") + $footer

$fullReport | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Отчёт сохранён: $outputFile" -ForegroundColor Green
Write-Host "Папок: $totalFolders, файлов: $totalFiles" -ForegroundColor Yellow
Write-Host "Готово!" -ForegroundColor Cyan