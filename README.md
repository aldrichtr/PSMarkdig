---
title: PSMarkdig - A module for reading, writing, and manipulating Markdown
Status: Prerelease
---

![GitHub commits since tagged version (branch)](https://img.shields.io/github/commits-since/aldrichtr/PSMarkdig/0.1.0/main)

## Synopsis

PowerShell already has built in functions for ***displaying*** markdown, such as
`ConvertFrom-Markdown` and `Show-Markdown`.

> **Note**
These functions use the [markdig](https://github.com/xoofx/markdig) library "under-the-hood".

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

But, what if you want to ***modify*** a markdown document...?  such as add a
heading, update the metadata in the frontmatter, or rearrange the content? That is
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
Powershell already comes with some commands for viewing Markdown.  This module is intended for users that
want to be able to ***do something*** with the markdown.

Use cases include:

- Update a changelog programatically
- Lint a collection of markdown files
etc
