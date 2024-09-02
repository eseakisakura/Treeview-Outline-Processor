[string] $path= $Args

[byte[]] $byte_str= "","",""	# 3byte


$fs= New-Object System.IO.FileStream($path, [System.IO.FileMode]::Open)

$fs.Read($byte_str, 0, 3) > $null

$fs.Close()

[string] $bom= "EF-BB-BF"

[string] $tt= [System.BitConverter]::ToString($byte_str)
write-host ("read 3byte hex: "+ $tt)

if($bom -eq $tt){
	return "utf8BOM"
}else{
	return ""
}
