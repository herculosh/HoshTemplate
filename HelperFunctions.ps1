
function Get-ScriptName
{
    $myInvocation.ScriptName
}


function LoadIniSource
{
    param([System.String] $IniPath = $PWD, [System.String] $IniFile)
    $IniFilePath = join-path $IniPath -childPath $IniFile

    $source = $null
    $extension = $null
    $info = new-object System.IO.FileInfo($IniFilePath)
    $extension = $info.Extension

    [System.Reflection.Assembly]::LoadFile((join-Path $IniPath -childPath "Components\Nini\Nini.dll")) | out-null

    switch ($extension)
    {
        ".ini"
        {
            $source = new-object Nini.Config.IniConfigSource($IniFilePath)
            break
        }
        ".config"
        {
            $source = new-object Nini.Config.DotNetConfigSource($IniFilePath)
            break
        }
        ".xml"
        {
            $source = new-object Nini.Config.XmlConfigSource($IniFilePath)
            break
        }
        default
        {
            $this.ThrowError("Unknown config file type")
            break
        }
    }

    return $source
}

