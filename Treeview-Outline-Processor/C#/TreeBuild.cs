using System; 
using System.Windows.Forms;
using System.Text.RegularExpressions;


class Tree_Build	// static
{
	static public TreeNode focus;		// ストアフォーカス
	static public TreeNode bookmark;	// インスタンス共有となるため、クラス名でアクセス


	static string[] Match_string(MatchCollection mc)
	{
		string[] ss= new string[0];

		foreach(Match t in  mc){
			Array.Resize(ref ss, ss.Length+ 1 );
			ss[ss.Length- 1]= t.Value;
		} //
		return ss;
	}
	
	static public void TreeBuild(Main_form parent, string readtext )
	{
 
		TreeView tree= parent.treeview;		// 参照

		// example (?<=^@OP)[0-9]+(?=\s*=)

 		MatchCollection mca= Regex.Matches(readtext , "(?<=\r\n)(\t| )+?(?=\r\n)");
		// タブorスペースが一つ以上最短一致
		// 空行、ヒットを配列へ

		// Console.WriteLine("mca: "+ mca.Count);
		string[] textline= Match_string(mca );


		MatchCollection mcb= Regex.Matches(readtext , "(^|(?<=\r\n(\t| )+?\r\n))(.|\r\n)*?(?=\r\n(\t| )+?\r\n)" );
		// 先頭or先読み空行　.or`r`n 最短一致　後読み空行
		// 本文、ヒットを配列へ

		// Console.WriteLine("mcb: "+ mcb.Count);
		string[] textdoc= Match_string(mcb );


		for(int i= 0; i < textdoc.Length; i++){
			textdoc[i]+= "\r\n";	// 後段のため最終行へ改行付与
		} //

		int j= 0;

		tree.Nodes.Add("Parent Untitled");

		TreeNode y= tree.Nodes[0];

		tree.Nodes[0].Text= "ボトムノード";	// .Text - title

		y.Tag= j;
		focus= y;		// 初期のフォーカス設定

		// y.Nodes.AddRange(new TreeNode[] {y, y} );

		object[] arr_node= new object[2] { tree, y };	// 配列初期化
		// arr_node	tree		child	2nd child	3rd child
		//					brother	brother		brother


		for(int i= 0; i < textline.Length; i++){

			// 本文入力 //

			// タイトル
			Match m= Regex.Match( textdoc[i] , "(^|(?<=\r\n)).*(?= \t?($|\r\n))");
			y.Text= (string) m.Value; 
			// 先頭or先読み改行で始まり　タイトル　行末or後読みスペースタブあるなし改行、最初のみヒット
			// 行末は一行文対応ため

			if(Regex.IsMatch(textdoc[i], "\t\r\n") == true){  // 行末にtabがある

				bookmark= y;
				// Console.WriteLine("bookmark set : "+ bookmark);
			}

			y.Name= Regex.Replace(textdoc[i], " \t?\r\n", "\r\n");
			// スペースタブ行のゴミカット、`s`t?`r`n -> `r`n


			//空行処理 //
			if(Regex.IsMatch( textline[i], "^\t ?$") == true){  // `t`s? - tabで始まり、spaceがあるかないか
			// 子ノードへ+ 開状況チェック


				y.Nodes.Add("Child Untitled");		// 1階層下へ


				if( textline[i].Contains(" ") == true){		// `s 開状況

					y.Expand();	// Add後
				}

				y= y.Nodes[0];
				j= 0;
				y.Tag=  j;

				Array.Resize(ref arr_node, arr_node.Length+ 1 );
				arr_node[arr_node.Length- 1]= y;

				// arr+= y		// 下位階層store
				// Console.WriteLine("child arr: "+ arr)


			}else if(Regex.IsMatch(textline[i], "^ ( |\t)*$") ){  // まずspace、(space | tab)がある
			// フォーカスタブあり、兄弟と回帰ノード、開状況のチェックは必要ない

				string ss= "";	// ここで初期化

				if(Regex.IsMatch(textline[i], "\t") == true){
				
					int nn= textline[i].IndexOf("\t");	// タブまでの個数計算

					string dd= textline[i].Substring(0, nn);
					int dt_len= dd.Length;		// スペース分、階層下へ

					dt_len= arr_node.Length- dt_len;

					y= (TreeNode) arr_node[dt_len];

					focus= y;	// フォーカス設定
					// Console.WriteLine("Tree-Build focus: "+ focus );

					ss= textline[i].Replace("\t", "");	// タブカット

				}else{
					ss= textline[i];	// space only
				}

				if (i < textline.Length- 1 ){	// 最終行以外

					int len= ss.Length;		// スペース分、同階層下へ
					len= arr_node.Length- len;
					// Console.WriteLine("Tree-Build Len: "+ len);

					y= (TreeNode) arr_node[len];

					j= (int) y.Tag;		// 添字を取得

					if(len > 1){	// $script:focus.Parent -eq $nullのため

						y= (TreeNode) arr_node[len- 1];		// parent
						y.Nodes.Add("Next Untitled");

						j++;
						y= y.Nodes[j];

					}else{
						tree.Nodes.Add("Next Untitled");

						j++;
						y= tree.Nodes[j];
					}

					y.Tag= j;

					Array.Resize(ref arr_node, len+ 1 );	// tree分+1
					arr_node[arr_node.Length- 1]= y;	// 配列カットのち、代入
					// Console.WriteLine("parent arr: "+ arr_node)
				}
	
			}else{
				Console.WriteLine("TreeBuild: 何らかのエラー");
				break;
			}
		} //
	}	// method
}
