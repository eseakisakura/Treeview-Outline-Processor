Add-Type -AssemblyName System.Windows.Forms > $null 
Add-Type -AssemblyName System.Drawing > $null

cd (Split-Path -Parent $MyInvocation.MyCommand.Path)
[Environment]::CurrentDirectory= pwd # working_dir set
 
function ForwardFind($x){ 

	$y= $x			# $script:focus
	("y: "+ $y) | write-host

	[array] $stuck= @($x)	# 最初にforcusノードから入れる

	[int] $sw= 1

	# for([int] $i= 0; $i -lt 20; $i++){
	while(1){

		if($i -gt 500000){

			[string] $qq= "検索ノードが、50万を超えました"

			write-host $qq

			[string] $retn=  [Windows.Forms.MessageBox]::Show(
			$qq, "確認", "OK","Information","Button1"
			)

			break;	# 強制終了
		}

		if($sw -eq 1){

			if($y.FirstNode -ne $null){

				$y= $y.FirstNode	# 最初の子ツリー ノード
				("FirstNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y

			}elseif($y.NextNode -ne $null){

				$y= $y.NextNode	# 兄弟ツリー ノード
				("NextNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y
			}else{

				$sw= 0
			}

		}else{
			if($y.Parent.NextNode -ne $null){

				$y= $y.Parent.NextNode	# 親の兄弟ノード
				("Parent.NextNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y
				$sw= 1

			}else{
				if($y.Level -gt 0){	# トップノード以外

					$y= $y.Parent	# いったん親へ戻る

				}else{
					$y= $tree.TopNode
					("tree.TopNodefullpath: "+ $y.FullPath) | write-host

					if($y -eq $x){ break; }

					$stuck+= $y
					$sw= 1
				}
			}
		}
	} #

	$stuck+= $x	# 最後に回帰ノード検索分
	return $stuck
 } #func
 
function PasteSelecter([string] $sw){ 


	[string] $clip= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)


	if($clip -eq "tree.nodes.data.flag.clipboard"){

		if($script:focus.Level -eq 0){	# $script:focus.Parent -eq $nullのため

			[object] $y= $tree.Nodes
		}else{
			[object] $y= $script:focus.Parent.Nodes	# forcusノードの下へadd
		}

		if($sw -eq "add"){

			[int] $ee= $y.IndexOf($script:focus)
			[int] $nn= $ee+ 1	# 下ノード
		}else{
			[int] $nn= $y.IndexOf($script:focus)
			[int] $ee= $nn+ 1	#下ノード
		}


		$y.Insert($nn, $script:node_clip.Clone())

		[object] $x= $y[$ee]
		$x.Tag= $ee

		[object] $z= $y[$nn]
		$z.Tag= $nn

		$script:focus= $z	# reforcus
		$tree.SelectedNode=  $z

	}else{
		# plain text

		if($script:focus.Level -eq 0){

			[object] $y= $tree.Nodes

			[object] $z= $script:focus.Parent.Nodes

			if($sw -eq "add"){
				[int[]] $dd= 1, 1
			}else{
				[int[]] $dd= 0, -1
			}

			$y.Insert(($y.IndexOf($script:focus)+ $dd[0]), "Untitled")

			[object] $obj= $y[$z.IndexOf($script:focus)+ $dd[1] ]


		}else{
			[object] $y= $script:focus.Parent.Nodes

			if($sw -eq "add"){
				[int[]] $dd= 1, 1
			}else{
				[int[]] $dd= 0, -1
			}

			$y.Insert(($y.IndexOf($script:focus)+ $dd[0]), "Untitled")

			[object] $obj= $y[$y.IndexOf($script:focus)+ $dd[1] ]
		}

		[string[]] $doc= $clip -split "`r`n"

		# if($doc[0] -eq ""){
		#	$obj.Text= "Untitled"
		# }else{

		$obj.Text= $doc[0]	# 行頭
		$obj.Name=  $clip	# clipboard

		# }

		$tree.SelectedNode= $obj	# refocus
	}
 } #func
 
function TreeBuild([string] $readtext){ 


	[string] $sentinel= "^^End_Finish$$"	# 番兵
	[bool] $sentinel_sw= $False		# $y.Nodes.AddRangeキャンセル


	[string[]] $textdoc= $readtext -split "`r`n"	# 配列確保

	$textline= $textdoc[0..($textdoc.Length- 3)]
	$textline+= $sentinel
	$textline+= $textdoc[-2]
	# EOFカット [-1]


	[string] $label= ""
	[string] $mem= ""
	[int] $j= 0


	$tree.Nodes.AddRange(@("Parent Untitled"))

	[object] $y= $tree.Nodes[0]


	# $tree.Nodes[0].Text= "ボトムノード"	# .Text - title

	$y.Tag= $j
	$script:focus= $y	# 初期のフォーカス設定

	# $y.Nodes.AddRange(@("3Untitled", "4Untitled"))


	[array] $arr= $tree, $y	# 階層ごとの最終ノード

	write-host ("arr[1]: "+ $arr[1])
	write-host ("arr[1].Tag: "+ $arr[1].Tag)
	write-host ""


	for([int] $i= 0; $i -lt $textline.Length; $i++){


		# 空行と番兵分岐

		if( $textline[$i] -eq $sentinel ){
		# 最終行[-2]確認

			$sentinel_sw= $True


		}elseif( $textline[$i] -match "^`t *$"){  # `t`s* - tabで始まり、spaceがあるかないか
		# 子ノードへ+ 開状況チェック

			$y.Name= $mem	# ここで入力
			write-host ("y.Name: "+ $y.Name)

			$mem= ""


			if( $textline[$i] -match " " ){	# `s 開状況

				$y.Expand()
				write-host ("tab child open label: "+ $textline[$i])
			}else{
				write-host ("tab child label: "+ $textline[$i])
			}

			$y.Nodes.AddRange(@("Child Untitled"))		# 1階層下へ
			$y= $y.Nodes[0]
			$j= 0
			$y.Tag=  $j

			$arr+= $y		# 下位階層store
			# write-host ("child arr: "+ $arr)


		}elseif( $textline[$i] -match "^ $" ){  #`s - 先頭スペース行末
		# 兄弟ノード確認

			$y.Name= $mem	# ここで入力
			write-host ("y.Name: "+ $y.Name)

			$mem= ""

			if ($sentinel_sw -eq $False ){	# 最終行以外

				[int] $len= $arr.Length- 1

				$y= $arr[$len]
				$j= $y.Tag	# 添字を取得


				$y= $arr[($len- 1)]	# parent
				$y.Nodes.AddRange(@("Next Untitled"))

				$j++;
				$y= $y.Nodes[$j]

				$y.Tag= $j

				$arr= $arr[0..($len)]
				$arr[-1]= $y

				# write-host ("parent arr: "+ $arr)
				write-host ("single space:"+ $textline[$i])
			}


		}elseif( $textline[$i] -match "^ ( |`t)+$" ){  # まずspace、(space | tab)がある
		# 親ノードへ、フォーカスチェック、開状況のチェックは必要ない


			$y.Name= $mem	# ここで入力
			write-host ("y.Name: "+ $y.Name)

			$mem= ""


			[string] $tt= " "	# `s

			if($textline[$i].Contains("`t") -eq $True){
			# タブまでの個数計算


				[int] $nn= $textline[$i].IndexOf("`t")

				[string] $dd= $textline[$i].Substring(0, $nn)


				[int] $dt_len= [Math]::Floor($dd.Length / $tt.Length)	# 同階層下へのスペース分

				$dt_len= $arr.Length- $dt_len

				$y= $arr[$dt_len]

				$script:focus= $y	# フォーカス設定
				write-host ("forcus set : "+ $y)

				[string] $ss= $textline[$i].Replace("`t", "")

				write-host ("forcus tab found: "+ $textline[$i])

			}else{
				[string]  $ss= $textline[$i]

				write-host ("space's only: "+ $textline[$i])
			}


			if ($sentinel_sw -eq $False ){	# 最終行以外


				[int] $len= [Math]::Floor($ss.Length / $tt.Length)	# 同階層下へのスペース分

				$len= $arr.Length- $len
				$y= $arr[$len]


				$j= $y.Tag	# 添字を取得

				$y= $arr[($len- 1)]	# parent
				$y.Nodes.AddRange(@("Next Untitled"))

				$j++;
				$y= $y.Nodes[$j]

				$y.Tag= $j

				$arr= $arr[0..($len)]
				$arr[-1]= $y

				# write-host ("parent arr: "+ $arr)
			}


		}else{
		#def.ライン処理

			# $textline[$i]= $textline[$i].Replace(" ","")	# `s - 正規表現のほうが安全
			# $y.Tag=  ("","")	# 項目増やす場合
			# $y.Tag[0]=  $counter
			# $y.Tag[1]=  $mem


			if( $textline[$i] -match " `t$" ){	# `s`t label+ bookmark


				$label= [System.Text.RegularExpressions.Regex]::Matches( $textline[$i] , ".*(?= `t$)")	# `s`t
				$label= $label.Trim(" ")	# exp -> last space cutting -> node in

				write-host ("title+ bookmark label: "+ $label )
				$script:bookmark= $y
				$y.Text= $label

			}elseif( $textline[$i] -match " $" ){	# `s - label


				$label= [System.Text.RegularExpressions.Regex]::Matches( $textline[$i] , ".*(?= $)")	# `s
				$label= $label.Trim(" ")

				write-host ("title label: "+ $label )
				$y.Text= $label


			}elseif( $textline[$i] -match "`t$" ){	# bookmark


				$label= [System.Text.RegularExpressions.Regex]::Matches( $textline[$i] , ".*(?=`t$)")
				$label= $label.Trim(" ")

				write-host ("bookmark label: "+ $label )
				$script:bookmark= $y

			}else{

				$label= $textline[$i]
				write-host ("def.label: "+ $label )
			}


			$mem+= $label+ "`r`n"	# ここでtext add
			$label= ""
		}
	} #
 } #func
 
function DocBuild($x){	# $tree 

	[string] $output= ""

	# $x.Nodes.Count | write-host
	for([int] $i= 0; $i -lt $x.Nodes.Count; $i++){

		$y= $x.Nodes[$i]


		if($script:bookmark -eq $y){

			[string] $bmk= "`t" # tab
		}else{
			[string] $bmk= ""
		}


		# write-host("fullpath: "+ $y.FullPath)

		[array] $arr= $y.Name -split "`r`n"


		for([int] $j= 0; $j -lt $arr.Length; $j++){	# $y.Name

			$output+= $arr[$j]

			if($y.Text -eq $arr[$j]){	# title line

				$output+= " "	# space
				$output+= $bmk
			}

			if($j -ne ($arr.Length- 1)){	# max count

				$output+= "`r`n"
			}
		} #

		# 空行分の出力

		if($y.Nodes.Count -gt 0){	# 子階層チェック

			$output+= "`t"	# tab

			if($y.IsExpanded -eq "True"){	# node展開時

				$output+= " "	# space
			}

			$output+= "`r`n"

					#ここで、飲み込む。
			$output+= DocBuild $y 	# 再帰
					#段数分、ここから下へ吐き出す。

			$output+= " "	# space

		}else{	# 兄弟node
			$output+= " "	# space
		}

		if($focus -eq $y){	# フォーカスあらばadd

			$output+= "`t"	# tab
		}

		if($i -lt ($x.Nodes.Count- 1)){	# max count

			$output+= "`r`n"
		}
	} #

	return $output
 } # func
 
function Down_search(){ 

	[array] $yy= ForwardFind $script:focus


	[int] $rtn_len= $editbox.SelectionLength		# 1
	[string] $rtn_str= $editbox.SelectedText		# "な"


	[int] $dur= ([int] $editbox.SelectionStart)+ 1	# マイナス数で$rtn= -1へ
	# write-host $editbox.Text.Length


	for([int] $i= 0;  $i -lt $yy.Length; $i++){

		if($i -eq 0){	# 同一ノード

			[int] $index_rtn= $yy[$i].Name.IndexOf($rtn_str, $dur, [System.StringComparison]::OrdinalIgnoreCase)
		}else{
			[int] $index_rtn= $yy[$i].Name.IndexOf($rtn_str, [System.StringComparison]::OrdinalIgnoreCase) # [列挙型] 区別しない
		}

		if($index_rtn -eq -1){

		}else{
			$script:focus= $yy[$i]
			$tree.SelectedNode= $script:focus	# refocus

			$editbox.focus()
			$editbox.Select($index_rtn, $rtn_len)

			break;	# ここでループブレイク
		}
	} #
 } # func
 
function Upper_search(){ 

	[array] $yy= ForwardFind $script:focus


	$yy= $yy[$yy.Length.. 0]	# 配列反転 " [array]::Reverse($yy) "でもよい


	[int] $rtn_len= $editbox.SelectionLength		# 1
	[string] $rtn_str= $editbox.SelectedText		# "な"


	[int] $dur= ([int] $editbox.SelectionStart)- 1	# マイナス数で$rtn= -1へ
	# write-host $editbox.Text.Length


	for([int] $i= 0;  $i -lt $yy.Length; $i++){

		if($i -eq 0){	# 同一ノード


			if($dur -ge 0){

				[int] $index_rtn= $yy[$i].Name.LastIndexOf($rtn_str, $dur, [System.StringComparison]::OrdinalIgnoreCase)

			}else{
				[int] $index_rtn= -1	# breakへ
			}
		}else{

			[int] $index_rtn= $yy[$i].Name.LastIndexOf($rtn_str, [System.StringComparison]::OrdinalIgnoreCase) # [列挙型] 区別しない
		}

		if($index_rtn -eq -1){

		}else{
			$script:focus= $yy[$i]
			$tree.SelectedNode= $script:focus	# refocus

			$editbox.focus()
			$editbox.Select($index_rtn, $rtn_len)

			break;	# ここでループブレイク
		}
	} #
 } #func
 
# ------------ 
 
$tree= New-Object System.Windows.Forms.TreeView 
$tree.Size= "200, 500"
$tree.Location= "10, 10"
$tree.HideSelection= $False
# $tree.SelectedNode (equal) $_.Node

$tree.Add_AfterSelect({

	"------" | write-host
	("index: "+ $this.Nodes.IndexOf($_.Node)) | write-host
	$this.TopNode.FullPath | write-host
	$_.Node.Parent.FullPath | write-host
	$_.Node.PrevNode.LastNode.FullPath | write-host
	$_.Node.PrevNode.FullPath | write-host
	$_.Node.FullPath | write-host
	$_.Node.NextNode.FullPath | write-host
	$_.Node.FirstNode.FullPath | write-host
	"------" | write-host
	$script:focus= $_.Node

	$counterbox.Text= $_.Node.Tag
	$editbox.Text= $_.Node.name
	$focusbox.Text= $script:focus
	$bookmarkbox.Text= $script:bookmark
 })


$tree.Add_MouseDown({
 try{
	[string] $rtn= ""

	switch([string] $_.Button){
	'Left'{	break;
	}'Right'{
		$contxt.Show([Windows.Forms.Cursor]::Position)
		break;
	}'Middle'{
	}
	} #sw
 }catch{
	echo $_.exception
 }
 })
 
$edit_lbl= New-Object System.Windows.Forms.Label 
$edit_lbl.Text= "editbox"
$edit_lbl.Size= "100,20"
$edit_lbl.Location= "210,10"
$edit_lbl.TextAlign= "MiddleCenter"
$edit_lbl.BorderStyle= "Fixed3D"
$edit_lbl.ForeColor= "black"
#$edit_lbl.BackColor= "dodgerblue"
 
$editbox= New-Object System.Windows.Forms.TextBox 
$editbox.Text= "editbox"

$editbox.Size= "400, 180"
$editbox.Location= "210, 30"
$editbox.Multiline= "True"
$editbox.AcceptsReturn= "True"
$editbox.AcceptsTab= "True"
$editbox.ScrollBars= "Vertical"
$editbox.WordWrap= "True"

# $editbox.SelectedText
# $editbox.SelectionLength
# $editbox.SelectionStart


$editbox.Add_Leave({

	$script:focus.Name= $this.Text
})


$editbox.Add_MouseDown({
 try{
	switch([string] $_.Button){
	'Right'{
	}'Left'{
		write-host "Left"
		write-host $editbox.SelectionStart
		write-host $editbox.SelectedText
		write-host $editbox.SelectionLength
	}'Middle'{
	}
	} #sw
 }catch{
	echo $_.exception
 }
 })
 
$focus_lbl= New-Object System.Windows.Forms.Label 
$focus_lbl.Text= "focusbox"
$focus_lbl.Size= "100,20"
$focus_lbl.Location= "210,210"
$focus_lbl.TextAlign= "MiddleCenter"
$focus_lbl.BorderStyle= "Fixed3D"
$focus_lbl.ForeColor= "black"
 
$focusbox= New-Object System.Windows.Forms.TextBox 
$focusbox.Text= "forcusbox"

$focusbox.Size= "400, 80"
$focusbox.Location= "210, 230"
$focusbox.Multiline= "True"
$focusbox.AcceptsReturn= "True"
$focusbox.AcceptsTab= "True"
$focusbox.ScrollBars= "Vertical"
 
$bookmark_lbl= New-Object System.Windows.Forms.Label 
$bookmark_lbl.Text= "bookmarkbox"
$bookmark_lbl.Size= "100,20"
$bookmark_lbl.Location= "210,310"
$bookmark_lbl.TextAlign= "MiddleCenter"
$bookmark_lbl.BorderStyle= "Fixed3D"
$bookmark_lbl.ForeColor= "black"
 
$bookmarkbox= New-Object System.Windows.Forms.TextBox 
$bookmarkbox.Text= "bookmarkbox"

$bookmarkbox.Size= "400, 80"
$bookmarkbox.Location= "210, 330"
$bookmarkbox.Multiline= "True"
$bookmarkbox.AcceptsReturn= "True"
$bookmarkbox.AcceptsTab= "True"
$bookmarkbox.ScrollBars= "Vertical"
 
$counter_lbl= New-Object System.Windows.Forms.Label 
$counter_lbl.Text= "counterbox"
$counter_lbl.Size= "100,20"
$counter_lbl.Location= "210,410"
$counter_lbl.TextAlign= "MiddleCenter"
$counter_lbl.BorderStyle= "Fixed3D"
$counter_lbl.ForeColor= "black"
 
$counterbox= New-Object System.Windows.Forms.TextBox 
$counterbox.Text= "counterbox"

$counterbox.Size= "400, 80"
$counterbox.Location= "210, 430"
$counterbox.Multiline= "True"
$counterbox.AcceptsReturn= "True"
$counterbox.AcceptsTab= "True"
$counterbox.ScrollBars= "Vertical"
 
# コンテキスト 

$contxt_03= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_03.Text= "Bookmark Select"
$contxt_03.Add_Click({

	$tree.SelectedNode= $script:bookmark
 })

$contxt_bmk= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_bmk.Text= "Bookmark Set"
$contxt_bmk.Add_Click({

	$script:bookmark= $script:focus
	$bookmarkbox.Text= $script:bookmark
 })

$contxt_cut= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_cut.Text= "Cut"
$contxt_cut.Add_Click({

	[Windows.Forms.Clipboard]::SetText("tree.nodes.data.flag.clipboard", [Windows.Forms.TextDataFormat]::UnicodeText)
	$script:node_clip= $script:focus
	$script:focus.Nodes.Remove($script:focus)
 })

$contxt_copy= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_copy.Text= "Copy"
$contxt_copy.Add_Click({

	[Windows.Forms.Clipboard]::SetText("tree.nodes.data.flag.clipboard", [Windows.Forms.TextDataFormat]::UnicodeText)
	$script:node_clip= $script:focus
 })

$contxt_paste= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_paste.Text= "Paste"
$contxt_paste.Add_Click({

	# $contxt_paste.Enabled= [Windows.Forms.Clipboard]::ContainsText([Windows.Forms.TextDataFormat]::UnicodeText)

	[bool] $rtn= [Windows.Forms.Clipboard]::ContainsText()	# text document チェック

	if($rtn -eq $True){

		PasteSelecter ""
	}
 })

$contxt_add= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_add.Text= "Add Paste"
$contxt_add.Add_Click({

	[bool] $rtn= [Windows.Forms.Clipboard]::ContainsText()

	if($rtn -eq $True){

		PasteSelecter "add"
	}
 })

$contxt_12= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_12.Text= "Child Paste"
$contxt_12.Add_Click({

	[object] $y= $script:focus

	# $y.Nodes.AddRange($script:node_clip.Clone())	# = insert
	$y.Nodes.Insert(0, $script:node_clip.Clone())	# node list object first child paste

	$y.Expand()

	$y.Nodes[0].Tag= 0

	$script:focus= $y.Nodes[0]	# refocus
	$tree.SelectedNode= $y.Nodes[0]
 })

$contxt= New-Object System.Windows.Forms.ContextMenuStrip
$contxt.Items.AddRange(@($contxt_bmk, $contxt_cut, $contxt_copy, $contxt_paste, $contxt_add, $contxt_12))
$contxt.Items.Insert(0, $contxt_03) # list object
 
$btn0= New-Object System.Windows.Forms.Button 
$btn0.Size= "100,100"
$btn0.Location= "210, 510"
$btn0.FlatStyle= "Popup"
$btn0.text= "select down search"

$btn0.Add_Click({

	if($editbox.SelectedText -ne ""){
		Down_search
	}
 })
 
$btn1= New-Object System.Windows.Forms.Button 
$btn1.Size= "100,100"
$btn1.Location= "310, 510"
$btn1.FlatStyle= "Popup"
$btn1.text= "select upper search"

$btn1.Add_Click({

	if($editbox.SelectedText -ne ""){
		Upper_search
	}
 })
 
$btn2= New-Object System.Windows.Forms.Button 
$btn2.Size= "100,100"
$btn2.Location= "410, 510"
$btn2.FlatStyle= "Popup"
$btn2.text= "doc file write"

$btn2.Add_Click({

		[string] $rtn= DocBuild $tree
		write-host ("====")
		$rtn | write-host
		write-host ("====")

		$rtn | Out-File -Encoding UTF8 -FilePath ".\TEST.txt" # UTF8


		# $rtn | Out-File -Encoding oem -FilePath ".\TEST-01.txt" # shiftJIS
 })
 
$frm= New-Object System.Windows.Forms.Form 
$frm.Size= @(640, 660) -join "," # string出力
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

# $frm.Add_Load({
#  })

# $frm.Add_Resize({
#  })

$frm.AllowDrop= $True

$frm.Add_DragEnter({

	$_.Effect= "All"
})

$frm.Add_DragDrop({
  try{
	[string[]] $rtn= $_.Data.GetData("FileDrop")

	$script:focus= ""
	$script:node_clip= ""
	$script:bookmark= ""

	$tree.Nodes.Clear()	# TreeNodeCollection クラス

	TreeBuild (cat $rtn[0] | Out-String)

	$tree.SelectedNode= $script:focus

  }catch{
	echo $_.exception
  }
})

 	
$frm.Controls.AddRange(@($tree)) 
$frm.Controls.AddRange(@($edit_lbl, $editbox, $focus_lbl, $focusbox, $bookmark_lbl, $bookmarkbox, $counter_lbl, $counterbox))
$frm.Controls.AddRange(@($btn0, $btn1, $btn2))
#下は後ろ側
 
[object] $script:focus= "" 
[object] $script:node_clip= ""
[object] $script:bookmark= ""


TreeBuild (cat '.\TEST.txt' | Out-String)

$tree.SelectedNode= $script:focus

$frm.ShowDialog() > $null
 
read-host "pause" 
 
