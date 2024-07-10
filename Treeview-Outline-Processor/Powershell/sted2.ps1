# counter box�̃i���o�[�o�� 
 
# �^�C�g���ʒu�̕ύX�@�g�ݍ��� 
 
Add-Type -AssemblyName System.Windows.Forms > $null 
Add-Type -AssemblyName System.Drawing > $null

cd (Split-Path -Parent $MyInvocation.MyCommand.Path)
[Environment]::CurrentDirectory= pwd # working_dir set
 
function NodePaste([string] $sw){ 

	if($script:focus.Level -eq 0){	# $script:focus.Parent -eq $null�̂���

		[object] $y= $tree.Nodes
	}else{
		[object] $y= $script:focus.Parent.Nodes	# forcus�m�[�h�̉���add
	}

	if($sw -eq "add"){

		[int] $ee= $y.IndexOf($script:focus)
		[int] $nn= $ee+ 1	# ���m�[�h		# .Insert node
	}else{
		[int] $nn= $y.IndexOf($script:focus)	# .Insert node
		##[int] $ee= $nn+ 1	#���m�[�h
	}


	$y.Insert($nn, $script:node_clip.Clone())


	##[object] $x= $y[$ee]
	##$x.Tag= $ee

	[object] $z= $y[$nn]

	## $z.Tag= $nn	## �s�v


	$script:focus= $z	# reforcus
	$tree.SelectedNode=  $script:focus

 } # func
 
function PlainPaste([string] $sw, [bool] $new){	# plain text 

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


	[bool] $new= [Windows.Forms.Clipboard]::ContainsText()	# text document �`�F�b�N

	if($new){

		[string] $cc= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

		[string[]] $doc= $cc -split "`r`n"	

		$obj.Text= $doc[0]	# �s��

		$obj.Name=  $cc	# clipboard
	}


	$tree.SelectedNode= $obj	# refocus

 } #func
 
function ChildPaste([string] $sw, [bool] $new){ 

	if($sw -eq "node"){

		[object] $y= $script:focus

		# $y.Nodes.AddRange($script:node_clip.Clone())	# ����ł��ǂ�
		$y.Nodes.Insert(0, $script:node_clip.Clone())	# node list object first child paste

		$y.Expand()	# �J��

		##$y.Nodes[0].Tag= 0 ## �s�v

		$script:focus= $y.Nodes[0]	# refocus
		$tree.SelectedNode= $script:focus

	}else{
		[object] $y= $script:focus

		$y.Nodes.AddRange(@("Untitled"))	# ����ł��ǂ�
		# $y.Nodes.Insert(0, "Untitled")	# node list object first child paste

		$y.Expand()	# �J��


		[bool] $new= [Windows.Forms.Clipboard]::ContainsText()	# text document �`�F�b�N

		if($new){
			[string] $cc= [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)

			[string[]] $dd= $cc -split "`r`n"

			$y.Nodes[0].Text= $dd[0]	# �s��

			$y.Nodes[0].Name=  $cc	# clipboard
		}

		## $y.Nodes[0].Tag= 0 ## �s�v

		$script:focus= $y.Nodes[0]	# refocus
		$tree.SelectedNode= $script:focus
	}
 } #func
 
function TreeBuild([string] $readtext){ 


	# example (?<=^@OP)[0-9]+(?=\s*=)

	[string[]] $textline= [System.Text.RegularExpressions.Regex]::Matches($readtext , "(?<=`r`n)(`t| )+?(?=`r`n)")
	# �^�uor�X�y�[�X����ȏ�ŒZ��v
	# ��s�A�q�b�g��z���

	#write-host ("textline: "+ $textline.Length)


	[string[]] $textdoc= [System.Text.RegularExpressions.Regex]::Matches($readtext , "(^|(?<=`r`n(`t| )+?`r`n))(.|`r`n)*?(?=`r`n(`t| )+?`r`n)" )
	# �擪or��ǂ݋�s�@.or`r`n �ŒZ��v�@��ǂ݋�s
	# �{���A�q�b�g��z���

	for([int] $i= 0; $i -lt $textdoc.Length; $i++){
		$textdoc[$i]+= "`r`n"	# ��i�̂��ߍŏI�s�։��s�t�^
	} #

	#write-host ("textdoc: "+ $textdoc)


	# [string] $label= ""
	[int] $j= 0


	$tree.Nodes.Add("Untitled")

	[object] $y= $tree.Nodes[0]


	$tree.Nodes[0].Text= "�{�g���m�[�h"	# .Text - title

	$y.Tag= $j
	$script:focus= $y	# �����̃t�H�[�J�X�ݒ�

	# $y.Nodes.AddRange(@("3Untitled", "4Untitled"))


	[array] $arr= $tree, $y	# �K�w���Ƃ̍ŏI�m�[�h


	for([int] $i= 0; $i -lt $textline.Length; $i++){

		# �{������


		$y.Text= [System.Text.RegularExpressions.Regex]::Match( $textdoc[$i] , "(^|(?<=`r`n)).*(?= `t?($|`r`n))")
		# �^�C�g��

		# �擪or��ǂ݉��s�Ŏn�܂�@�^�C�g���@�s��or��ǂ݃X�y�[�X�^�u����Ȃ����s�A�ŏ��̂݃q�b�g
		# �s���͈�s���Ή�����


		if($textdoc[$i] -match "`t`r`n"){  # �s����tab������

			$script:bookmark= $y
			# write-host ("bookmark set : "+ $script:bookmark)
		}

		$y.Name= [System.Text.RegularExpressions.Regex]::Replace($textdoc[$i], " `t?`r`n", "`r`n")
		# �X�y�[�X�^�u�s�̃S�~�J�b�g�A`s`t?`r`n -> `r`n



		# ��s����
		if( $textline[$i] -match "^`t ?$"){  # `t`s? - tab�Ŏn�܂�Aspace�����邩�Ȃ���
		# �q�m�[�h��+ �J�󋵃`�F�b�N


			$y.Nodes.Add("Child Untitled")		# 1�K�w����


			if( $textline[$i].Contains(" ") -eq $True){	# `s �J��

				$y.Expand()	# Add��
			}

			$y= $y.Nodes[0]
			$j= 0
			$y.Tag=  $j

			$arr+= $y		# ���ʊK�wstore
			# write-host ("child arr: "+ $arr)


		}elseif( $textline[$i] -match "^ ( |`t)*$" ){  # �܂�space�A(space | tab)������Ȃ�
		# �t�H�[�J�X�^�u����A�Z��Ɖ�A�m�[�h�A�J�󋵂̃`�F�b�N�͕K�v�Ȃ�


			if($textline[$i].Contains("`t") -eq $True){
			# �^�u�܂ł̌��v�Z


				[int] $nn= $textline[$i].IndexOf("`t")

				[string] $dd= $textline[$i].Substring(0, $nn)


				[int] $dt_len= $dd.Length	# ���K�w���ւ̃X�y�[�X��

				$dt_len= $arr.Length- $dt_len

				$y= $arr[$dt_len]

				$script:focus= $y	# �t�H�[�J�X�ݒ�
				# write-host ("forcus set : "+ $script:focus)


				[string] $ss= $textline[$i].Replace("`t", "")	# �^�u�J�b�g


			}else{
				[string]  $ss= $textline[$i]

			}


			if ($i -lt $textline.Length- 1 ){	# �ŏI�s�ȊO


				[int] $len= $ss.Length	# ���K�w���ւ̃X�y�[�X��

				$len= $arr.Length- $len
				$y= $arr[$len]	# ��A�m�[�h��


				$j= $y.Tag	# �Y�����擾


				$y= $arr[($len- 1)]	# parent

				$y.Nodes.Add("Next Untitled")

				$j++;
				$y= $y.Nodes[$j]

				$y.Tag= $j

				$arr= $arr[0..($len)]
				$arr[-1]= $y

				# write-host ("parent arr: "+ $arr)
			}


		}else{
			write-host ("TreeBuild: ���炩�̃G���[")
			break;
		}
	} #
 } #func
	 
<#		TreeBuild ��s���� 

		}elseif( $textline[$i] -match "^ $" ){  #`s - �擪�X�y�[�X�s��
		# �Z��m�[�h�m�F

			if ($i -lt $textline.Length- 1 ){	# �ŏI�s�ȊO

				##[int] $len= $arr.Length- 1	##

				$y= $arr[- 1]

				$j= $y.Tag	# �Y�����擾


				$y= $arr[- 2]	# parent
				$y.Nodes.Add("Next Untitled")

				$j++;
				$y= $y.Nodes[$j]

				$y.Tag= $j

				## $arr= $arr[0..($arr.Length- 1)]	##�s�v
				$arr[-1]= $y

				# write-host ("parent arr: "+ $arr)
				# write-host ("single space:"+ $textline[$i])
			}

#>
  
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

		# ��s���̏o��

		if($y.Nodes.Count -gt 0){	# �q�K�w�`�F�b�N

			$output+= "`t"	# tab

			if($y.IsExpanded -eq "True"){	# node�W�J��

				$output+= " "	# space
			}

			$output+= "`r`n"
					#�����ŁA���ݍ��ށB

			$output+= DocBuild $y 	# �ċA

					#�i�����A�������牺�֓f���o���B

			$output+= " "	# space

		}else{	# �Z��node
			$output+= " "	# space
		}

		if($focus -eq $y){	# �t�H�[�J�X�����add

			$output+= "`t"	# tab
		}

		if($i -lt ($x.Nodes.Count- 1)){	# max count

			$output+= "`r`n"
		}
	} #

	return $output
 } # func
 
function ForwardFind($x){ 

	$y= $x			# $script:focus

	[array] $stuck= @($x)	# �ŏ���forcus�m�[�h��������

	[int] $i= 0
	[int] $sw= 1
	# for([int] $i= 0; $i -lt 20; $i++){
	while(1){

		if($i -gt 5000){

			[string] $qq= "�����m�[�h���A5000�𒴂��܂���"

			Write-Host $qq

			#[string] $retn=  [Windows.Forms.MessageBox]::Show(
			#$qq, "�m�F", "OK","Information","Button1"
			#)

			break;	# �����I��
		}

		if($sw -eq 1){

			if($y.FirstNode -ne $null){

				$y= $y.FirstNode	# �ŏ��̎q�c���[ �m�[�h
				#("FirstNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y

			}elseif($y.NextNode -ne $null){

				$y= $y.NextNode	# �Z��c���[ �m�[�h
				#("NextNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y
			}else{

				$sw= 0
			}

		}else{
			if($y.Parent.NextNode -ne $null){

				$y= $y.Parent.NextNode	# �e�̌Z��m�[�h
				#("Parent.NextNodefullpath: "+$y.FullPath) | write-host

				if($y -eq $x){ break; }

				$stuck+= $y
				$sw= 1

			}else{
				if($y.Level -gt 1){	# �g�b�v�m�[�h�ȊO <- 0���ƃG���[

					$y= $y.Parent	# ��������e�֖߂�

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

	$stuck+= $x	# �Ō�ɉ�A�m�[�h������
	return $stuck
 } #func
 
function Down_search(){ 

	[array] $yy= ForwardFind $script:focus


	$search_node=  $script:focus
	$search_index= $editbox.SelectionStart


	[string] $rtn_str= $editbox.SelectedText		# "��"
	[int] $rtn_len= $editbox.SelectionLength		# 1


	[int] $dur= ([int] $editbox.SelectionStart)+ 1
	# write-host $editbox.Text.Length


	for([int] $i= 0;  $i -lt $yy.Length; $i++){

		if($i -eq 0){	# ����m�[�h

			[int] $index_rtn= $yy[$i].Name.IndexOf($rtn_str, $dur, [System.StringComparison]::OrdinalIgnoreCase)
		}else{
			[int] $index_rtn= $yy[$i].Name.IndexOf($rtn_str, [System.StringComparison]::OrdinalIgnoreCase) # [�񋓌^] ��ʂ��Ȃ�
		}

		if($index_rtn -eq -1){	# node���Ɍ����ꂪ�Ȃ�

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

			break;	# �����Ń��[�v�u���C�N
		}
	} #
 } # func
 
function Upper_search(){ 

	[array] $yy= ForwardFind $script:focus


	$yy= $yy[$yy.Length.. 0]	# �z�񔽓] " [array]::Reverse($yy) "�ł��悢


	$search_node=  $script:focus
	$search_index= $editbox.SelectionStart


	[string] $rtn_str= $editbox.SelectedText		# "��"
	[int] $rtn_len= $editbox.SelectionLength		# 1


	[int] $dur= ([int] $editbox.SelectionStart)- 1
	# write-host $editbox.Text.Length


	for([int] $i= 0;  $i -lt $yy.Length; $i++){

		if($i -eq 0){	# ����m�[�h

			if($dur -ge 0){

				[int] $index_rtn= $yy[$i].Name.LastIndexOf($rtn_str, $dur, [System.StringComparison]::OrdinalIgnoreCase)

			}else{
				[int] $index_rtn= -1	# SelectionStart= 0��
			}
		}else{

			[int] $index_rtn= $yy[$i].Name.LastIndexOf($rtn_str, [System.StringComparison]::OrdinalIgnoreCase) # [�񋓌^] ��ʂ��Ȃ�
		}

		if($index_rtn -eq -1){	# node���Ɍ����ꂪ�Ȃ�

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

			break;	# �����Ń��[�v�u���C�N
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

	#"------" | write-host
	#("index: "+ $this.Nodes.IndexOf($_.Node)) | write-host
	#$this.TopNode.FullPath | write-host
	#$_.Node.Parent.FullPath | write-host
	#$_.Node.PrevNode.LastNode.FullPath | write-host
	#$_.Node.PrevNode.FullPath | write-host
	#$_.Node.FullPath | write-host
	#$_.Node.NextNode.FullPath | write-host
	#$_.Node.FirstNode.FullPath | write-host
	#"------" | write-host

	$script:focus= $_.Node
	$counterbox.Text= $_.Node.Tag
	$editbox.Text= $_.Node.name
	$focusbox.Text= $script:focus

	# $bookmarkbox.Text= $script:bookmark
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


#.$editbox.Add_TextChanged({
#
#})

$editbox.Add_Leave({

	$script:focus.Name= $this.Text

	[string[]] $dd= $this.Text -split "`r`n"

	$script:focus.Text=  $dd[0]	# �s��
 })

$editbox.Add_MouseDown({
 try{
	[string] $rtn= $_.Button	# $_�̓X�C�b�`�͒ʂ�Ȃ�

	switch([string] $_.Button){
	'Right'{
	}'Left'{
		write-host ("Button: "+ $rtn)
		#write-host ("SelectionStart: "+ $this.SelectionStart)
		#write-host ("SelectionLength: "+ $this.SelectionLength)
		#write-host ("SelectedText: "+ $this.SelectedText)		# �E�N���b�N�Ȃǂ�

		break;
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
$counter_lbl.Text= "counterbox tree build only"
$counter_lbl.Size= "200,20"
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
 
# �R���e�L�X�g 
	 
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

		ChildPaste "node"
	}else{
		ChildPaste ""
	}
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

	$script:focus.Name= $editbox.Text

	[string] $rtn= DocBuild $tree
	write-host ("====")
	$rtn | write-host
	write-host ("====")

	$rtn | Out-File -Encoding UTF8 -FilePath ".\TEST-01.txt" # UTF8

	# $rtn | Out-File -Encoding oem -FilePath ".\TEST-01.txt" # shiftJIS
 })
 
$frm= New-Object System.Windows.Forms.Form 
$frm.Size= @(640, 660) -join "," # string�o��
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

	$script:focus.Name= $editbox.Text
 })

$frm.Add_Load({

	TreeBuild (cat '.\TEST.txt' | Out-String)

	$tree.SelectedNode= $script:focus
	$bookmarkbox.Text= $script:bookmark

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

	$tree.Nodes.Clear()	# TreeNodeCollection �N���X

	TreeBuild (cat $rtn[0] | Out-String)

	$tree.SelectedNode= $script:focus
	$bookmarkbox.Text= $script:bookmark

  }catch{
	echo $_.exception
  }
})
 
$frm.Controls.AddRange(@($tree)) 
$frm.Controls.AddRange(@($edit_lbl, $editbox, $focus_lbl, $focusbox, $bookmark_lbl, $bookmarkbox, $counter_lbl, $counterbox))
$frm.Controls.AddRange(@($btn0, $btn1, $btn2))
#���͌�둤
 
[object] $script:focus= "" 
[object] $script:node_clip= ""
[object] $script:bookmark= ""


[bool] $script:test= $True

$frm.ShowDialog() > $null
 	
read-host "pause" 
 
