# powershell.exe -ExecutionPolicy RemoteSigned -NoExit -Sta -File コンパイルスタート.ps1
<#
Function Split_path([string]$f){ 

  [string[]]$out= "","","",""

  if($f -eq ""){ $f= "unknown" }
  # pathないと通らない仕様ため

  $out[0]= [System.IO.Path]::GetFileName($f)
  $out[1]= [System.IO.Path]::GetDirectoryName($f)
  $out[2]= [System.IO.Path]::GetFileNameWithoutExtension($f)
  $out[3]= [System.IO.Path]::GetExtension($f)

  return $out

 } #func
#>
 
echo "Path :" 
# 64でもexeは同じものが出る
# $Env:Path+= ";C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\"
$Env:Path+= ";C:\Windows\Microsoft.NET\Framework64\v4.0.30319\"
echo $Env:Path
echo ""

cd (Split-Path -Parent $PSCommandPath)
[Environment]::CurrentDirectory= pwd # working_dir set

# [string[]] $args_path= Split_path $Args[0]
# [string] $exe_path= (Join-Path $args_path[1] $args_path[2])+ ".exe"

# write-host ""
# write-host $Args[0]
# write-host $exe_path
# write-host ""

# csc -out:$exe_path $Args[0]
csc -out:form-test.exe .\*.cs # .\exe\*.cs .\exe\main-parts\*.cs

write-host "`r`n compile Fin."
read-host "pause -- next Lunch Build"

.\form-test.exe

# ----以降メモ
# 32bit dll使用の場合 x86でexeを出力
# csc -platform:x86 -out:$exe_path $Args[0]

# コンソール
#csc .\new2_watch.cs
#csc .\new2_fm.cs
#csc .\new2_arp.cs
# 実行ファイル
#csc -target:winexe -win32icon:MW_icon.ico .\new2_watch.cs
#csc -target:winexe -win32icon:FE_icon.ico .\new2_fm.cs
#csc -target:winexe -win32icon:AG_icon.ico .\new2_arp.cs

# ----不使用
#csc -target:library -out:common.dll -win32icon:ST_icon.ico -optimize+ .\dll\*.cs
#csc -reference:common.dll -target:winexe -win32icon:MW_icon.ico -optimize+ .\mml_watch.cs
#csc -reference:common.dll -target:winexe -win32icon:FE_icon.ico -optimize+ .\fm_editor.cs
#csc -reference:common.dll -target:winexe -win32icon:AG_icon.ico -optimize+ .\arp_gene.cs
# ----
 	
