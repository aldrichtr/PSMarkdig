
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

using namespace Markdig
using namespace Markdig.Syntax

class MarkdigTypeCompleter : IArgumentCompleter {

  [string] $Mode

  # Constructor
  MarkdigTypeCompleter([string] $m) {
    if ([string]::IsNullorEmpty($m)) {
      $this.Mode = 'FullName'
    } else {
      $this.Mode = $m
    }
  }

  # Completion method. Called from completion action
  [IEnumerable[ CompletionResult]]CompleteArgument(
    [string] $commandName,
    [string] $parameterName,
    [string] $wordToComplete,
    [CommandAst] $commandAst,
    [IDictionary] $fakeBoundParameters
  ) {

    $resultList = [List[CompletionResult]]::new()

    [Markdown].Assembly.GetTypes()
    | Where-Object { $_.IsSubclassOf([MarkdownObject]) }
    | Select-Object -Property @('Name', 'FullName', 'BaseType')
    | ForEach-Object {
      $type = $_
      switch -Regex ($this.Mode) {
        '^[nN]ame' {
          # 'Name', or 'name'
          if ($type.Name -like "$wordToComplete*") {
            $resultList.Add([CompletionResult]::new(
                $type.Name,     # text inserted
                $type.Name,     # list display
                'ParameterValue',
                ('{0} ({1})' -f $type.FullName, $type.BaseType)          # tooltip
              ))
          }
          continue
        }
        '^[fF]ull([nN]ame)?' {
          # 'Full', 'full', 'FullName' ...
          if ($type.Name -like "$wordToComplete*") {
            $resultList.Add([CompletionResult]::new(
                $type.FullName,     # text inserted
                $type.FullName,     # list display
                'ParameterValue',
                ('{0} ({1})' -f $type.FullName, $type.BaseType)          # tooltip
              ))
          }
          continue
        }
      }
    }
    return $resultList
  }
}

class MarkdigTypeCompletionsAttribute : ArgumentCompleterAttribute, IArgumentCompleterFactory {
  [string]$Mode

  MarkdigTypeCompletionsAttribute([string]$mode) {
    $this.Mode = $mode
  }

  [IArgumentCompleter] Create() { return [MarkdigTypeCompleter]::new($this.Mode) }
}
