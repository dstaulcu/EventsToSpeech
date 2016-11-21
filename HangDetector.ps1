function Get-WindowStatus
{
[CmdletBinding()]
[Alias()]
[OutputType([bool])]
Param (
    [Parameter(Mandatory=$true,Position=0)]
    $hWnd
)

$MethodDefinition = @"
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
static extern bool IsHungAppWindow(IntPtr hWnd);
"@

Add-Type -MemberDefinition $MethodDefinition -Namespace 'My' -Name 'WinApi' -ErrorAction SilentlyContinue -PassThru

$result = [my.WinApi]::IsHungAppWindow($hWnd)

 
write-host 'Check-IsHungAppWindow: ' + $result

return $result
}


# Loop for specified period of time for testing
$number = 1
$i = 1

$testProcess = 'VirtMemTest64'

do{
    write-host "loop $i of $number"
    sleep  1
    $i++ 

    if (Get-Process -Name $testProcess -ErrorAction SilentlyContinue) {
        $process = Get-Process -Name $testProcess
        Write-Host $testProcess + ' is running!'
        Check-IsHungAppWindow -hwnd $process.MainWindowHandle
    }
}
while ($i -le $number)