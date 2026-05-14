---
document type: cmdlet
external help file: PSMarkdig-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSMarkdig
ms.date: 04-28-2026
PlatyPS schema version: 2024-05-01
title: Select-MarkdigDescendant
---

## SYNOPSIS

Enumerate and select markdown elements

## SYNTAX

### __AllParameterSets

```powershell
Select-MarkdigDescendant [-Element] <MarkdownObject> [-Type <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases, `Select-MarkdigElement`

## DESCRIPTION

The `Select-MarkdigDescendant` cmdlet selects markdown elements from the input that match the given type.

## EXAMPLES

### Example 1: Select headings from a markdown document

```powershell
$doc = Import-Markdown "CHANGELOG.md"
Select-MarkdigDescendant -Element $doc -Type 'Markdig.Syntax.HeadingBlock'
```

## PARAMETERS

### -Element

The markdig element to select descendants from

```yaml
Type: Markdig.Syntax.MarkdownObject
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Type

The **fully-qualified** type name of element to return.  To see a list of types use `Get-MarkdigType`

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

Fully-qualified type name of the element to select.

### Markdig.MarkdownObject



## OUTPUTS

## NOTES

## RELATED LINKS

- [<https://github.com/xoofx/markdig/blob/main/src/Markdig/Syntax/MarkdownObjectExtensions.cs>]()
