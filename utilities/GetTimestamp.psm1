<#
.SYNOPSIS
Retrieves the current timestamp in the format "HH:mm:ss.fff".

.DESCRIPTION
This function returns the current timestamp in the format "HH:mm:ss.fff", where:
- HH represents hours in 24-hour format.
- mm represents minutes.
- ss represents seconds.
- fff represents milliseconds.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
GetTimestamp
Returns the current timestamp in the format "HH:mm:ss.fff".

#>
function GetTimestamp {
    return (Get-Date -Format "HH:mm:ss.fff") + " - "
}
