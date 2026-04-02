# This script helps creating project files for re2.  The argument is the path of Google\re2.
# It produces one pair of *.vcxproj, *.vcxproj.filters files for each project.  The generated
# XML may just be inserted at the right place in the project files, replacing whatever was there.

$dir = resolve-path $args[0]

$filtersheaders = "  <ItemGroup>`r`n"
$vcxprojheaders = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\re2\*" -Include re2.h,stringpiece.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\re2\\", "..\..\re2\"
  $filtersheaders +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojheaders +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
$filtersheaders += "  </ItemGroup>`r`n"
$vcxprojheaders += "  </ItemGroup>`r`n"

$filtersinternals = "  <ItemGroup>`r`n"
$vcxprojinternals = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\re2\*" -Include *.h -Exclude re2.h,stringpiece.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\re2\\", "..\..\re2\"
  $filtersinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\util\*" -Include *.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\util\\", "..\..\util\"
  $filtersinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
$filtersinternals += "  </ItemGroup>`r`n"
$vcxprojinternals += "  </ItemGroup>`r`n"

$filterssources = "  <ItemGroup>`r`n"
$vcxprojsources = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\re2\*" -Include *.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\re2\\", "..\..\re2\"
  $filterssources +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojsources +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\util\*" -Include *.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\util\\", "..\..\util\"
  $filterssources +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojsources +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterssources += "  </ItemGroup>`r`n"
$vcxprojsources += "  </ItemGroup>`r`n"

$filterstests = "  <ItemGroup>`r`n"
$vcxprojtests = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\re2\testing\*" -Include *.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\re2\\testing\\", "..\..\re2\testing\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\re2\testing\*" -Include *.cc -Exclude *_benchmark.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\re2\\testing\\", "..\..\re2\testing\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterstests += "  </ItemGroup>`r`n"
$vcxprojtests += "  </ItemGroup>`r`n"

$filtersbenchmarks = "  <ItemGroup>`r`n"
$vcxprojbenchmarks = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\re2\testing\*" -Include backtrack.cc,*_benchmark.cc,null_walker.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\re2\\testing\\", "..\..\re2\testing\"
  $filtersbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filtersbenchmarks += "  </ItemGroup>`r`n"
$vcxprojbenchmarks += "  </ItemGroup>`r`n"

$dirfilterspath = [string]::format("{0}/re2_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $dirfilterspath,
    $filtersheaders + $filtersinternals + $filterssources,
    [system.text.encoding]::utf8)

$testsfilterspath = [string]::format("{0}/tests_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $testsfilterspath,
    $filterstests,
    [system.text.encoding]::utf8)

$benchmarksfilterspath = [string]::format("{0}/benchmarks_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $benchmarksfilterspath,
    $filtersbenchmarks,
    [system.text.encoding]::utf8)

$dirvcxprojpath = [string]::format("{0}/re2_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $dirvcxprojpath,
    $vcxprojheaders + $vcxprojinternals + $vcxprojsources,
    [system.text.encoding]::utf8)

$testsvcxprojpath = [string]::format("{0}/tests_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $testsvcxprojpath,
    $vcxprojtests,
    [system.text.encoding]::utf8)

$benchmarksvcxprojpath = [string]::format("{0}/benchmarks_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $benchmarksvcxprojpath,
    $vcxprojbenchmarks,
    [system.text.encoding]::utf8)
