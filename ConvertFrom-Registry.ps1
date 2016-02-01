<#
.SYNOPSIS
Get Values (Recursively if desired) from a Registry Key and return them as a Hashtable.
.DESCRIPTION
This returns a hashtable of all Values and Data for a given Registry Key. If the *Default* Value for a Key, is set it will be returned as `(default)`.

If the Key doesn't exist, and empty hashtable will be returned. Use `Resolve-Path` or `Test-Path` to test for the path if you want to ensure you're 

Works well with [REQUIREMENTS.json](https://github.com/UNT-CAS-ITS/ConvertFrom-Registry/wiki/REQUIREMENTS.json).
.PARAMETER Key
This is the Registry Key you want to look in.

Expects path via PSDrive for the Registry Hive; see examples.
.PARAMETER Ignore
List of Parameters and/or Sub-Keys that you wish to ignore.
.PARAMETER Recurse
Use if you want to traverse into sub-keys.
.OUTPUTS
[System.Collections.Hashtable]
[System.Boolean]::$false
.EXAMPLE
PS > $reg = Resolve-Path 'HKLM:\SOFTWARE\TestApp' -ErrorAction Stop
PS > $reg = ConvertFrom-Registry $reg
.EXAMPLE
PS > $reg = ConvertFrom-Registry (Resolve-Path 'HKLM:\SOFTWARE\TestApp' -ErrorAction Stop) -Recurse
.EXAMPLE
# Set Default Settings in a script, then overwrite with setting in the Registry; possibly supplied via GPO.
PS > $TestApp = @{}
PS > $TestApp.Server = 'testapp.its.cas.unt.edu'
PS > $TestApp.Format = 'html'
PS > (ConvertFrom-Registry -Key (Resolve-Path 'HKLM:\SOFTWARE\TestApp\' -ErrorAction Stop) -Recurse -Ignore @('Parameters')).GetEnumerator() | %{ $TestApp.($_.Name) = $_.Value }
.NOTES
Author: Raymond Piller (VertigoRay)

Copyright 2016 University of North Texas,
               College of Arts & Sciences,
               IT Services

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
.LINK
http://github.com/UNT-CAS-ITS/ConvertFrom-Registry
#>
function ConvertFrom-Registry {
    #Requires -Version 1.0
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [System.Management.Automation.PathInfo] $Key
        ,
        [Parameter(Mandatory=$false,Position=2)]
        [System.Collections.ArrayList]          $Ignore = @()
        ,
        [switch]                                $Recurse
    )

    try {
        $Key = Resolve-Path $Key -ErrorAction Stop
    } catch [System.Management.Automation.ItemNotFoundException] {
        # Should never error unless someone is really trying to mess with me.
        Write-Error $_
        return $false
    }
    Write-Verbose "[$($MyInvocation.MyCommand)] Key: $($Key.Name)"

    # Also Ignore PowerShell descriptors
    @('PSChildName', 'PSDrive', 'PSParentPath', 'PSPath', 'PSProvider') | %{ $Ignore.Add($_) | Out-Null }

    $Hive = (Get-Item $Key).PSDrive.Name

    $return_reg = @{}
    
    if ($Key) {
        foreach ($item in ((Get-ItemProperty $Key).PSObject.Members | ?{ $_.MemberType -eq 'NoteProperty'})) {
            if ($Ignore -inotcontains $item.Name) {
                Write-Verbose "[$($MyInvocation.MyCommand)] Adding Key: $($item.Name): $($item.Name)"
                $return_reg.Add($item.Name, $item.Value)
            }
        }

        if ($Recurse) {
            foreach ($child in (Get-ChildItem $Key)) {
                if ($Ignore -inotcontains $child.Name.Split('\')[-1]) {
                    $Key = Resolve-Path ($child.Name.Replace($child.Name.Split('\')[0], "${Hive}:"))
                    Write-Verbose "[$($MyInvocation.MyCommand)] Child: $($child.Name)"
                    if (Test-Path $Key) {
                        $return_reg.Add($child.Name.Split('\')[-1], (ConvertFrom-Registry -Key (Resolve-Path $Key -ErrorAction Stop) -Recurse))
                    } else {
                        # This should never fail, but if it does I want to know.
                        Write-Warning "Unable to find path: ${Key}"
                    }
                }
            }
        }
    } else {
        # This should never fail, but if it does I want to know.
        Write-Warning "Unable to find path: ${Key}"
    }

    return $return_reg
}
