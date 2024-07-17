using System; 
using System.Windows.Forms;
using System.Text.RegularExpressions;

// treebuild 最終改行がなくても、最終ノードに取り込める
//  docnode 最終改行を出力する


class Tree_Build	// static
{
	static public TreeNode focus;		// ストアフォーカス
	static public TreeNode bookmark;	// インスタンス共有となるため、クラス名でアクセス
	static public TreeNode node_clip;

	static public string DocNode( TreeNode x )	// treenode -> treenode overload
	{
		TreeNode y;

		string output= "";

		// Console.WriteLine(x.Nodes.Count);
		for( int i= 0; i < x.Nodes.Count; i++){

		 	y= x.Nodes[i];

			string bmk= "";

			if(bookmark == y ){
				bmk= "\t";	// tab
			}

			// write-host("fullpath: "+ $y.FullPath)
			string[] arr= y.Name.Split(new string[] { "\r\n" },  StringSplitOptions.None);

			for(int j= 0; j < arr.Length; j++){	// y.Name
			// 本文出力

				output+= arr[j];	// string++

				if(y.Text == arr[j]){	// title line

					output+= " ";	// space
					output+= bmk;
				}

				if( j != (arr.Length- 1) ){	// max count

					output+= "\r\n";
				}
			} //

			// 空行分の出力
			if(y.Nodes.Count > 0){	// 子階層チェック

				output+= "\t";	// tab

				if(y.IsExpanded == true){	// node展開時

					output+= " ";	// space
				}

				output+= "\r\n";
				//					// ここで、飲み込む。

				output+= DocNode(y );	// 再帰

				//					// 段数分、ここから下へ吐き出す。

				output+= " ";	// space

			}else{			// 兄弟node

				output+= " ";	// space
			}

			if(focus == y){		// フォーカスあらばadd

				output+= "\t";	// tab
			}

			if( i < (x.Nodes.Count- 1) ){	// max count

				output+= "\r\n";
			}
		} // 

		return output;

	} // method

	static public string DocNode( TreeView x )	// treeview -> treenode overload
	{
		// Console.WriteLine(x.GetType());	// 変数型チェック

		TreeNode y;

		string output= "";

		// Console.WriteLine(x.Nodes.Count);
		for( int i= 0; i < x.Nodes.Count; i++){

		 	y= x.Nodes[i];

			string bmk= "";

			if(bookmark == y ){
				bmk= "\t";	// tab
			}

			// write-host("fullpath: "+ $y.FullPath)
			string[] arr= y.Name.Split(new string[] { "\r\n" },  StringSplitOptions.None);

			for(int j= 0; j < arr.Length; j++){	// y.Name
			// 本文出力

				output+= arr[j];	// string++

				if(y.Text == arr[j]){	// title line

					output+= " ";	// space
					output+= bmk;
				}

				if( j != (arr.Length- 1) ){	// max count
					output+= "\r\n";
				}
			} //

			// 空行分の出力
			if(y.Nodes.Count > 0){	// 子階層チェック

				output+= "\t";	// tab

				if(y.IsExpanded == true){	// node展開時

					output+= " ";	// space
				}

				output+= "\r\n";
				//					// ここで、飲み込む。

				output+= DocNode(y );	// 再帰

				//					// 段数分、ここから下へ吐き出す。

				output+= " ";	// space


			}else{			// 兄弟node後、再ループで子階層チェックへ

				output+= " ";	// space
			}

			if(focus == y){		// フォーカスあらばadd

				output+= "\t";	// tab
			}

			if( i < (x.Nodes.Count- 1) ){	// max count
			output+= "\r\n";
			}
		} // 

		return output;

	} // method

	static string[] Match_string(MatchCollection mc)
	{
		string[] ss= new string[0];

		foreach(Match t in  mc){
			Array.Resize(ref ss, ss.Length+ 1 );
			ss[ss.Length- 1]= t.Value;
		} //
		return ss;
	} // method
	
	static public void TreeBuild(Main_form parent, string readtext )
	{
 
		TreeView tree= parent.tools.treeview;		// 参照

		// example (?<=^@OP)[0-9]+(?=\s*=)

 		MatchCollection mca= Regex.Matches(readtext , "(?<=\r\n)(\t| )+?($|(?=\r\n))");
		// (先読み 改行) タブorスペースが一つ以上最短一致 行末or(後読み 改行)
		// 空行、ヒットを配列へ //

		// Console.WriteLine("mca: "+ mca.Count);
		string[] textline= Match_string(mca );


		MatchCollection mcb= Regex.Matches(readtext , "(^|(?<=\r\n(\t| )+?\r\n))(.|\r\n)+?(?=\r\n(\t| )+?(\r\n)?)" );
		// 先頭or(先読み空行分) 任意or`r`nが一つ以上最短一致 (後読み空行分 - 改行あるなし)
		// 本文、ヒットを配列へ //

		// Console.WriteLine("mcb: "+ mcb.Count);
		string[] textdoc= Match_string(mcb );


		for(int i= 0; i < textdoc.Length; i++){
			textdoc[i]+= "\r\n";	// 後段のため最終行へ改行付与
		} //

		int j= 0;

		tree.Nodes.Add("Parent Untitled");
		// tree.Nodes.Insert(0, "Parent Untitled");	// エラーとなる

		TreeNode y= tree.Nodes[0];	// node 単体

		// tree.Nodes[0].Text= "Bottom Untitled";	// .Text - title

		y.Tag=  j;
		focus= y;		// 初期のフォーカス設定

		// y.Nodes.AddRange(new TreeNode[] {y, y} );

		object[] arr= new object[2] { tree, y };	// 配列初期化
		// arr_node	tree		child		2nd child	3rd child
		//					brother		brother		brother


		for(int i= 0; i < textline.Length; i++){

			// 本文入力 //

			// タイトル
			Match m= Regex.Match( textdoc[i] , "(^|(?<=\r\n)).*(?= \t?($|\r\n))");
			// 先読み(先頭or改行で始まり)　タイトル読込み　後読み(スペースタブあるなし 行末or改行)
			// 行末は一行文対応ため

			y.Text= (string) m.Value; 

			if(Regex.IsMatch(textdoc[i], "\t\r\n") == true){  // 行末にtabがある

				bookmark= y;
				// Console.WriteLine("bookmark set : "+ bookmark);
			}

			y.Name= Regex.Replace(textdoc[i], " \t?\r\n", "\r\n");
			// スペースタブ行のゴミカット、`s`t?`r`n -> `r`n


			//以降空行処理 //
			if(Regex.IsMatch( textline[i], "^\t ?$") == true){  // `t`s? - tabで始まりspaceあるなし
			// 子ノードへ+ 開状況チェック


				y.Nodes.Add("Child Untitled");		// 1階層下へ


				if( textline[i].Contains(" ") == true){		// `s 開状況

					y.Expand();	// Add後
				}

				y= y.Nodes[0];
				j= 0;
				y.Tag= j;

				Array.Resize(ref arr, arr.Length+ 1 );
				arr[arr.Length- 1]= y;

				// arr+= y		// 下位階層store
				// Console.WriteLine("child arr: "+ arr)


			}else if(Regex.IsMatch(textline[i], "^ ( |\t)*$") ){  // まずspace、(space | tab)がある
			// フォーカスタブあり、兄弟と回帰ノード、開状況のチェックは必要ない

				string ss= "";	// ここで初期化

				if(Regex.IsMatch(textline[i], "\t") == true){
				
					int nn= textline[i].IndexOf("\t");	// タブまでの個数計算

					string dd= textline[i].Substring(0, nn);
					int dt_len= dd.Length;		// スペース分、階層下へ

					dt_len= arr.Length- dt_len;

					y= (TreeNode) arr[dt_len];

					focus= y;	// フォーカス設定
					// Console.WriteLine("Tree-Build focus: "+ focus );

					ss= textline[i].Replace("\t", "");	// タブカット

				}else{
					ss= textline[i];	// space only
				}

				if (i < textline.Length- 1 ){	// 最終行以外

					int len= ss.Length;		// スペース分、同階層下へ
					len= arr.Length- len;
					// Console.WriteLine("Tree-Build Len: "+ len);

					y= (TreeNode) arr[len];

					j= (int) y.Tag;		// 添字を取得

					if(len > 1){	// $script:focus.Parent -eq $nullのため

						y= (TreeNode) arr[len- 1];		// parent
						y.Nodes.Add("Next Untitled");

						j++;
						y= y.Nodes[j];

					}else{
						tree.Nodes.Add("Next Untitled");

						j++;
						y= tree.Nodes[j];
					}

					y.Tag=  j;

					Array.Resize(ref arr, len+ 1 );	// tree分+1
					arr[arr.Length- 1]= y;	// 配列カットのち、代入
					// Console.WriteLine("parent arr: "+ arr)
				}
	
			}else{
				Console.WriteLine("TreeBuild: 何らかのエラー");
				break;
			}
		} //
	}	// method
}
