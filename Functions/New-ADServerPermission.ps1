function New-ADServerPermission {
<#
.SYNOPSIS
Prepares a new server with AD permissions for Local Administrator access.

.DESCRIPTION
The script creates a new Domain Local Group (DL). This DL group will be added
to the Local Administrator group of the Server.

In compliance with AGDLP a Global Group (G) get's member of the DL.

.PARAMETER Computername
Specify a single computer or a series of computers.

.PARAMETER Department
Specify the Global Group to get permission to this server.
This may be a Global Group for a team.

.EXAMPLE
.\New-ServerPermission.ps1 -Computername Server01 -Department Contoso_Team01_Admin

.EXAMPLE
Import-Csv .\server.csv | New-AdminUser -Verbose

.NOTES
OU is hardcoded in begin-Block:
ou=Permissions,ou=Groups,ou=Administration

.LINK
http://github.com/rfc821/WindowsServer-Admin
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$true)]
    [string]$Computername,
    [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$true)]
    [ValidateSet("Contoso_Team01_Admin","Contoso_Team02_Admin","Contoso_Team03_Admin","Contoso_Team04_Admin")]
    [string]$Department
)

begin {

    $ou = 'ou=Permissions,ou=Groups,ou=Administration'
    $ErrorActionPreference = 'Stop'
    $domain = Get-ADDomain
    $dn = $domain.DistinguishedName

}

process {

    foreach ($Server in $Computername) {

        try {
            Write-Verbose "Verabeite $Computer"
            $Group = 'Contoso_', $Server -join ''
            $State = 'Undefined'

            Write-Verbose "Erstelle AD Gruppe $Group"
            New-ADGroup -Name $Group -SamAccountName $Group -GroupCategory "Security" -GroupScope "DomainLocal" -Path "$ou,$dn" -Description "Local Administrators on Server $Computer"

            Write-Verbose "Setze Berechtigungen auf Remotesystem"
            $z = 0

            while (($State -ne 'Success') -and ($z -lt 50)) {
                Start-Sleep -Milliseconds 500
                $z++
                $Remotesystem = (Add-LocalAdministrator -Computername $Server -Identity $Group)
                $State = $Remotesystem.State
                Write-Verbose "Versuch $z ... Status ""$State"""
            }
            if ($State -ne 'Success') { throw "Function Add-LocalAdministrator failed" }

            Write-Verbose "Erzeige Mitgliedschaft in $Department"
            Add-ADGroupMember -Identity $Group -Members $Department
        }

        catch {
            Write-Debug 'Catch Error'
            $State = $_.Exception.Message
        }

        $Properties = @{Computername = $Computer;
                        State = $State}
        $Object = New-Object -TypeName PSObject -Property $Properties
        Write-Output $Object

    }

}

end {}

}