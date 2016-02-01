
Get Values (Recursively if desired) from a Registry Key and return them as a Hashtable.

# Description

This returns a hashtable of all Values and Data for a given Registry Key. If the *Default* Value for a Key, is set it will be returned as `(default)`.

If the Key doesn't exist, and empty hashtable will be returned. Use `Resolve-Path` or `Test-Path` to test for the path if you want to ensure you're 

Works well with [REQUIREMENTS.json](https://github.com/UNT-CAS-ITS/ConvertFrom-Registry/wiki/REQUIREMENTS.json).

# Parameters

## Key

This is the Registry Key you want to look in.

Expects path via PSDrive for the Registry Hive; see examples.

## Ignore

List of Parameters and/or Sub-Keys that you wish to ignore.

## Recurse

Use if you want to traverse into sub-keys.

# OUTPUTS

[System.Collections.Hashtable]
[System.Boolean]::$false

# Examples

## Basic Usage

Get the Values from the supplied Key. Do not recurse.

```powershell
$reg = Resolve-Path 'HKLM:\SOFTWARE\TestApp' -ErrorAction Stop
$reg = ConvertFrom-Registry $reg
```

## One Liner, Recursive

Get the Values from the supplied Key. Recurse into sub-Keys.

```powershell
$reg = ConvertFrom-Registry (Resolve-Path 'HKLM:\SOFTWARE\TestApp' -ErrorAction Stop) -Recurse
```

# EXAMPLE

Set some Default Settings in a script, then overwrite with setting in the Registry; possibly supplied via GPO.

```powershell
$TestApp = @{}
$TestApp.Server = 'testapp.its.cas.unt.edu'
$TestApp.Format = 'html'

$TestApp_Registry = ConvertFrom-Registry -Key (Resolve-Path 'HKLM:\SOFTWARE\TestApp\' -ErrorAction Stop) -Recurse -Ignore @('Parameters')
foreach ($SettingFromGPO in $TestApp_Registry.GetEnumerator()) {
    $TestApp.($_.Name) = $_.Value
}
```

***Note:*** *This example is the reason I wrote this function.*