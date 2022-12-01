import-module au

$latestReleaseUrl = 'https://github.com/Schniz/fnm/releases/latest'
$assetsUrlRegex = 'https.+\/expanded_assets\/(v[0-9\.]+)'
$windowsZipRegex = 'fnm-windows\.zip$'

function global:au_SearchReplace {
   @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x64:).*" = "`${1} $($Latest.URL64)"
          "(?i)(checksum64:).*" = "`${1} $($Latest.Checksum64)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
    $latestRelease = Invoke-WebRequest -Uri $latestReleaseUrl -UseBasicParsing

    $latestRelease.content -match $assetsUrlRegex

    $assetsUrl = $Matches.0

    $assets = Invoke-WebRequest -Uri $assetsUrl -UseBasicParsing

    $url = $assets.links | Where-Object href -match $windowsZipRegex | Select-Object -First 2 -expand href | ForEach-Object { 'https://github.com' + $_ }

    $tag = $url -split '/' | Select-Object -Last 1 -Skip 1
    $version = $tag.trimstart('v')

    @{
        Version = $version
        URL64 = $url
        ReleaseNotes = "https://github.com/Schniz/fnm/releases/tag/${tag}"
    }
}

update -ChecksumFor none
