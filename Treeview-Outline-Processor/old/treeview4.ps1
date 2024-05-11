Add-Type -AssemblyName System.Windows.Forms > $null 
Add-Type -AssemblyName System.Drawing > $null

cd (Split-Path -Parent $MyInvocation.MyCommand.Path)
[Environment]::CurrentDirectory= pwd # working_dir set
 
<# 
	
function Srch($x){ 

	# $x.Nodes.Count | write-host
	for([int] $i= 0; $i -lt $x.Nodes.Count; $i++){

		$y= $x.Nodes[$i]

		[string] $bookmark= ""
		if($y.Tag[2] -eq 'bookmark'){
			$bookmark= "B" # `t
		}

		# write-host("ff: "+ $y.FullPath)

		[array] $arr= $y.Tag[1] -split "`r`n"

		for([int] $j= 0; $j -lt $arr.Length; $j++){

			$script:out+= $arr[$j]

			if($y.Tag[0] -eq $j){ # title line
				$script:out+= "S"
				$script:out+= $bookmark
			}

			$script:out+= "`r`n"
		} #



		if($y.Nodes.Count -gt 0){ # child count

			$script:out+= "C"# `t

			if($y.IsExpanded -eq 'True'){ # node展開時
				$script:out+= "N"
			}
			$script:out+= "`r`n"

					#ここで、飲み込む。
			Srch $y 	# 再帰
					#段数分、ここから下へ吐き出す。

			$script:out+= "S"

		}else{		# 残り親nodeへ
			$script:out+= "S"
		}

		if($y.Tag[3] -eq 'focus'){
			$script:out+= "F"# `t
		}

		if($i -ne ($x.Nodes.Count- 1)){ # max count
			$script:out+= "`r`n"
		}
	} #
 } # func
 
function TreeBuild(){ 

	$readtext= (cat '.\TEST.txt' | Out-String)

	# $label.Length | write-host
	[string[]] $label= $readtext -split "`r`n"

	[string] $rgx= ""
	[string] $mem= ""
$script:tree.Nodes.AddRange(@("いち"))
	[array] $arr= $script:tree,  $script:tree.Nodes[0] # スタック

	[int[]] $srr= 0 #adress stuck

	for([int] $i= 0; $i -lt $label.Length; $i++){

		$rgx= [System.Text.RegularExpressions.Regex]::Matches($label[$i],"^[F|S|C|N]+$") # ^[ |\t]+$

		if($rgx -eq ""){

			$mem+= $label[$i]

		}else{
			# write-host $mem
			# $mem= ""

			if($rgx -match "^C"){ #	child # ^`t

				$y= $arr[- 1]
				$y.Nodes.AddRange(@("に"))

				$y= $y.Nodes[0]
				("push layer: "+ $y.FullPath) | write-host

				$arr+= $y
				$srr+= 0
				("push srr: "+ $srr -join ",") | write-host

			}elseif($rgx -match "^S"){

				if($rgx.Contains("F") -eq $True){ # `t

					[int] $num= $arr.Length- $rgx.IndexOf("F") # `t
					("focus index: "+ $num) | write-host

					$frr= $arr[0..$num]

					$y= $arr[- 1] # <- focus point
					("indexF: "+ $y.FullPath) | write-host

					$rgx= $rgx.Replace("F", "") # `t
				}

		if($i -eq ($label.Length- 2)){ break; }

				[int] $num= ($arr.Length- 1)- $rgx.Length
				("layer num: "+ $num) | write-host

				$arr= $arr[0..$num]

				$y= $arr[- 1]
				$y.Nodes.AddRange(@("さん"))

				$srr= $srr[0..$num]
				$srr[- 1]++;
				("layer srr: "+ $srr -join ",") | write-host

				$arr+= $y.Nodes[$srr[- 1]]
				("pop layer: "+ $y.FullPath) | write-host
			}
		}
	} #
 } #func
 
function ReverseFind($y){ 

	[int] $sw= 1
	for([int] $i= 0; $i -lt 20; $i++){

		if($sw -eq 1){

			if($y.PrevNode -ne $null){

				$y= $y.PrevNode
("fullpath: "+$y.FullPath) | write-host
			}elseif($y.Parent -ne $null){

				$y= $y.Parent
("fullpath: "+$y.FullPath) | write-host
			}else{
				$sw= 0
			}

		}else{

			if($y.PrevNode.LastNode -ne $null){

				$y= $y.PrevNode.LastNode
("fullpath: "+$y.FullPath) | write-host
				$sw= 1
			}else{
				if($y.Level -gt 0){

					$y= $y.Parent
				}else{

					break; # 突き当り
				}
			}
		}
	} #
 } #func
 
#> 
  
function ForwardFind($x){ 

	$y= $x # $script:focus
	[array] $stuck= @()

	[int] $sw= 1
	for([int] $i= 0; $i -lt 20; $i++){

		if($sw -eq 1){

			if($y.FirstNode -ne $null){

				$y= $y.FirstNode
	# ("fullpath: "+$y.FullPath) | write-host
				if($y -eq $x){ break; }
				$stuck+= $y

			}elseif($y.NextNode -ne $null){

				$y= $y.NextNode
	# ("fullpath: "+$y.FullPath) | write-host
				if($y -eq $x){ break; }
				$stuck+= $y
			}else{
				$sw= 0
			}

		}else{

			if($y.Parent.NextNode -ne $null){

				$y= $y.Parent.NextNode
	# ("fullpath: "+$y.FullPath) | write-host
				if($y -eq $x){ break; }
				$stuck+= $y
				$sw= 1
			}else{
				if($y.Level -gt 0){

					$y= $y.Parent
				}else{
					$y= $tree.TopNode
	# ("fullpath: "+$y.FullPath) | write-host
					if($y -eq $x){ break; }
					$stuck+= $y
					$sw= 1
					# break; # 突き当り
				}
			}
		}
	} #
	$stuck+= $x
	("len: "+ $stuck.Length) | write-host

	return $stuck
 } #func
 
function PasteSelecter([string] $sw){ 

	[string] $x= ""
	$x= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

	[array] $add= "", ""
	[int[]] $add[0]= 0, 1
	[int[]] $add[1]= -1, 1

	[string] $num= 0
	if($sw -eq 'add'){ $num= 1 } # $add - down paste


	if($x -eq 'tree.nodes.data.flag.clipboard'){

		$script:te= $script:mt.Clone()

		# insert - Parent node index_num

		if($focus.Level -eq 0){ ## if($focus.Parent -eq $null){
			$script:tree.Nodes.Insert(($tree.Nodes.IndexOf($focus)+ $add[0][$num]), $te)
		}else{
			$script:focus.Parent.Nodes.Insert(($focus.Parent.Nodes.IndexOf($focus)+ $add[0][$num]), $te)
		}
		$tree.SelectedNode= $script:te # refocus

	}else{
		if($focus.Level -eq 0){
			$script:tree.Nodes.Insert(($tree.Nodes.IndexOf($focus)+ $add[0][$num]), "Untitled")
			$y= $script:tree.Nodes[($focus.Parent.Nodes.IndexOf($focus)+ $add[1][$num])]
		}else{
			$script:focus.Parent.Nodes.Insert(($focus.Parent.Nodes.IndexOf($focus)+ $add[0][$num]), "Untitled")
			$y= $script:focus.Parent.Nodes[$focus.Parent.Nodes.IndexOf($focus)+ $add[1][$num] ]
		}

		[string[]] $z= $x -split "`r`n"

		$y.Tag=  (0, "")

		if($z[0] -eq ""){
			$y.Text= "Untitled"
		}else{
			$y.Text= $z[0]
			$y.Tag[1]=  $x
		}
		$tree.SelectedNode= $y # refocus
	}
 } #func
 
function Srch($x){ 

	# $x.Nodes.Count | write-host
	for([int] $i= 0; $i -lt $x.Nodes.Count; $i++){

		$y= $x.Nodes[$i]

		[string] $bookmark= ""
		if($bmk -eq $y){
			$bookmark= "B" # `t
		}

		# write-host("ff: "+ $y.FullPath)

		[array] $arr= $y.Tag[1] -split "`r`n"

		for([int] $j= 0; $j -lt $arr.Length; $j++){

			$script:out+= $arr[$j]

			if(($y.Tag[0]- 1) -eq $j){ # title line
				$script:out+= "S"
				$script:out+= $bookmark
			}

			if($j -ne ($arr.Length- 1)){ # max count
				$script:out+= "`r`n"
			}
		} #


		if($y.Nodes.Count -gt 0){ # child count

			$script:out+= "C"# `t

			if($y.IsExpanded -eq 'True'){ # node展開時
				$script:out+= "N"
			}
			$script:out+= "`r`n"

					#ここで、飲み込む。
			Srch $y 	# 再帰
					#段数分、ここから下へ吐き出す。

			$script:out+= "S"

		}else{		# 残り親nodeへ
			$script:out+= "S"
		}

		if($focus -eq $y){
			$script:out+= "F"# `t
		}

		if($i -ne ($x.Nodes.Count- 1)){ # max count
			$script:out+= "`r`n"
		}
	} #
 } # func
 
$counterbox= New-Object System.Windows.Forms.TextBox 
$counterbox.Text= "test1test2"

$counterbox.Size= "200, 100"
$counterbox.Location= "210, 410"
$counterbox.Multiline= "True"
$counterbox.AcceptsReturn= "True"
$counterbox.AcceptsTab= "True"
$counterbox.ScrollBars= "Vertical"
 
$bookbox= New-Object System.Windows.Forms.TextBox 
$bookbox.Text= "test1test2"

$bookbox.Size= "200, 200"
$bookbox.Location= "10, 210"
$bookbox.Multiline= "True"
$bookbox.AcceptsReturn= "True"
$bookbox.AcceptsTab= "True"
$bookbox.ScrollBars= "Vertical"
 
$focusbox= New-Object System.Windows.Forms.TextBox 
$focusbox.Text= "test1test2"

$focusbox.Size= "200, 200"
$focusbox.Location= "210, 210"
$focusbox.Multiline= "True"
$focusbox.AcceptsReturn= "True"
$focusbox.AcceptsTab= "True"
$focusbox.ScrollBars= "Vertical"
 
$editbox= New-Object System.Windows.Forms.TextBox 
$editbox.Text= "test1test2"

$editbox.Size= "400, 200"
$editbox.Location= "210, 10"
$editbox.Multiline= "True"
$editbox.AcceptsReturn= "True"
$editbox.AcceptsTab= "True"
$editbox.ScrollBars= "Vertical"
$editbox.WordWrap= "True"

# $editbox.SelectedText
# $editbox.SelectionLength
# $editbox.SelectionStart
 
# コンテキスト 
$contxt_03= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_03.Text= "ReSelect"
$contxt_03.Add_Click({
$tree.SelectedNode= $bmk
 })
$contxt_bmk= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_bmk.Text= "BookMark"
$contxt_bmk.Add_Click({
	$script:bmk= $focus
 })
$contxt_cut= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_cut.Text= "Cut"
$contxt_cut.Add_Click({
	[Windows.Forms.Clipboard]::SetText("tree.nodes.data.flag.clipboard", [Windows.Forms.TextDataFormat]::UnicodeText)
	$script:mt= $focus
	$script:focus.Nodes.Remove($focus)
 })

$contxt_copy= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_copy.Text= "Copy"
$contxt_copy.Add_Click({
	[Windows.Forms.Clipboard]::SetText("tree.nodes.data.flag.clipboard", [Windows.Forms.TextDataFormat]::UnicodeText)
	# $script:mt= $script:focus
 })



$contxt_paste= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_paste.Text= "Paste"
$contxt_paste.Add_Click({
	PasteSelecter ""
 })

$contxt_add= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_add.Text= "Add Paste"
$contxt_add.Add_Click({

	PasteSelecter "add"
 })

$contxt_12= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_12.Text= "Child Paste"
$contxt_12.Add_Click({

	$script:te= $script:mt.Clone()

	# $script:focus.Nodes.AddRange($te) # node list object last child paste
	$script:focus.Nodes.Insert(0, $te) # node list object first child paste

	$tree.SelectedNode= $script:te # refocus
 })

$contxt= New-Object System.Windows.Forms.ContextMenuStrip
$contxt.Items.AddRange(@($contxt_bmk, $contxt_cut, $contxt_copy, $contxt_paste, $contxt_add, $contxt_12))
$contxt.Items.Insert(0, $contxt_03) # list object
 
$tree= New-Object System.Windows.Forms.TreeView 
$tree.Size= "200, 200"
$tree.Location= "10, 10"
$tree.HideSelection= $False
# $tree.SelectedNode (equal) $_.Node

$tree.Add_AfterSelect({

	# write-host ("index: "+ $this.Nodes.IndexOf($_.Node))
	"------" | write-host
	$this.TopNode.FullPath | write-host
	$_.Node.Parent.FullPath | write-host
	$_.Node.PrevNode.LastNode.FullPath | write-host
	$_.Node.PrevNode.FullPath | write-host
	$_.Node.FullPath | write-host
	$_.Node.NextNode.FullPath | write-host
	$_.Node.FirstNode.FullPath | write-host
	"------" | write-host
	$script:focus= $_.Node

	$counterbox.Text= $_.Node.Tag[0]
	$editbox.Text= $_.Node.Tag[1]
	## $editbox.Text= $_.Node.name
	$focusbox.Text= $focus
	$bookbox.Text= $bmk
 })

$tree.Add_MouseDown({
 try{
	switch([string] $_.Button){
	'Right'{
			$contxt_paste.Enabled= [Windows.Forms.Clipboard]::ContainsText([Windows.Forms.TextDataFormat]::UnicodeText)
			$contxt.Show([Windows.Forms.Cursor]::Position)
	}'Left'{
	}'Middle'{
		Srch $tree
		write-host ("check6: --------")
		$script:out | write-host
		write-host ("check6: --------")

		$script:out | Out-File -Encoding oem -FilePath ".\TEST-01.txt" # shiftJIS
	}
	} #sw
 }catch{
	echo $_.exception
 }
 })
 
$btn0= New-Object System.Windows.Forms.Button 
$btn0.Size= "200,100"
$btn0.Location= "10, 410"
$btn0.FlatStyle= "Popup"
$btn0.text= "search"

$btn0.Add_Click({
	[array] $yrr= ForwardFind $script:focus

	for([int] $i= $yrr.Length-1; $i -ge 0; $i--){
("fullpath: "+$yrr[$i].Tag[1]) | write-host

		if($i -eq ($yrr.Length-1)){

			if($editbox.SelectionStart -eq 0){
				continue;
			}
			[int] $rtn= $yrr[$i].Tag[1].LastIndexOf("な", $editbox.SelectionStart- 1, [System.StringComparison]::OrdinalIgnoreCase) # [列挙型] 区別しない
		}else{
			[int] $rtn= $yrr[$i].Tag[1].LastIndexOf("な", [System.StringComparison]::OrdinalIgnoreCase) # [列挙型] 区別しない
		}
		("rtn: "+ $rtn) | write-host
		if($rtn -ne -1){
			$script:focus= $yrr[$i]
			$script:tree.SelectedNode= $script:focus # refocus

			$editbox.focus()
			$script:editbox.Select($rtn, 1)
			break;
		}
	} #

<#
	[int] $len= 1#$editbox.SelectionLength
	### [string] $str= "よよ"#$editbox.SelectedText

	### $rtn= $tree.Nodes.Find($str, $False)
	("rtn: "+ $rtn) | write-host
	$y= $script:focus
	#while(1){
	$y= $y.NextNode

	$rtn= $y.Tag[1].IndexOf($str, 0)
	("chk3: "+ $retn) | write-host

	$editbox.Text= $y.Tag[1]
	$script:focus= $y

	$tree.SelectedNode= $script:focus # refocus

	# $script:focus.NextNode.FullPath | write-host
	$editbox.focus()
	# [int] $rtn= $editbox.Text.IndexOf($editbox.SelectedText, ($editbox.SelectionStart+ $len)) # 以降
	# [int] $rtn= $editbox.Text.LastIndexOf($editbox.SelectedText, ($editbox.SelectionStart- 1)) # 以前- 1
	$editbox.Select($rtn, $len)
#>
})
 	
#フォーム 

$frm= New-Object System.Windows.Forms.Form
$frm.Size= @(600, 640) -join "," # string出力
$frm.Text= "TreeView"
$frm.FormBorderStyle= "Sizable"
$frm.StartPosition= "WindowsDefaultLocation"
$frm.MaximizeBox= $True
$frm.MinimizeBox= $True
$frm.TopLevel= $True
# $frm.TransparencyKey= $frm.BackColor

# $frm.FormBorderStyle= "None"
# $frm.TransparencyKey= $black
# $frm.AllowTransparency= $True
# $frm.Opacity = 0.5
$frm.Add_Load({
 })

$frm.Add_Resize({
 })
 
$frm.Controls.AddRange(@($tree, $editbox, $bookbox, $focusbox, $counterbox, $btn0)) #下は後ろ側 
 
[object] $script:focus= "" 
[object] $script:mt= ""
[object] $script:te= ""
[object] $script:bmk= ""

[string] $script:out= ""
 
function TreeBuild([string] $readtext){ 

	# $readtext.Length | write-host
	[string[]] $textline= $readtext -split "`r`n"

	[string] $rgx= ""

	[bool] $book= $False
	[string] $mem= ""
	[string] $label= ""
	[int] $counter= 1
	[int] $j= 0

	$script:tree.Nodes.AddRange(@("1Untitled"))
	[array] $arr= $script:tree,  $script:tree.Nodes[0] # スタック
	[array] $frr= @()

	[int[]] $srr= 0 #adress stuck


	for([int] $i= 0; $i -lt $textline.Length; $i++){

		$rgx= [System.Text.RegularExpressions.Regex]::Matches($textline[$i],"^[F|S|C|N]+$") # ^[ |\t]+$

		if($rgx -eq ""){
			$j++;

			if($textline[$i] -match "S$" -eq $True){
				$counter= $j
				$textline[$i]= $textline[$i].Replace("S","")
				$label= $textline[$i]

			}elseif($textline[$i] -match "SB$" -eq $True){
				$book= $True
				$counter= $j
				$textline[$i]= $textline[$i].Replace("SB","")
				$label= $textline[$i]
			}
			$mem+= $textline[$i]+ "`r`n"

		}else{
			$y= $arr[- 1]
			$y.Text= $label
			$y.Tag=  ("","")
			$y.Tag[0]=  $counter
			$y.Tag[1]=  $mem
			## $y.name=  $mem
			if($book -eq $True){
				$script:bmk= $y
			}

			$book= $False
			$mem= ""
			$counter= 1
			$j= 0
			$label= ""

			if($rgx -match "^C"){ #	child # ^`t

				$y= $arr[- 1]

				if($rgx -match "N$"){ # node展開時

					$y.Expand()
				}

				$y.Nodes.AddRange(@("2Untitled"))

				$y= $y.Nodes[0]
				# ("push layer: "+ $y.FullPath) | write-host

				$arr+= $y
				$srr+= 0
				# ("push srr: "+ $srr -join ",") | write-host

			}elseif($rgx -match "^S"){

				if($rgx.Contains("F") -eq $True){ # `t

					[int] $num= $arr.Length- $rgx.IndexOf("F") # `t
					# ("focus index: "+ $num) | write-host

					$frr= $arr[0..$num]

					$y= $frr[- 1] # <- focus point
					$script:focus= $y

					# ("indexF: "+ $y.FullPath) | write-host

					$rgx= $rgx.Replace("F", "") # `t
				}

		if($i -eq ($textline.Length- 2)){ break; } # fuyo AddRange cancel

				[int] $num= ($arr.Length- 1)- $rgx.Length
				# ("layer num: "+ $num) | write-host

				$arr= $arr[0..$num]

				$y= $arr[- 1]
				$y.Nodes.AddRange(@("3Untitled"))

				$srr= $srr[0..$num]
				$srr[- 1]++;
				# ("layer srr: "+ $srr -join ",") | write-host

				$arr+= $y.Nodes[$srr[- 1]]
				# ("pop layer: "+ $y.FullPath) | write-host
			}
		}
	} #
 } #func
 
TreeBuild (cat '.\TEST.txt' | Out-String) 
 
$tree.SelectedNode= $focus 
 
<# 
	
$texthash= @{}; 
$texthash["0"]= "いち
いち"
$texthash["1"]= "に
に"
$texthash["2"]= "さん
さん"
$texthash["0,0"]= "よん
よん"
$texthash["1,0"]= "ご
ご"
$texthash["1,1"]= "ろく
ろく"
$texthash["0,0,0"]= "なな
なな"
 
$tree.Nodes.AddRange(@("いち", "いち", "さん")) 
$tree.Nodes[0].Nodes.AddRange(@("よん"))
$tree.Nodes[1].Nodes.AddRange(@("ご", "ろく"))
# $tree.Nodes[0].Nodes[0].Nodes.AddRange(@("なな"))

$tree.SelectedNode= $tree.Nodes[1].Nodes[0]

$xx= $tree
$xx= $xx.Nodes[0]
$xx= $xx.Nodes[0]
$xx.Nodes.AddRange(@("なな")) # = .Nodes[].Text

$tree.Nodes[0].Nodes[0].Tag= ([array] 3, "", "bookmark", "focus") # .Nodes[].Name
$tree.Nodes[0].Nodes[0].Tag[2] | write-host
 
$tree.Nodes[0].Tag= ([string[]] 0, "いいち 
いち", "", "")
$tree.Nodes[1].Tag= ([string[]] 0, "にに
に", "", "")
$tree.Nodes[2].Tag= ([string[]] 0, "ささん
さん", "", "")
$tree.Nodes[0].Nodes[0].Tag= ([string[]] 0, "よよ
よ", "bookmark", "")
$tree.Nodes[1].Nodes[0].Tag= ([string[]] 1, "ごご
ご", "", "")
$tree.Nodes[1].Nodes[1].Tag= ([string[]] 0, "ろろく
ろく", "", "")
$tree.Nodes[0].Nodes[0].Nodes[0].Tag= ([string[]] 0, "ななな
なな", "", "focus")

 
#> 
  
$frm.ShowDialog() > $null 
 
exit 
 
		[int] $sw= 1 

		if($sw){
			if($mem -eq ""){ # 0行
				$head= $dd
			}
			if($dd -match " $"){ # title行
				$dd= [System.Text.RegularExpressions.Regex]::Matches($dd,"^.*(?= $)")
				$head= $dd
				write-host ("head: "+ $head)
				$sw= 0
			}
		}

		$sw= 1
		# $Tree.Nodes[0].Nodes[1].Nodes[0].Text= $head
 
[array] $arr_keys= $texthash.Keys 

[int[]] $aarr= ""
foreach($bb in $arr_keys){
	[int[]] $rrr= $bb -split ","
	$aarr*= $rrr.Length

 } #


$arr_keys= $arr_keys | sort {$_.Length}

write-host $arr_keys

foreach($aa in $arr_keys){


	[string[]] $rrb= $aa -split ","


	switch($rrb.Length){
	1{
write-host ("rrb: "+ $rrb[0])
		$xx= $tree
		$xx.Nodes.AddRange(@($texthash[$rrb[0]]))
	}default{
		$xx= $tree
write-host $xx
		for([int] $ii= 0; $ii -lt $rrb.Length; $ii++){

			# $xx= $xx.Nodes[$rrb[$ii]]

		} #

		# $xx.Nodes.AddRange(@("のの"))
	}
	} #sw
 } #

# exit
 
