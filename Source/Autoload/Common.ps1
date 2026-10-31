

# POST REQUEST
# GET REQUEST
# Send Mail
# AES
# Write-HostDev # Writes host if you are in dev env


<#
 # Parse .ini file to object
 # Apparently there is no official standard for .ini files so be careful of using this function.
#>
function Get-IniContent {

    param (
        [string]$Path,                      # Path to .ini file
        [bool]$TypeAware = $false,          # False - 5 = '5', True - 5 = 5 and '5' = '5', allows types of string|int|bool|float
        [bool]$SingleQuoteIsChar = $false,  # False - 'hello' = hello, True - 'hello' = 'hello'
        [bool]$DoubleQuoteIsChar = $false,  # False - "hello" = hello, True - "hello" = "hello"
        [bool]$PreserveSigFigs = $false     # False -  6.00 = 6, True - 6.00 = 6.00 (Applied when $TypeAware -eq $true)
    )
    
    $iniObject = New-Object PSObject
    $fileContents = Get-Content $Path

    # Adding an extra item allows the loop to run an extra time to terminate the last object
    $fileContents += ''
    $counter = 0;
    foreach ($c in $fileContents) {

        $counter++

        if ($c -match '^#|;') { #NOTE: comments have to be on thier own lines, cant do a inline commnent like this one, not sure if thats even normal
            continue
        } elseif (($c -match '.*\[.*]') -or ($fileContents.Count -eq $counter)) {

            if ($null -ne $hashTable) {
                $name = $objVal -replace '^\[|]$', ''
                Add-Member -InputObject $iniObject -MemberType NoteProperty -Name $name -Value $hashTable
            }
            $hashTable = @{}
            $objVal = $c

        } elseif ($null -ne $objVal -and $c -match '.*=.*') {

            $split = $c -split "=" #TODO: probably gonna have to do something different here because what if there are 3 = on the line, like in a string. use .split() regex i think

            $key = $split[0].Trim()
            $value = $split[1].Trim()

            if ($TypeAware -and $value -match '^[-]?\d+$') {

                #Use type inference to cast to the correct number data type.
                $value = +$value 

            } elseif ($TypeAware -and $value -match '^[-]?\d+\.\d+$'){

                if ($PreserveSigFigs) {

                    $castVal = +$value

                    # Cast as sig fig if the normal cast does not match the original length (meaning it was shortened).
                    #WARN: will trigger with leading zeros, like 002 will always be a 2 of type decimal
                    if ($value.Length -eq $castVal.Length) {
                        $value = $castVal
                    } else {
                        $value = +($value + 'd')
                    }
                } else {
                    $value = +$value
                }
            } elseif ($TypeAware -and $value.ToLower() -eq 'true' -or $value.ToLower() -eq 'false') {
                $value = [boolean]$value
            } else {

                $textStriped = $false
                if (-not $SingleQuoteIsChar -and $value -match "^'.*'$") {
                    $value = $value -replace "^'|'$", ''
                    $textStriped = $true # prevents the text from being striped twice.
                }

                if (-not $DoubleQuoteIsChar -and $value -match '^".*"$'-and -not $textStriped ) {
                    $value = $value -replace '^"|"$', ''
                }
            }
            $hashTable.Add($key, $value)
        }
    }
    return $iniObject
}
