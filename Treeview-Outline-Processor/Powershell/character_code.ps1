[string] $path= $Args

[System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance) # GetEncoding(932)のための.NetCore対応

[string] $utf8= [System.IO.File]::ReadAllText($path)	# UTF8
[string] $shift= [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(932))	# shiftJIS

[int] $utf8Len= [System.Text.Encoding]::UTF8.GetByteCount($utf8)
[int] $shiftLen= [System.Text.Encoding]::UTF8.GetByteCount($shift)


[string] $utf8Rep= $utf8.Replace("", "")	# 代用文字以外の文字列
[string] $shiftRep= $shift.Replace("", "")	# U+0081

$utf8Len+= 12* ($utf8.Length- $utf8Rep.Length)	# 代用文字へ、12byteのペナルティ
$shiftLen+= 12* ($shift.Length- $shiftRep.Length)

write-host ("utf8Len: "+ $utf8Len)
write-host ("shiftLen: "+ $shiftLen)


if($utf8Len -lt $shiftLen){
	return ""
}else{
	return "OEM"
}
