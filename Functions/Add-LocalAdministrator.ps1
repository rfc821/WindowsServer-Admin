function Add-LocalAdministrator {
<#
.SYNOPSIS
Add an AD user or group to the Local Administrator group.

.DESCRIPTION
The script can use a computer name as input and will add the identity (user or group) as an administrator to the computer.

.PARAMETER Computername
Specify a single computer or a series of computers.

.PARAMETER Identity
SamAccountName of user or group that shall be added to the Local Administrator group.

.EXAMPLE
Add-LocalAdministrator.ps1 -Computername Server01 -Identity User01

Adds User01 as an administrator to the computer Server01

.LINK
http://github.com/rfc821/WindowsServer-Admin
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]
    $Computername,
    [Parameter(Mandatory=$True)]
    [string]
    $Identity
)

    if ($Identity -notmatch '\\') {
        $SAMResolved = (Resolve-SamAccountName -Identity $Identity)
        $SAMResolvedState = $SAMResolved.State
        $SAMResolvedIdentity = $SAMResolved.Identity

        if ($SAMResolvedState -eq 'Success') {
            $Identity = 'WinNT://',"$env:userdomain",'/',$SAMResolvedIdentity -join ''
        }
        else {

            $Properties = @{Computername = $Computername;
                            State = "$SamResolvedState"}
        }

    }
    else {

        $SAMResolved = ($Identity -split '\\')[1]
        $DomainResolved = ($Identity -split '\\')[0]
        $Identity = 'WinNT://',$DomainResolved,'/',$SAMResolved -join ''

    }


    if ($SAMResolvedState -eq 'Success')
    {
	    [string[]]$Computername = $Computername.Split(',')
        foreach ($Server in $Computername) {	    

		    try {

			        ([ADSI]"WinNT://$Server/Administrators,group").add($Identity)

                    $Properties = @{Computername = $Server;
                                    State = 'Success'}


		    } catch {

                    $State = $_.Exception.Message
                    $Properties = @{Computername = $Server;
                                    State = $State}
                    

		    }

	    }
    }

    $Object = New-Object -TypeName PSObject -Property $Properties
    Write-Output $Object
}
