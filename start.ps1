param(
    [ValidateSet("DEV-X","DEV-B","DEV-A")]
    [String]	$ProcessName = "DEV-X",
    [String] 	$ConfigIni = ("CIConfig-{0}.Ini" -f $ProcessName),
    [String]	$LoggingConfig = ("DefaultLog.Config" -f $ProcessName),
    [switch]$Debug
)

$ScriptPath = (Split-Path -Parent $MyInvocation.MyCommand.Path)

if ($PWD -ne (convert-path $PWD)) {
    cd (convert-path $PWD)    
}
# Begin Log4Net Initialization...
$env:EnvironmentLogs = join-path $ScriptPath "LOGS"

[void][Reflection.Assembly]::LoadFrom((join-path $ScriptPath "\Components\log4net\log4net.dll"))
$file = new-object System.IO.FileInfo((join-path $ScriptPath -child $LoggingConfig))

[log4net.LogManager]::ResetConfiguration()
[log4net.Config.XmlConfigurator]::Configure($file)
$Log = [log4net.LogManager]::GetLogger($ProcessName)

#Disable Email Notification for DEV environments
if ($ProcessName -match "DEV" -or $Debug) {
    $null = $log.Logger.Parent.RemoveAppender("SmtpAppender")
    $log.Info("Log4Net Email notification has been disabled")

    if($Debug)
    {
        $log.Logger.Parent.Level = [log4net.Core.Level]::Debug
    }
}
# End Log4Net Initialization...

. (join-path ($PWD) "HelperFunctions.ps1")
# Try to load Ini Files
$Config = LoadIniSource -IniFile (join-path "Config" $ConfigIni)


[string]	$ScriptName = (Get-ScriptName).Substring((Get-ScriptName).LastIndexOf("\") + 1)
[string]	$sourcePath = $Config.Configs["Application"].Get("SourcePath")
[string]	$sourceFiles = $Config.Configs["Application"].Get("SourceFiles")
[String]    $usingServiceCenter = $Config.Configs["Application"].Get("ServiceCenter")

[string]	$targetBasePath = $Config.Configs["Targets"].Get("basepath")
[string]	$targetFileHosts = $Config.Configs["Targets"].Get("hosts")
[string]	$targetFileApplications = $Config.Configs["Targets"].Get("applications")
[string]	$targetFileApplicationdetails	= $Config.Configs["Targets"].Get("applicationdetails")
[string]	$targetFileContactgroups	= $Config.Configs["Targets"].Get("contactgroups")

$Log.Info("CONFIGURATION INI SETTINGS");
$Log.Info(("`tVariable: {0,-20} -> {1}" -f "usingServiceCenter", $usingServiceCenter));
$Log.Info(("`tVariable: {0,-20} -> {1}" -f "ScriptPath", $ScriptPath));
$Log.Info(("`tVariable: {0,-20} -> {1}" -f "sourceFiles", $sourceFiles));
$Log.Info(("`tVariable: {0,-20} -> {1}" -f "usingServiceCenter", $usingServiceCenter));
write-host ""
$Log.Info("CONFIGURATION VARIABLES FOR TARGETS");
$Log.Info(("`tVariable: targetBasePath -> {0}" -f $targetBasePath));
$Log.Info(("`tVariable: targetFileHosts -> {0}" -f $targetFileHosts));

$sourceFiles = $sourceFiles -f $usingServiceCenter
$log.Debug(("Source File: {0}" -f $sourceFiles))


$targetSCPath = ($targetBasePath -f $usingServiceCenter)
$log.Debug(("Traget Service Center Path: {0}" -f $targetSCPath))

if (test-path $targetSCPath)
{
    $Log.Error(("Pfad {0} existiert schon!" -f $targetSCPath))
}
$log.Debug(("Create new Item: {0}" -f $targetSCPath))
new-item $targetSCPath -ItemType directory -ea Ignore -Verbose:$Debug


copy-item C:\temp\test_inuse.csv (join-path $targetSCPath ($targetFileHosts -f $usingServiceCenter)) -Force
    
[log4net.LogManager]::ResetConfiguration()

