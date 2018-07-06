Write-Host " "
Write-Host " "


Write-Host "[$(Get-Date)] Build solution." -ForegroundColor Green
Write-Host " "
dotnet build solution_name.sln

Write-Host " "
Write-Host "[$(Get-Date)] copy file pre-push to local hook git." -ForegroundColor Green
$prePush="`#!/bin/sh
RED=`'\033[0;31m`'
GREEN=`'\033[1;32m`'
YELLOW=`'\033[1;33m`'
NO_COLOR=`'\033[0m`'

`#`#`#`#`#`#`# HOOK BUILD PROJECTS `#`#`#`#`#`#`#`#`#`#`#`#`#
dotnet build solution_name.sln

rc=`$?

if [[ `$rc != 0 ]] ; then
	echo -e `"`${RED}Error build project`${NO_COLOR}`"
	echo `"`"
	exit `$rc
fi

`#`#`#`#`#`#`# HOOK BUILD PROJECTS `#`#`#`#`#`#`#`#`#`#`#`#

`#`#`#`#`#`#`# HOOK TEST PROJECTS `#`#`#`#`#`#`#`#`#`#`#`#`#

dotnet test --no-build .\\project_test\\ --filter `"(FullyQualifiedName~Tests.Core) | (FullyQualifiedName~Tests.Query)`"

rc=`$?

if [[ `$rc != 0 ]] ; then
	echo -e `"`${RED}Error test project`${NO_COLOR}`"
	echo `"`"
	exit `$rc
fi

`#`#`#`#`#`#`# HOOK TEST PROJECTS `#`#`#`#`#`#`#`#`#`#`#`#`#

exit 0
"

$prePush | out-file -FilePath ".\.git\hooks\pre-push" -Encoding UTF8

#Convert file dos to unix
Get-ChildItem ".\.git\hooks\pre-push" | ForEach-Object {
  $contents = [IO.File]::ReadAllText($_) -replace "`r`n?", "`n"
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [IO.File]::WriteAllText($_, $contents, $utf8)
}

Write-Host " "
Write-Host "[$(Get-Date)] SUCCESS!!! " -ForegroundColor Blue
