---
title: PSMarkdig - A module for reading, writing, and manipulating Markdown
---

Status: ![GitHub commits since tagged version (branch)](https://img.shields.io/github/commits-since/aldrichtr/PSMarkdig/0.1.0/main)

## Synopsis

Powershell already comes with some commands for viewing Markdown.  This module is intended for users that
want to be able to ***do something*** with the markdown.

## Description

Use cases include:
- Update a changelog programatically
- Lint a collection of markdown files
etc

## Notes

The underlying parser, AST, and renderer comes from the excellent [markdig](https://github.com/xoofx/markdig) library.