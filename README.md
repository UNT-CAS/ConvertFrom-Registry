
Get Values (Recursively if desired) from a Registry Key and return them as a Hashtable.

Works well with [REQUIREMENTS.json](https://github.com/UNT-CAS-ITS/ConvertFrom-Registry/wiki/REQUIREMENTS.json).

# Description

This returns a hashtable of all Values and Data for a given Registry Key. If the *Default* Value for a Key, is set it will be returned as `(default)`.

# Parameters

## Key

- **Type:** `[System.Management.Automation.PathInfo]`

This is the Registry Key you want to look in.

This parameter expects apath via PSDrive for the Registry Hive. The best way to achieve this is with `Resolve-Path`; see examples.

## Ignore

- **Type:** `[System.Collections.ArrayList]`

List of Parameters and/or Sub-Keys that you wish to ignore.

## Recurse

- **Type:** `[Switch]`

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

## Use to Set Configurable Settings From the Registry

Set some Default Settings in a script, then overwrite with setting in the Registry; possibly supplied via GPO. Ignore *Parameters* and *Arguments* as they are reserved words and not configurable.

```powershell
$TestApp = @{}
$TestApp.Server = 'testapp.its.cas.unt.edu'
$TestApp.Format = 'html'
$TestApp.Parameters = $MyInvocation.BoundParameters
$TestApp.Arguments = $MyInvocation.UnboundArguments

$Key = Resolve-Path 'HKLM:\SOFTWARE\TestApp\' -ErrorAction Stop
$TestApp_Registry = ConvertFrom-Registry -Key $Key -Recurse -Ignore @('Parameters','Arguments')
foreach ($SettingFromGPO in $TestApp_Registry.GetEnumerator()) {
    $TestApp.($SettingFromGPO.Name) = $SettingFromGPO.Value
}
```

***Note:*** *This example is the reason I wrote this function.*
