param(
    [switch]$Reverse
)

Set-Location $PSScriptRoot

$from = ""
$to = ""
if ($Reverse) {
    $from = ".ahk"
    $to = ".ah2"
}
else {
    $from = ".ah2"
    $to = ".ahk"
}

# Get all files with extension $ext in the current directory and its subdirectories
$files = Get-ChildItem -Path . -Include *$from -Recurse

# If $Reverse is true, rename from .ahk to .ah2. Otherwise, rename from .ah2 to .ahk
foreach ($file in $files) {
    Rename-Item $file.FullName $file.FullName.Replace($from, $to)
}

Get-ChildItem -Path . -Include *$to -Recurse | ForEach-Object {
    (Get-Content $_) | ForEach-Object { $_ -replace $from, $to } | Set-Content $_.FullName -Encoding UTF8
}
