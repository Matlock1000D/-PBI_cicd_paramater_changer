Param(
    [String]$Workfolder
)
# Käydään läpi kaikki raportit ja etsitään parametrit
# Oltava .tmdl-muodossa
$files = Get-ChildItem -Path $Workfolder -File -Filter expressions.tmdl -Recurse | Where-Object {($_.Directory.Name -match 'definition') -and ($_.Directory.Parent.Name -like '*.Dataset') }
Write-Host "Työhakemisto: $Workfolder"
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName
    $newcontent = @()
    foreach ($line in $content) {
        $target = $null
        $replacer = $null
        $newline = $line
        if ($line -match "^expression") {
            if ($line -match '= "(.*?)"') {
                $target = $Matches[1]
                if ($line -match '"([^"]*)"(?=[^"]*})') {
                    $replacer = $Matches[1]
                } else {
                    Write-Host "Ei löydetty parametria, jolla korvata, riviltä $line."
                }
            } else {
                Write-Host "Ei löydetty korvattavaa parametria riviltä $line."
            }
            if (($null -ne $target) -and ($null -ne $replacer)) {
                $target = [regex]$target
                $newline = $target.Replace($line, $replacer, 1)
            }
        }
        $newcontent += $newline
    }
    $newcontent | Set-Content -Path $file.FullName
}
