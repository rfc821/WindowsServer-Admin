function Resolve-SamAccountName {
<#
.SYNOPSIS
Resolves an SamAccountName in Active Directory.

.DESCRIPTION
The script can resolve an SamAccountName in Active Directory to check if it exists or not.

.PARAMETER Identity
Specify a SamAccountName

.EXAMPLE
Resolve-SamAccountName -Identity User01

.LINK
http://github.com/rfc821/WindowsServer-Admin
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]
    $Identity
)

    begin {}

    process {

            try
            {
                $Resolve = ([adsisearcher]"(samaccountname=$Identity)").findone().properties['samaccountname']
                $Properties = @{Identity = $Resolve[0];
                                State = "Success"}
            }
            catch
            {
                $Properties = @{Identity = $Identity;
                                State = "Not found in AD"}
            }

            $Object = New-Object -TypeName PSObject -Property $Properties
            Write-Output $Object

    }

    end {}

}