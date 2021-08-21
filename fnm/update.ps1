import-module au

$releases = 'https://github.com/Schniz/fnm/releases/latest'

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
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re = 'fnm-windows\.zip$'
    $url = $download_page.links | ? href -match $re | select -First 2 -expand href | % { 'https://github.com' + $_ }

    $tag = $url -split '/' | select -Last 1 -Skip 1
    $version = $tag.trimstart('v')

    @{
        Version = $version
        URL64 = $url
        ReleaseNotes = "https://github.com/Schniz/fnm/releases/tag/${tag}"
    }
}

update -ChecksumFor none
