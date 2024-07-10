using System; 
using System.Windows.Forms;


class Search_Build	// static
{
	static public TreeNode search_node;
	static public int search_index= -1;


	static public object[] ForwardFind(Main_form parent, TreeNode x)
	{

		TreeView tree= parent.treeview;
		TreeNode y= x;
		object[] stuck= new object[1] { x };	// 最初にforcusノードから入れる


		int i= 0;
		int sw= 1;
		// for([int] $i= 0; $i -lt 20; $i++){
		while(true){

			if( i > 5000){

				string qq= "検索ノードが、5000を超えました";

				Console.WriteLine(qq);

				DialogResult result=  MessageBox.Show(
					qq, "確認", MessageBoxButtons.OK, MessageBoxIcon.Information,MessageBoxDefaultButton.Button1
				);

				break;	// 強制終了
			}


			if(sw == 1){

				if(y.FirstNode != null){

					y= y.FirstNode;	// 最初の子ツリー ノード
					// Console.WriteLine("FirstNodefullpath: "+y.FullPath);

					if(y == x){ break; }

					Array.Resize(ref stuck, stuck.Length+ 1 );
					stuck[stuck.Length- 1]= y;
					// $stuck+= $y

				}else if(y.NextNode != null){

					y= y.NextNode;	// 兄弟ツリー ノード
					// Console.WriteLine("NextNodefullpath: "+y.FullPath);

					if(y == x){ break; }

					Array.Resize(ref stuck, stuck.Length+ 1 );
					stuck[stuck.Length- 1]= y;
					// $stuck+= $y
				}else{
					sw= 0;
				}

			}else{

				if(y.Parent.NextNode != null){

					y= y.Parent.NextNode;	// 親の兄弟ノード
					// Console.WriteLine("Parent.NextNodefullpath: "+y.FullPath);

					if(y == x){ break; }

					Array.Resize(ref stuck, stuck.Length+ 1 );
					stuck[stuck.Length- 1]= y;
					//$stuck+= $y
					sw= 1;

				}else{
					if(y.Level > 1){	// トップノード以外  <- 0だとエラー

						y= y.Parent;	// いったん親へ戻る
					}else{
						y= tree.TopNode;
						// Console.WriteLine("tree.TopNodefullpath: "+ y.FullPath);

						if(y == x){ break; }

						Array.Resize(ref stuck, stuck.Length+ 1 );
						stuck[stuck.Length- 1]= y;
						//$stuck+= $y
						sw= 1;

					}
				}
			}

			i++;
		} //

		Array.Resize(ref stuck, stuck.Length+ 1 );
		stuck[stuck.Length- 1]= x;	// 最後に回帰ノード検索分
		//$stuck+= $x

		return stuck;

	 } // method


	static public void Down_search(Main_form parent )
	{
 		object[] yrr= Search_Build.ForwardFind(parent, Tree_Build.focus);


		search_node=  Tree_Build.focus;
		search_index= parent.editbox.SelectionStart;

		TreeView tree= parent.treeview;


		string rtn_str= parent.editbox.SelectedText;		// "な"
		int rtn_len= parent.editbox.SelectionLength;		// 1


		int dur= ((int) parent.editbox.SelectionStart)+ 1;
		// Console.WriteLine(parent.editbox.Text.Length);


		for(int i= 0;  i < yrr.Length; i++){

			int index_rtn= 0;
			TreeNode tt= (TreeNode) yrr[i];

			if(i == 0){	// 同一ノード
				index_rtn= tt.Name.IndexOf(rtn_str, dur, StringComparison.OrdinalIgnoreCase);
			}else{
				index_rtn= tt.Name.IndexOf(rtn_str, StringComparison.OrdinalIgnoreCase); // [列挙型] 区別しない
			}

			if(index_rtn == -1){	// node内に検索語がない -> -1

			}else{

				if(yrr[i] == search_node ){
					Console.WriteLine("Restart - node : "+ search_node);
				}

				Tree_Build.focus= (TreeNode) yrr[i];
				tree.SelectedNode= Tree_Build.focus;	// refocus

				parent.editbox.Focus();
				parent.editbox.Select(index_rtn, rtn_len);

				break;	// ここでループブレイク
			}
		} //
	} // method


	static public void Upper_search(Main_form parent )
	{
		object[] yrr= Search_Build.ForwardFind(parent, Tree_Build.focus);

		Array.Reverse(yrr);


		search_node=  Tree_Build.focus;
		search_index= parent.editbox.SelectionStart;

		TreeView tree= parent.treeview;


		string rtn_str= parent.editbox.SelectedText;		// "な"
		int rtn_len= parent.editbox.SelectionLength;		// 1


		int dur= ((int) parent.editbox.SelectionStart)- 1;
		// Console.WriteLine(parent.editbox.Text.Length);

		for(int i= 0;  i < yrr.Length; i++){

			int index_rtn= 0;
			TreeNode tt= (TreeNode) yrr[i];

			if(i == 0){	// 同一ノード

				if(dur >= 0){
					index_rtn= tt.Name.LastIndexOf(rtn_str, dur, StringComparison.OrdinalIgnoreCase);
				}else{
					index_rtn= -1;	// SelectionStart= 0時
				}

			}else{
				index_rtn= tt.Name.LastIndexOf(rtn_str, StringComparison.OrdinalIgnoreCase); // [列挙型] 区別しない
			}

			if(index_rtn == -1){	// node内に検索語がない -> -1

			}else{

				if(yrr[i] == search_node ){
					Console.WriteLine("Restart - node: "+ search_node);
				}

				Tree_Build.focus= (TreeNode) yrr[i];
				tree.SelectedNode= Tree_Build.focus;	// refocus

				parent.editbox.Focus();
				parent.editbox.Select(index_rtn, rtn_len);

				break;	// ここでループブレイク
			}
		} //
	} // method
}
