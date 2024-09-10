# GetEncoding(932)使用するため.NetCore対応 - ps5,7両対応の場合不要 
# [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)

[string] $path= $Args

[byte[]] $byte_str= "","",""	# 3byte

[object] $fs= New-Object System.IO.FileStream($path, [System.IO.FileMode]::Open)
$fs.Read($byte_str, 0, 3) > $null
$fs.Close()


[string] $bom= "EF-BB-BF"

[string] $tt= [System.BitConverter]::ToString($byte_str)
write-host ""
write-host ("read 3byte hex: "+ $tt)


[string] $output= ""
[string] $ss= ""

if($bom -eq $tt){
	$ss= "UTF8bom"
	[object] $bom= New-Object System.Text.UTF8Encoding($True)
	$output= [System.IO.File]::ReadAllText($path, $bom)

}else{
	[object] $nobom= New-Object System.Text.UTF8Encoding($False)	# UTF8nobom

	[string] $u8= [System.IO.File]::ReadAllText($path, $nobom)
	[string] $sf= [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(932))	# shiftJIS

	[int] $u8_len= [System.Text.Encoding]::UTF8.GetByteCount($u8)
	[int] $sf_len= [System.Text.Encoding]::UTF8.GetByteCount($sf)


	[string] $u8_rep= $u8.Replace("?", "")	# 代用文字以外の文字列
	[string] $sf_rep= $sf.Replace("?", "")	# U+0081

	$u8_len+= ($u8.Length- $u8_rep.Length)*12	# 代用文字へ 12byteのペナルティ
	$sf_len+= ($sf.Length- $sf_rep.Length)*12

	Write-Host ("u8_len: "+ $u8_len)
	Write-Host ("sf_len: "+ $sf_len)

	if($u8_len -lt $sf_len){
		$ss= "UTF8nobom"
		$output= $u8
	}else{
		$ss= "shiftJIS"
		$output= $sf
	}

	Write-Host "-- "+$ss +"--"
}

return ($output, $ss)
 
