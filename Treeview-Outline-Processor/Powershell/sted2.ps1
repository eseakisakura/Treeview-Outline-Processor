# 高速化手法	ライン処理 -> 正規表現で抽出 
# utf8 bomなし対応
 
Add-Type -AssemblyName System.Windows.Forms > $null 
Add-Type -AssemblyName System.Drawing > $null

cd (Split-Path -Parent $PSCommandPath)
[Environment]::CurrentDirectory= pwd # working_dir set
 
function NodePaste([string] $sw){ 

#2408
	if($script:focus.Level -eq 0){	# $script:focus.Parent.Nodes -eq $nullのため

		[object] $y= $tree.Nodes
	}else{
		[object] $y= $script:focus.Parent.Nodes	# forcusノードの下へadd
	}

	if($sw -eq "add"){

		[int] $ee= $y.IndexOf($script:focus)
		[int] $nn= $ee+ 1			# 下ノード
	}else{
		[int] $nn= $y.IndexOf($script:focus)	# .Insert number
	}


	$y.Insert($nn, $script:node_clip.Clone())


	[object] $z= $y[$nn]


	$tree.SelectedNode= $z	# reforcus

 } # func
 
function PlainPaste([string] $sw){	# plain text 

#2408
	if($script:focus.Level -eq 0){

		[object] $y= $tree.Nodes
	}else{
		[object] $y= $script:focus.Parent.Nodes
	}

	if($sw -eq "add"){

		[int[]] $dd= 1, 1
	}else{
		[int[]] $dd= 0, -1
	}

	$y.Insert(($y.IndexOf($script:focus)+ $dd[0]), "Untitled")	# ここで $obj.Text= Untitled

	[object] $obj= $y[$y.IndexOf($script:focus)+ $dd[1] ]


	$obj.Tag= @{}		# hash
	$obj.Tag["title"]= 0		# title index
	$obj.Tag["caret"]= 0	# 0 caret	#2408


	[bool] $new= [Windows.Forms.Clipboard]::ContainsText()	# text document チェック

	if($new){
		[string] $cc= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)


		[string[]] $doc= $cc -split "`r`n"

		if($doc[0].Length -gt 0){

			$obj.Text= $doc[0]	# 行頭
		}else{
			$obj.Text= "Untitled"
		}

		$obj.Name=  $cc	# clipboard	

	}else{
		$obj.Name=  ""
	}


	$tree.SelectedNode= $obj	# refocus

 } #func
 
function NodeChildPaste(){ 

#2408
	[object] $y= $script:focus

	# $y.Nodes.AddRange($script:node_clip.Clone())	# これでも良い
	$y.Nodes.Insert(0, $script:node_clip.Clone())	# node list object first child paste

	$y.Expand()	# 開状況へ

	$tree.SelectedNode= $y.Nodes[0]	# refocus

 } # func
 
function PlainChildPaste(){ 

#2408
	[object] $y= $script:focus

	# $y.Nodes.AddRange(@("Untitled"))	# これでも良い
	$y.Nodes.Insert(0, "Untitled")	# node list object first child paste

	$y.Expand()	# 開状況へ

	[object] $obj= $y.Nodes[0]


	$obj.Tag= @{}		# hash
	$obj.Tag["title"]= 0		# title index
	$obj.Tag["caret"]= 0	# 0 caret	#2408


	[bool] $new= [Windows.Forms.Clipboard]::ContainsText()	# text document チェック

	if($new){
		[string] $cc= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

		[string[]] $doc= $cc -split "`r`n"

		if($doc[0].Length -gt 0){

			$obj.Text= $doc[0]	# 行頭
		}else{
			$obj.Text= "Untitled"
		}

		$obj.Name=  $cc	# clipboard

	}else{
		$obj.Name=  ""
	}

	$tree.SelectedNode= $obj	# refocus

 } #func
 
function Line_index([int] $num, [string] $textdoc){	# 改行数 

	[int] $count= 0
	[int] $index= $textdoc.IndexOf("`r`n")

	[int] $before= 0

	while ($index -ne -1 -and $index -lt $num){	# not -1 and num以下

		$before= $index+ 1	# caret前の行末から次の行頭へ
		$count++;	# 改行数

		$index= $textdoc.IndexOf("`r`n", $index+ 1)	# index+1以降の"`r`n"
	} #

	return ($count, $before)
 } # func
 
function TreeBuild([string] $readtext){ 


	# example (?<=^@OP)[0-9]+(?=\s*=)

	[string[]] $textline= [System.Text.RegularExpressions.Regex]::Matches($readtext , "(?<=`r`n)(`t| )+?((?=`r`n)|$)")
	# (先読み 改行) タブorスペースが一つ以上最短一致 (後読み 改行)or行末
	# 空行、ヒットを配列へ
	#2408

	write-host ("textline.Length: "+ $textline.Length)

	[string[]] $textdoc= [System.Text.RegularExpressions.Regex]::Matches($readtext , "(^|(?<=`r`n(`t| )+?`r`n))(.|`r`n)+?(?=`r`n(`t| )+?(`r`n|$))")
	# 先頭or(先読み空行分) 任意or`r`nが一つ以上最短一致 (後読み空行分)
	# 本文、ヒットを配列へ
	#2408

	write-host ("textdoc.Length: "+ $textdoc.Length)


	$tree.Nodes.Add("Untitled")

	[object] $y= $tree.Nodes[0]


	$y.Tag= @{}		# hash
	$y.Tag["title"]= 0		# title index
	$y.Tag["caret"]= 0		# 0 caret	#2408


	if( $textline.Length -ne $textdoc.Length -or $textline.Length -eq 0 -or $textdoc.Length -eq 0){	# plan text


		[string] $tt= [System.Text.RegularExpressions.Regex]::Match( $readtext , "^.*(?=($|`r`n))")
		# 先頭　タイトル読込み　後読み(行末or改行)
		# 行末は一行文対応ため

		if($tt.Length -gt 0){

			$y.Text= $tt
		}

		$y.Name= $readtext

		$script:focus= $y	# 最終フォーカス設定


	}else{	# sted text


		#2408	[int] $j= 0


		$script:focus= $y	# 初期のフォーカス設定

		[array] $arr= $tree, $y	# 階層ごとの最終ノード


#		for([int] $i= 0; $i -lt $textdoc.Length; $i++){
#			$textdoc[$i]+= "`r`n"			# 後段のため最終行へ改行付与
#			# write-host ("textdoc[i]"+$textdoc[$i])	#2408
#		} #


		for([int] $i= 0; $i -lt $textline.Length; $i++){


			$textdoc[$i]+= "`r`n"	# 後段のため最終行へ改行付与


			# 本文処理

			# タイトル
			[string] $tt= [System.Text.RegularExpressions.Regex]::Match( $textdoc[$i] , "(^|(?<=`r`n)).*(?= `t?($|`r`n))")
			# 先読み(先頭or改行で始まり)　タイトル読込み　後読み(スペースタブあるなし 行末or改行)
			# 行末は一行文対応ため

			if($tt.Length -gt 0){

				$y.Text= $tt	# Untitled overwrite
			}


			# title index
			[int] $num= $textdoc[$i].IndexOf(" `r`n")	# `s

			if($num -eq -1){
				$num= $textdoc[$i].IndexOf(" `t`r`n")	# `s`t
			}

			write-host("num: "+ $num)

			[int[]] $count= Line_index $num $textdoc[$i]



			$y.Tag["title"]= $count[0]
			write-host("y.Tag[title]: "+ $y.Tag["title"])


			# bookmark
			if($textdoc[$i] -match "`t`r`n"){  # 行末にtabがある

				$script:bookmark= $y
				write-host ("bookmark set : "+ $script:bookmark)

				[int] $bmk_num= $textdoc[$i].IndexOf("`t`r`n")
				write-host("num: "+ $bmk_num)

				[int[]] $bmk_count= Line_index $bmk_num $textdoc[$i]


				$script:bookmark_caret= $bmk_count[1]	# caret
				write-host ("bookmark caret : "+ $script:bookmark_caret)
			}


			# 本文
			$y.Name= [System.Text.RegularExpressions.Regex]::Replace($textdoc[$i], "( |`t| `t)`r`n", "`r`n")
			# スペースタブ行のゴミカット、(`s|`t|`s`t)`r`n -> `r`n
			#2408



			# 空行処理

			if( $textline[$i] -match "^`t ?$"){  # `t`s? - tabで始まり、spaceがあるかないか
			# 子ノードへ+ 開状況チェック


				$y.Nodes.Add("Untitled")		# 1階層下へ Child Untitled


				if( $textline[$i].Contains(" ") -eq $True){	# `s 開状況

					$y.Expand()	# Add後
				}

				$y= $y.Nodes[0]
				#2408	$j= 0

				$y.Tag= @{}		# hash
				$y.Tag["title"]= 0		# title index
				$y.Tag["caret"]= 0		# 0 caret	#2408

				$arr+= $y		# 下位階層store
				# write-host ("child arr: "+ $arr)


			}elseif( $textline[$i] -match "^ ( |`t)*$" ){  # まずspace、(space | tab)があるなし
			# フォーカスタブあり、兄弟と回帰ノード、開状況のチェックは必要ない


				if($textline[$i].Contains("`t") -eq $True){
				# タブまでの個数計算


					[int] $nn= $textline[$i].IndexOf("`t")

					[string] $dd= $textline[$i].Substring(0, $nn)


					[int] $dt_len= $dd.Length	# 同階層下へのスペース分

					$dt_len= $arr.Length- $dt_len

					$y= $arr[$dt_len]

					$script:focus= $y	# 最終フォーカス設定
					write-host ("forcus set : "+ $script:focus)


					[string] $ss= $textline[$i].Replace("`t", "")	# タブカット、スペースのみへ


				}else{
					[string]  $ss= $textline[$i]

				}


				if ($i -lt $textline.Length- 1 ){	# 最終行以外


					[int] $len= $ss.Length	# 同階層下へのスペース分

					$len= $arr.Length- $len
					$y= $arr[$len]	# 回帰ノードへ


					#2408	$j= $y.Tag	# 添字を取得
					[int] $j= $y.Index	# 添字を取得	#2408


					$y= $arr[($len- 1)]	# parent

					$y.Nodes.Add("Untitled")	# Next Untitled

					$j++;
					$y= $y.Nodes[$j]


					$y.Tag= @{}		# hash
					$y.Tag["title"]= 0		# title index
					$y.Tag["caret"]= 0		# 0 caret	#2408


					$arr= $arr[0..($len)]
					$arr[-1]= $y

					# write-host ("parent arr: "+ $arr)
				}


			}else{
				write-host ("TreeBuild: 何らかのエラー")
				break;
			}
		} #
	}
 } #func
	 
<#		TreeBuild 空行処理 

		}elseif( $textline[$i] -match "^ $" ){  #`s - 先頭スペース行末
		# 兄弟ノード確認

			if ($i -lt $textline.Length- 1 ){	# 最終行以外

				##[int] $len= $arr.Length- 1	##

				$y= $arr[- 1]

				$j= $y.Tag	# 添字を取得


				$y= $arr[- 2]	# parent
				$y.Nodes.Add("Next Untitled")

				$j++;
				$y= $y.Nodes[$j]

				$y.Tag= $j

				## $arr= $arr[0..($arr.Length- 1)]	##不要
				$arr[-1]= $y

				# write-host ("parent arr: "+ $arr)
				# write-host ("single space:"+ $textline[$i])
			}

#>
  	
function DocBuild($x){	# $tree 


	# $x.Nodes.Count | write-host

	for([int] $i= 0; $i -lt $x.Nodes.Count; $i++){

		$y= $x.Nodes[$i]

		[int[]] $count= 0, 0


		if($script:bookmark -eq $y){	# bookmark tabの行取得	#2408

			$count= Line_index $script:bookmark_caret  $y.Name
		}

		# write-host("script:bookmark_caret:"+ $script:bookmark_caret)
		# write-host("count[0]: "+ $count[0])
		# write-host("fullpath: "+ $y.FullPath)

		[string[]] $arr= $y.Name -split "`r`n"


		for([int] $j= 0; $j -lt $arr.Length; $j++){	# 本文

			$script:doc_out+= $arr[$j]	# string line add

			if($y.Tag["title"] -eq $j ){	# title line

				$script:doc_out+= " "	# space
			}

			if($j -eq $count[0] -and $script:bookmark -eq $y ){	# bookmark line

				$script:doc_out+= "`t"	# tab
			}

			if($j -ne ($arr.Length- 1)){	# max count

				$script:doc_out+= "`r`n"
			}
		} #

		# 空行分の出力

		# write-host ("y.Nodes.Count: "+ $y.Nodes.Count)

		if($y.Nodes.Count -gt 0){	# 子階層チェック

			$script:doc_out+= "`t"	# tab

			if($y.IsExpanded -eq "True"){	# node展開時

				$script:doc_out+= " "	# space
			}

			$script:doc_out+= "`r`n"

					#ここで、飲み込む。

			# 再帰で呼び出す場合、ローカル変数returnだとうまくいかない
			DocBuild $y 	# 再帰

			$script:doc_out+= $dd

					#段数分、ここから下へ吐き出す。

			$script:doc_out+= " "	# space

		}else{	# 兄弟node
			$script:doc_out+= " "	# space
		}

		#2408
		if($script:focus -eq $y -and $tree.Nodes[0] -ne $y){	# フォーカスあらば tab add、tree.Nodes[0]以外

			$script:doc_out+= "`t"	# tab
		}

		if($i -lt ($x.Nodes.Count- 1)){	# max count

			$script:doc_out+= "`r`n"
		}
	} #

 } # func
 
function ForwardFind($x){ 

	$y= $x			# $script:focus

	[array] $stuck= @($x)	# 最初にforcusノードから入れる

	[int] $i= 0
	[int] $sw= 1
	# for([int] $i= 0; $i -lt 20; $i++){
	while(1){

		if($i -gt 5000){

			[string] $qq= "検索ノードが、5000を超えました"

			Write-Host $qq

			#[string] $retn=  [Windows.Forms.MessageBox]::Show(
			#$qq, "確認", "OK","Information","Button1"
			#)

			break;	# 強制終了
		}

		if($sw -eq 1){

			if($y.FirstNode -ne $null){

				$y= $y.FirstNode	# 最初の子ツリー ノード
				#("FirstNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y

			}elseif($y.NextNode -ne $null){

				$y= $y.NextNode	# 兄弟ツリー ノード
				#("NextNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y
			}else{

				$sw= 0
			}

		}else{
			if($y.Parent.NextNode -ne $null){

				$y= $y.Parent.NextNode	# 親の兄弟ノード
				#("Parent.NextNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y
				$sw= 1

			}else{
				if($y.Level -gt 1){	# トップノード以外 <- 0だとエラー

					$y= $y.Parent	# いったん親へ戻る

				}else{
					$y= $tree.TopNode
					#("tree.TopNodefullpath: "+ $y.FullPath) | write-host

					if($y -eq $x){ break; }

					$stuck+= $y
					$sw= 1
				}
			}
		}


		$i++;

	} #

	$stuck+= $x	# 最後に回帰ノード検索分
	return $stuck
 } #func
 
function Down_search(){ 

	[array] $yy= ForwardFind $script:focus


	$search_node=  $script:focus
	$search_index= $editbox.SelectionStart


	[string] $rtn_str= $editbox.SelectedText		# "な"
	[int] $rtn_len= $editbox.SelectionLength		# 1


	[int] $dur= ([int] $editbox.SelectionStart)+ 1
	# write-host $editbox.Text.Length


	for([int] $i= 0;  $i -lt $yy.Length; $i++){

		if($i -eq 0){	# 同一ノード

			[int] $index_rtn= $yy[$i].Name.IndexOf($rtn_str, $dur, [System.StringComparison]::OrdinalIgnoreCase)
		}else{
			[int] $index_rtn= $yy[$i].Name.IndexOf($rtn_str, [System.StringComparison]::OrdinalIgnoreCase) # [列挙型] 区別しない
		}

		if($index_rtn -eq -1){	# node内に検索語がない

		}else{
			#write-host ("==="+ $script:search_node)
			#write-host ("==="+ $script:search_index)

			#if($yy[$i] -eq $script:search_node ){
			#	Write-Host ("- node - Restart"+ $script:search_node)
			#}
			#if($index_rtn -eq $script:search_index ){
			#	Write-Host ("- index - Restart"+ $script:search_index)
			#}

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


	$search_node=  $script:focus
	$search_index= $editbox.SelectionStart


	[string] $rtn_str= $editbox.SelectedText		# "な"
	[int] $rtn_len= $editbox.SelectionLength		# 1


	[int] $dur= ([int] $editbox.SelectionStart)- 1
	# write-host $editbox.Text.Length


	for([int] $i= 0;  $i -lt $yy.Length; $i++){

		if($i -eq 0){	# 同一ノード

			if($dur -ge 0){

				[int] $index_rtn= $yy[$i].Name.LastIndexOf($rtn_str, $dur, [System.StringComparison]::OrdinalIgnoreCase)

			}else{
				[int] $index_rtn= -1	# SelectionStart= 0時
			}
		}else{

			[int] $index_rtn= $yy[$i].Name.LastIndexOf($rtn_str, [System.StringComparison]::OrdinalIgnoreCase) # [列挙型] 区別しない
		}

		if($index_rtn -eq -1){	# node内に検索語がない

		}else{
			#write-host ("==="+ $script:search_node)
			#write-host ("==="+ $script:search_index)

			#if($yy[$i] -eq $script:search_node ){
			#	Write-Host ("- node - Restart"+ $script:search_node)
			#}
			#if($index_rtn -eq $script:search_index ){
			#	Write-Host ("- index - Restart"+ $script:search_index)
			#}

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
$tree.Size= "200, 420"
$tree.Location= "10, 10"
$tree.HideSelection= $False
# $tree.SelectedNode (equal) $_.Node


$tree.Add_AfterSelect({

	#"------" | write-host
	#("index: "+ $this.Nodes.IndexOf($_.Node)) | write-host
	#$this.TopNode.FullPath | write-host	# 初期は認識エラーが出るので、$tree.Nodes[0]とする
	#$_.Node.Parent.FullPath | write-host
	#$_.Node.PrevNode.LastNode.FullPath | write-host
	#$_.Node.PrevNode.FullPath | write-host
	#$_.Node.FullPath | write-host
	#$_.Node.NextNode.FullPath | write-host
	#$_.Node.FirstNode.FullPath | write-host
	#"------" | write-host

	$script:focus= $_.Node

	$focusbox.Text= $script:focus
	# $bookmarkbox.Text= $script:bookmark

	$counterbox.Text= $_.Node.Index
	# write-host ("_.Node.Index: "+ $_.Node.Index)

	$editbox.Text= $_.Node.Name
	$editindex.Text= $_.Node.Tag["title"]
	$editnum.Text= $_.Node.Tag["caret"]	#2408

	$editbox.SelectionStart= $_.Node.Tag["caret"]	# caret set
	$editbox.ScrollToCaret()	#2408
 })


$tree.Add_MouseDown({
 try{
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
 
$counter_lbl= New-Object System.Windows.Forms.Label 
$counter_lbl.Text= "counterbox" #2408

$counter_lbl.Size= "200,20"
$counter_lbl.Location= "10,430"
$counter_lbl.TextAlign= "MiddleCenter"
$counter_lbl.BorderStyle= "Fixed3D"
$counter_lbl.ForeColor= "black"
 
$counterbox= New-Object System.Windows.Forms.TextBox 
$counterbox.Text= "tree node index" #2408

$counterbox.Size= "200, 40"
$counterbox.Location= "10, 450"
$counterbox.Multiline= "True"
$counterbox.AcceptsReturn= "True"
$counterbox.AcceptsTab= "True"
$counterbox.ScrollBars= "Vertical"
 
# ------------ 
 
$edit_lbl= New-Object System.Windows.Forms.Label 
$edit_lbl.Text= "editbox"

$edit_lbl.Size= "200,20"
$edit_lbl.Location= "210,10"
$edit_lbl.TextAlign= "MiddleCenter"
$edit_lbl.BorderStyle= "Fixed3D"
$edit_lbl.ForeColor= "black"
#$edit_lbl.BackColor= "dodgerblue"
 
$editbox= New-Object System.Windows.Forms.TextBox 
$editbox.Text= "editbox"

$editbox.Size= "400, 200"
$editbox.Location= "210, 30"
$editbox.Multiline= "True"
$editbox.AcceptsReturn= "True"
$editbox.AcceptsTab= "True"
$editbox.ScrollBars= "Vertical"
$editbox.WordWrap= "True"

# $editbox.SelectedText
# $editbox.SelectionLength
# $editbox.SelectionStart


#.$editbox.Add_TextChanged({
#
#})

$editbox.Add_Leave({
#2408
	$script:focus.Tag["caret"]= $this.SelectionStart

	$script:focus.Name= $this.Text


	[string[]] $doc= $this.Text -split "`r`n"

	if($doc[0].Length -gt 0){

		$script:focus.Text=  $doc[0]	# 行頭
	}else{
		$script:focus.Text= "Untitled"
	}
 })

$editbox.Add_MouseDown({
 try{
	[string] $rtn= $_.Button	# $_はスイッチは通らない

	switch([string] $_.Button){
	'Right'{
	}'Left'{
		write-host ("Button: "+ $rtn)
		#write-host ("SelectionStart: "+ $this.SelectionStart)
		#write-host ("SelectionLength: "+ $this.SelectionLength)
		#write-host ("SelectedText: "+ $this.SelectedText)		# 右クリックなどで

		break;
	}'Middle'{
	}
	} #sw
 }catch{
	echo $_.exception
 }
 })
 
$index_lbl= New-Object System.Windows.Forms.Label 
$index_lbl.Text= "indexbox"

$index_lbl.Size= "200,20"
$index_lbl.Location= "210,230"
$index_lbl.TextAlign= "MiddleCenter"
$index_lbl.BorderStyle= "Fixed3D"
$index_lbl.ForeColor= "black"
#$index_lbl.BackColor= "dodgerblue"
 
$editindex= New-Object System.Windows.Forms.TextBox	#2408 
$editindex.Text= "edit title index"

$editindex.Size= "400, 40"
$editindex.Location= "210, 250"
$editindex.Multiline= "True"
$editindex.AcceptsReturn= "True"
$editindex.AcceptsTab= "True"
$editindex.ScrollBars= "Vertical"
 
$editnum= New-Object System.Windows.Forms.TextBox	#2408 
$editnum.Text= "edit caret"

$editnum.Size= "400, 40"
$editnum.Location= "210, 290"
$editnum.Multiline= "True"
$editnum.AcceptsReturn= "True"
$editnum.AcceptsTab= "True"
$editnum.ScrollBars= "Vertical"
 
$focus_lbl= New-Object System.Windows.Forms.Label 
$focus_lbl.Text= "focusbox"

$focus_lbl.Size= "200,20"
$focus_lbl.Location= "210,330"
$focus_lbl.TextAlign= "MiddleCenter"
$focus_lbl.BorderStyle= "Fixed3D"
$focus_lbl.ForeColor= "black"
 
$focusbox= New-Object System.Windows.Forms.TextBox 
$focusbox.Text= "forcusbox"

$focusbox.Size= "400, 40"
$focusbox.Location= "210, 350"
$focusbox.Multiline= "True"
$focusbox.AcceptsReturn= "True"
$focusbox.AcceptsTab= "True"
$focusbox.ScrollBars= "Vertical"
 
$bookmark_lbl= New-Object System.Windows.Forms.Label 
$bookmark_lbl.Text= "bookmarkbox"

$bookmark_lbl.Size= "200,20"
$bookmark_lbl.Location= "210,390"
$bookmark_lbl.TextAlign= "MiddleCenter"
$bookmark_lbl.BorderStyle= "Fixed3D"
$bookmark_lbl.ForeColor= "black"
 
$bookmarkbox= New-Object System.Windows.Forms.TextBox 
$bookmarkbox.Text= "bookmarkbox"

$bookmarkbox.Size= "400, 40"
$bookmarkbox.Location= "210, 410"
$bookmarkbox.Multiline= "True"
$bookmarkbox.AcceptsReturn= "True"
$bookmarkbox.AcceptsTab= "True"
$bookmarkbox.ScrollBars= "Vertical"
 
$bookmark_lbl= New-Object System.Windows.Forms.Label 
$bookmark_lbl.Text= "bookmarkbox"

$bookmark_lbl.Size= "200,20"
$bookmark_lbl.Location= "210,390"
$bookmark_lbl.TextAlign= "MiddleCenter"
$bookmark_lbl.BorderStyle= "Fixed3D"
$bookmark_lbl.ForeColor= "black"
 
$bookmarknum= New-Object System.Windows.Forms.TextBox	#2408 
$bookmarknum.Text= "bookmark caret"

$bookmarknum.Size= "400, 40"
$bookmarknum.Location= "210, 450"
$bookmarknum.Multiline= "True"
$bookmarknum.AcceptsReturn= "True"
$bookmarknum.AcceptsTab= "True"
$bookmarknum.ScrollBars= "Vertical"
 
# コンテキスト 
	 
$contxt_03= New-Object System.Windows.Forms.ToolStripMenuItem 
$contxt_03.Text= "Bookmark Select"
$contxt_03.Add_Click({

	$tree.SelectedNode= $script:bookmark

	$editbox.SelectionStart= $script:bookmark_caret	# caret set
	$editbox.ScrollToCaret()	#2408
	$editbox.focus()
 })


$contxt_bmk= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_bmk.Text= "Bookmark Set"
$contxt_bmk.Add_Click({

	$script:bookmark= $script:focus
	$script:bookmark_caret= $editbox.SelectionStart 	#2408
	$bookmarkbox.Text= $script:bookmark
 })


$contxt_title= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_title.Text= "Title Set"
$contxt_title.Add_Click({

	[int] $num= $editbox.SelectionStart 	#2408
	write-host("num: "+ $num)

	[int[]] $count= Line_index $num $editbox.Text
	write-host("count[0]: "+ $count[0])

	$script:focus.Tag["title"]= $count[0]	# title index
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

	[string] $clip= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

	if($clip -eq "tree.nodes.data.flag.clipboard"){

		NodePaste ""
	}else{
		PlainPaste ""
	}
 })

$contxt_add= New-Object System.Windows.Forms.ToolStripMenuItem
$contxt_add.Text= "Add Paste"
$contxt_add.Add_Click({

	[string] $clip= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

	if($clip -eq "tree.nodes.data.flag.clipboard"){

		NodePaste "add"
	}else{
		PlainPaste "add"
	}
 })

 
$contxt_12= New-Object System.Windows.Forms.ToolStripMenuItem 
$contxt_12.Text= "Child Paste"
$contxt_12.Add_Click({

	[string] $clip= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

	if($clip -eq "tree.nodes.data.flag.clipboard"){

		NodeChildPaste
	}else{
		PlainChildPaste
	}
 })
 
$contxt= New-Object System.Windows.Forms.ContextMenuStrip 

$contxt.Items.AddRange(@($contxt_bmk, $contxt_title, $contxt_cut, $contxt_copy, $contxt_paste, $contxt_add, $contxt_12))
$contxt.Items.Insert(0, $contxt_03) # list object
  
$btn0= New-Object System.Windows.Forms.Button 
$btn0.Size= "100,100"
$btn0.Location= "10, 510"
$btn0.FlatStyle= "Popup"
$btn0.text= "select text down search"

$btn0.Add_Click({

	if($editbox.SelectedText -ne ""){

		Down_search
	}
 })
 
$btn1= New-Object System.Windows.Forms.Button 
$btn1.Size= "100,100"
$btn1.Location= "110, 510"
$btn1.FlatStyle= "Popup"
$btn1.text= "select text upper search"

$btn1.Add_Click({

	if($editbox.SelectedText -ne ""){

		Upper_search
	}
 })
 
$btn2= New-Object System.Windows.Forms.Button 
$btn2.Size= "100,100"
$btn2.Location= "210, 510"
$btn2.FlatStyle= "Popup"
$btn2.text= "doc file write UTF8 bom"

$btn2.Add_Click({

	$script:focus.Name= $editbox.Text

	$script:doc_out= ""	#2408

	DocBuild $tree

	$script:doc_out+= "`r`n"	# 再帰なのでここで追加
				# [System.IO.File]::WriteAllTextでは必要、Out-Fileでは不要
	# write-host ("====")
	# write-host ("script:doc_out: "+ $script:doc_out)
	# write-host ("====")

	# $script:doc_out | Out-File -Encoding "utf8BOM" -FilePath ".\TEST-01.txt" # UTF8 bom

	[object] $bom= New-Object System.Text.UTF8Encoding($True)	# UTF8bom
	[System.IO.File]::WriteAllText(".\TEST-01.txt", $script:doc_out, $bom)

	Write-Host ""
	Write-Host "UTF8bom file write"
 })
 
$btn3= New-Object System.Windows.Forms.Button 
$btn3.Size= "100,100"
$btn3.Location= "310, 510"
$btn3.FlatStyle= "Popup"
$btn3.text= "doc file write UTF8 no bom"

$btn3.Add_Click({

	$script:focus.Name= $editbox.Text

	$script:doc_out= ""	#2408

	DocBuild $tree

	$script:doc_out+= "`r`n"	# 再帰なのでここで追加
				# [System.IO.File]::WriteAllTextでは必要、Out-Fileでは不要
	# write-host ("====")
	# write-host ("script:doc_out: "+ $script:doc_out)
	# write-host ("====")

	# $script:doc_out | Out-File -Encoding "utf8NoBOM" -FilePath ".\TEST-01.txt" # UTF8 bomなし

	[object] $nobom= New-Object System.Text.UTF8Encoding($False)	# UTF8nobom
	[System.IO.File]::WriteAllText(".\TEST-01.txt", $script:doc_out, $nobom)

	Write-Host ""
	Write-Host "UTF8nobom file write"
 })
 
$btn4= New-Object System.Windows.Forms.Button 
$btn4.Size= "100,100"
$btn4.Location= "410, 510"
$btn4.FlatStyle= "Popup"
$btn4.text= "doc file write shiftJIS"

$btn4.Add_Click({

	$script:focus.Name= $editbox.Text

	$script:doc_out= ""	#2408

	DocBuild $tree

	$script:doc_out+= "`r`n"	# 再帰なのでここで追加
				# [System.IO.File]::WriteAllTextでは必要、Out-Fileでは不要
	# write-host ("====")
	# write-host ("script:doc_out: "+ $script:doc_out)
	# write-host ("====")

	# $script:doc_out | Out-File -Encoding "OEM" -FilePath ".\TEST-01.txt" # shiftJIS

	[System.IO.File]::WriteAllText(".\TEST-01.txt", $script:doc_out, [System.Text.Encoding]::GetEncoding(932))	# shiftJIS

	Write-Host ""
	Write-Host "shiftJIS file write"
 })
 
$stus= New-Object System.Windows.Forms.StatusStrip 
$stus.SizingGrip= $false

$stus_label= New-Object System.Windows.Forms.ToolStripStatusLabel
$stus_label.Text= "Encoding"
# $stus_label.Font= $FonLabel
 
$frm= New-Object System.Windows.Forms.Form 
$frm.Size= @(640, 700) -join "," # string出力
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

$frm.Add_FormClosing({
#2408
	[string] $clip= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

	if($clip -eq "tree.nodes.data.flag.clipboard"){

		[Windows.Forms.Clipboard]::SetText("", [Windows.Forms.TextDataFormat]::UnicodeText)
		# 再起動時の整合性ため空を送る
	}
 })

$frm.Add_Load({

	# TreeBuild (cat '.\TEST.txt' | Out-String)

	# $tree.SelectedNode= $script:focus
	# $bookmarkbox.Text= $script:bookmark
#2408
	$tree.Nodes.Add("Untitled")

	$tree.Nodes[0].Tag= @{}		# hash
	$tree.Nodes[0].Tag["title"]= 0	# title index
	$tree.Nodes[0].Tag["caret"]= 0	# 0 caret	#2408

 	$tree.Nodes[0].Name= ""

	# $script:focus= $tree.Nodes[0]
})

# $frm.Add_Resize({
#  })

$frm.AllowDrop= $True

$frm.Add_DragEnter({

	$_.Effect= "All"
})

$frm.Add_DragDrop({
  try{
	[string[]] $rtn= $_.Data.GetData("FileDrop")

	$tree.Nodes.Clear()	# TreeNodeCollection クラス

	$script:bookmark= ""
	$script:bookmark_caret= 0


	[string[]] $dec= .\character_code.ps1 $rtn[0]
	$stus_label.Text= $dec[1]

	$tree.Visible= $false

	# TreeBuild (Get-Content -Encoding "utf8NoBOM" $rtn[0] | Out-String)
	TreeBuild $dec[0]

	$tree.Visible= $true


	$tree.SelectedNode= $script:focus
	$bookmarkbox.Text= $script:bookmark
	$bookmarknum.Text= $script:bookmark_caret	#2408

  }catch{
	echo $_.exception
  }
})
 
$stus.Items.AddRange(@($stus_label)) 

$frm.Controls.AddRange(@($tree))
$frm.Controls.AddRange(@($edit_lbl, $editbox, $index_lbl, $editindex, $editnum, $focus_lbl, $focusbox, $bookmark_lbl, $bookmarkbox, $bookmarknum, $counter_lbl, $counterbox))
$frm.Controls.AddRange(@($btn0, $btn1, $btn2,$btn3,$btn4, $stus))
#下は後ろ側
 
[object] $script:focus= "" 
[object] $script:node_clip= ""	# copy,paste
[object] $script:bookmark= ""
[int] $script:bookmark_caret= 0
[string] $script:doc_out= ""

$frm.ShowDialog() > $null
 
read-host "pause" 
 
