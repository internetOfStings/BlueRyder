
#TODO: allow the user to pass in then root path with a param?
#TODO: also, make these _BR_..._ vars immutable

#TODO: make a singleton if possible? cant really do that in powershell from what I can tell becuase ps does not have private instance vars
#TODO: maybe if i have a class manage another instance of a class? should deff me immutable or something.
$_br_ = [hashtable]::Synchronized(@{})
$_br_.RootDir = (Get-Location).Path

$AutoLoadFiles = Get-ChildItem ($_br_.RootDir + '\Source\Autoload') | Select-Object Name,FullName | Where-Object {$_.Name -like "*.ps1"}

foreach ($file in $AutoLoadFiles) {
    . $file.FullName
}

$_br_.ServerSettings = Get-IniContent -Path ($_br_.RootDir + '\Server.ini') -SingleQuoteIsChar $false -TypeAware $true -PreserveSigFigs $true

$_br_.WebService = $_br_.ServerSettings.WebService
$_br_.WebService.TerminateServer = $false

# Create Web Service runspace (in process) and start web server
#NOTE: you cannot use synchronized data with out of process runspaces.
$WebServiceRunspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()

$WebServiceRunspace.Open() 
$WebServiceRunspace.SessionStateProxy.SetVariable('_br_', $_br_)
$WebServiceRunspace.Name = "BlueRyder WebService"
$WebServicePS = [System.Management.Automation.PowerShell]::Create()
$WebServicePS.Runspace = $WebServiceRunspace 

$WebServicePS.AddScript({ Add-Type -AssemblyName System.Web; Invoke-Expression ($_br_.RootDir + '\Source\HTTP\Kernel.ps1') }) | Out-Null

$asyncResult = $WebServicePS.BeginInvoke()

Write-Host "Server Is Running"
Write-Host "-----------------"
while ($quit -ne 'q') {
    $quit = Read-Host "Use q to terminate server: "
    if ($quit -eq 'q') {
        $_br_.WebService.TerminateServer = $true
        Invoke-Webrequest "http://$($_br_.WebService.HostListenOn):8080/"
    }
}

$output = $WebServicePS.EndInvoke($asyncResult)

$output
$WebServicePS.Dispose()
$WebServiceRunspace.Close()