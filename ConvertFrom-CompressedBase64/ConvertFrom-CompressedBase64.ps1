function ConvertFrom-CompressedBase64 {
    [cmdletbinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true
        )]
        [string] $InputObject
    )
    $binarydata = [System.Convert]::FromBase64String($InputObject)
    $ms = New-Object System.IO.MemoryStream
    $ms.Write($binaryData, 0, $binaryData.Length)
    $null = $ms.Seek(0,0)
    $cs = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]"Decompress")
    $sr = New-Object System.IO.StreamReader($cs)
    $sr.ReadToEnd()    
}
