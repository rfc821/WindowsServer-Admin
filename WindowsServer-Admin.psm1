$ModuleRoot = Split-Path -Parent $PSCommandPath;
Get-ChildItem -Path "$ModuleRoot\Functions\" -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose "Loading Function ""$_.FullName""";
        . $_.FullName;
    }

$exportedFunctions = @(
  'Add-LocalAdministrator',
  'Resolve-SamAccountName',
  'New-ADServerPermission'
);

Export-ModuleMember -Function $exportedFunctions;