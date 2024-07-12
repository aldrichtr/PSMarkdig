---
title: 'PSMarkdig: A PowerShell module for working with markdown'
status: prerelease
---

## Synopsis

PSMarkdig is a module for parsing, modifying and writing markdown.

## Overview

PowerShell already has built in functions for _displaying_ markdown, such as
`ConvertFrom-Markdown` and `Show-Markdown`.

> **Note**
These functions use the [markdig](https://github.com/xoof/markdig) library "under-the-hood".

If your goal is to convert existing markdown content into another format, such
as HTML, then the built-in commands already provide that.

```powershell
Get-Content README.md
  | ConvertFrom-Markdown
  | Select-Object -ExpandProperty HTML
```

Similarly, if you just want to display markdown content in the console, the
built-in commands can do that too.

```powershell
Show-Markdown README.md
```

You can even get to the markdig objects using `ConvertFrom-Markdown`

```powershell
$tokens = Get-Content README.md
  | ConvertFrom-Markdown
  | Select-Object -ExpandProperty Tokens
```

But, what if you want to _modify_ a markdown document...?  such as add a
heading, use the metadata in the frontmatter, or rearrange the content? That is
where `PSMarkdig` comes in.

```powershell
$doc = README.md | Import-Markdown -Extension 'advanced+yaml'
$mainHeadings = $doc | Get-MarkdownHeading -Level 2
# Change the second heading to a sub-heading of the first
$mainHeadings
   | Select-Object -First 1 -Skip 1
   | Set-MarkdownHeading -Level 3
$doc | Write-Markdown README.md
```
