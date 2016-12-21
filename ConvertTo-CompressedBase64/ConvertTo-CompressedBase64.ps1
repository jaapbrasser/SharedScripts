Function ConvertTo-CompressedBase64 {
    [cmdletbinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true
        )]
        [string] $InputObject
    )
    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Compress)
    $sw = New-Object System.IO.StreamWriter($cs)
    $sw.Write($InputObject.ToCharArray())
    $sw.Close()
    [System.Convert]::ToBase64String($ms.ToArray())
}