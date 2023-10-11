Set-Location $PSScriptRoot

# Get all .ah2 files in the current directory and its subdirectories
$ah2files = Get-ChildItem -Path . -Include *.ah2 -Recurse

# Rename each .ah2 file to .ahk
foreach ($file in $ah2files) {
    Rename-Item $file.FullName $file.FullName.Replace(".ah2", ".ahk")
}
