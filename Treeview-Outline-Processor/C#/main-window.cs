using System; 
using System.Drawing;
using System.Windows.Forms;
 using System.IO;
using System.Text;	// Encoding.GetEncoding を使用するのに必要


class Main_form : Form
{
	public TreeView tree_view= new TreeView()
	{
		Size=  new Size(200, 500),
		Location=  new Point(10, 10),
		HideSelection= false,
	};

	TextBox edit_box= new TextBox()
	{
		Size=  new Size(400, 200),
		Location=  new Point(220, 10),
		Multiline = true,
		AcceptsReturn= true,
	};

	TextBox focus_box= new TextBox()
	{
		Size=  new Size(400, 100),
		Location=  new Point(220, 220),
		Multiline = true,
	};

	//Text_box3 text_class3;
	// public int test= 10;
	private int test= 10;


	// プロパティを用意するとよい - 初期値がある場合
	public int Proper
	{
		set{ this.test= value; }
		get{ return this.test; }
	}

	// 自動実装プロパティ #5.0は初期値できない
	public int Proper2{ get; set; }


	public Main_form(string[] args_path)	// constructor 返値はない
	{
		try{
			{	// Form
				Text= "Test Form";
				Size= new Size(646, 626);
				Font= new Font("Segoe UI", 11);
				AllowDrop= true;
			}

			this.DragEnter+= (sender, e)=>
			{
				e.Effect= DragDropEffects.All;
			};

			this.DragDrop+= (sender, e)=>
			{
				string[] file_name= (string[]) e.Data.GetData(DataFormats.FileDrop);
				tree_view.Nodes.Clear();	// TreeNodeCollection クラス

				string file_txt= File.ReadAllText(file_name[0], Encoding.UTF8);

				Tree_Build.TreeBuild (this,file_txt );
				tree_view.SelectedNode= Tree_Build.focus;
			};

			string file_doc= File.ReadAllText(@".\TEST.txt", Encoding.UTF8);
			// TreeBuild (cat '.\TEST.txt' | Out-String)

			Tree_Build.TreeBuild(this, file_doc );
			tree_view.SelectedNode= Tree_Build.focus;


			this.Controls.AddRange(new Control[] { tree_view, edit_box, focus_box } );

		//	text_class2= new Text_box2(this );
		//	text_class3= new Text_box3(this );


			this.MouseDown+= (sender, e)=>
			{
			};

			tree_view.AfterSelect+= (sender, e)=>
			{
				// Console.WriteLine("click! window test"+ e.Node.Name);

				Tree_Build.focus= e.Node;
				// counterbox.Text= e.Node.Tag;

				edit_box.Text= (string) e.Node.Name;
				// focusbox.Text= focus;
			};

		//	this.Closed+= (sender, e)=>
		//	{
		//		// player_inst.ok_player.Stop();
		//		// player_inst.ok_player.Close();
		//		// player_inst.tim.Stop();
		//		// player_inst.tim2.Stop();

		//		Console.WriteLine("click! window Closed");
		//	};

		}catch (Exception ex){

			Console.WriteLine("ERR: main-window-constructor >");
			Console.WriteLine(ex);
		}finally{
			// this.Dispose();
		}
	}
/*
	void TreeBuild(string readtext )
	{

		string sentinel= "^^End_Of_Finish$$";	// 番兵
		bool sentinel_sw= false;				// $y.Nodes.AddRangeキャンセル

		string[] textdoc= readtext.Split(new string[] {"\r\n"} , StringSplitOptions.None);
		// StringSplitOptions.None引数必要

		string[] textline=  new string[textdoc.Length- 2];

		Array.Copy(textdoc, 0, textline, 0, textdoc.Length- 2 );	// ,org index, ,copy index, length
		//textline= textdoc[0..($textdoc.Length- 2)];

		Array.Resize(ref textline, textline.Length+ 1 );
		textline[textline.Length- 1]= sentinel;
		//textline+= sentinel;

		Array.Resize(ref textline, textline.Length+ 1 );
		textline[textline.Length- 1]= textdoc[textdoc.Length- 1];
		//textline+= textdoc[-1];
		// EOFカット不要



		string label= "";
		string mem= "";
		int j= 0;

		tree.Nodes.Add("Parent Untitled");

		TreeNode y= tree.Nodes[0];

		// $tree.Nodes[0].Text= "ボトムノード"	# .Text - title

		y.Tag= j;
		focus= y;		// 初期のフォーカス設定

		// y.Nodes.AddRange(new TreeNode[] {y, y} );

		object[] arr_node= new object[2] { tree, y };	// 配列初期化
		// arr_node	tree		child	2nd child	3rd child
		//					brother	brother		brother



		// Console.WriteLine("Tree-Build arr_node: "+ arr_node[1]);
		// write-host ("arr[1]: "+ $arr[1])
		// write-host ("arr[1].Tag: "+ $arr[1].Tag)
		// write-host ""


		for(int i= 0; i < textline.Length; i++){

			// 空行と番兵分岐

			if( textline[i] == sentinel ){
			// 最終行[-2]確認

				sentinel_sw= true;


			}else if(Regex.IsMatch(textline[i], "^\t *$") == true){  // `t`s* - tabで始まり、spaceがあるかないか
				// textline[i] -match "^\t\s*$"
				// 子ノードへ+ 開状況チェック

				y.Name= mem;	// ここで入力
				// write-host ("y.Name: "+ $y.Name)

				mem= "";
				y.Nodes.Add("Child Untitled");		// 1階層下へ

				if( textline[i].Contains(" ") ){	// `s 開状況

					//write-host ("tab child open label: "+ $textline[$i])
					y.Expand();	// AddRange後

				}else{
					// write-host ("tab child label: "+ $textline[$i])
				}

				y= y.Nodes[0];
				j= 0;
				y.Tag=  j;

				Array.Resize(ref arr_node, arr_node.Length+ 1 );
				arr_node[arr_node.Length- 1]= y;

				// arr+= y		# 下位階層store
				// write-host ("child arr: "+ $arr)

			}else if(Regex.IsMatch(textline[i], "^ $") == true){	//`s - 先頭スペース行末
			// 兄弟ノード確認

				y.Name= mem;	// ここで入力
				// write-host ("y.Name: "+ $y.Name)
				// Console.WriteLine("Tree-Build 兄弟ノード: ");

				mem= "";

				if (sentinel_sw == false ){	// 最終行以外

					y= (TreeNode) arr_node[arr_node.Length- 1];
					j= (int) y.Tag;		// 添字を取得


					if(arr_node.Length > 2){	// $script:focus.Parent -eq $nullのため

			// Console.WriteLine("Tree-Build Length > 2: "+ arr_node.Length);

						y= (TreeNode) arr_node[arr_node.Length- 2];	// parent
						y.Nodes.Add("Next Untitled");

						j++;
						y= y.Nodes[j];

					}else{	// arr_node[0]

			// Console.WriteLine("Tree-Build tree: "+ arr_node.Length);

						tree.Nodes.Add("Next Untitled");

						j++;
						y= tree.Nodes[j];
					}

					y.Tag= j;

					arr_node[arr_node.Length- 1]= y;	// 兄弟ノードストア

					// write-host ("parent arr: "+ $arr)
					// write-host ("single space:"+ $textline[$i])
				}


			}else if(Regex.IsMatch(textline[i], "^( |\t)+$") ){  // まずspace、(space | tab)がある
			// }elseif( textline[i] -match "^ ( |`t)+$" ){
			// 回帰ノード、フォーカスタブチェック、開状況のチェックは必要ない

				y.Name= mem;	// ここで入力
				// write-host ("y.Name: "+ $y.Name)

				mem= "";
				string ss= "";
				// string tt= " ";	// `s

				if(Regex.IsMatch(textline[i], "\t") == true){
				// タブまでの個数計算

					int nn= textline[i].IndexOf("\t");
					string dd= textline[i].Substring(0, nn);


					int dt_len= dd.Length;	// スペース分、階層下へ
					// Math.Floor(dd.Length/ tt.Length);

					dt_len= arr_node.Length- dt_len;

					y= (TreeNode) arr_node[dt_len];

					focus= y	;	// フォーカス設定
					// write-host ("forcus set : "+ y)
					ss= textline[i].Replace("\t", "");

					// write-host ("forcus tab found: "+ $textline[$i])

				}else{
					ss= textline[i];	// space only
					// write-host ("space's only: "+ $textline[$i])
				}


				if (sentinel_sw == false){		// 最終行以外

					int len= ss.Length;		// スペース分、同階層下へ
					len= arr_node.Length- len;

					y= (TreeNode) arr_node[len];

					j= (int) y.Tag;		// 添字を取得


					if(len > 1){	// $script:focus.Parent -eq $nullのため

						y= (TreeNode) arr_node[len- 1];	// parent
						y.Nodes.Add("Next Untitled");

						j++;
						y= y.Nodes[j];

					}else{
						tree.Nodes.Add("Next Untitled");

						j++;
						y= tree.Nodes[j];
					}

					y.Tag= j;

			// Console.WriteLine("Tree-Build Len: "+ len);

					Array.Resize(ref arr_node, len+ 1 );	// tree分+1
					arr_node[arr_node.Length- 1]= y;	// 配列カットのち、代入
					// write-host ("parent arr: "+ $arr)
				}


			}else{
				// def.ライン処理

				// $textline[$i]= $textline[$i].Replace(" ","")	# `s - 正規表現のほうが安全
				// $y.Tag=  ("","")				# 項目増やす場合
				// $y.Tag[0]=  $counter
				// $y.Tag[1]=  $mem


				if(Regex.IsMatch(textline[i], " \t$") == true){
				// if( textline[i] -match "`s`t$"){	// `s`t label+ bookmark

					// $label= [System.Text.RegularExpressions.Regex]::Matches( $textline[$i] , ".*(?= `t$)")	# `s`t

					label= textline[i].Replace(" \t$","");

					////label= label.Trim(" ");	// exp -> last space cutting
					// write-host ("title+ bookmark label: "+ $label )

					bookmark= y;
					y.Text= label;

				}else if(Regex.IsMatch(textline[i], " $") == true){	// label
				//}else if(textline[i] -match " $" ){

					// $label= [System.Text.RegularExpressions.Regex]::Matches( $textline[$i] , ".*(?= $)")	# `s

					label= textline[i].Replace(" $","");

					////label= label.Trim(" ");

					y.Text= label;

					// write-host ("title label: "+ $y.Text )

				}else if(Regex.IsMatch(textline[i], "\t$") == true){	// bookmark
				// }else if(textline[i] -match "`t$"){

					// $label= [System.Text.RegularExpressions.Regex]::Matches( $textline[$i] , ".*(?=`t$)")

					label= textline[i].Replace("\t$","");

					////label= label.Trim(" ");
					// write-host ("bookmark label: "+ $label )
					bookmark= y;

				}else{

					label= textline[i];
					// write-host ("def.label: "+ $label )
				}

				mem+= label+ "\r\n";	// ここでtext add
				label= "";

				// Console.WriteLine("Tree-Build mem: "+mem);
			}
		} //
	}	// method
*/
}	//class
