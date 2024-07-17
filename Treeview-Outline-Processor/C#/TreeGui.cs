using System; 
using System.Drawing;
using System.Windows.Forms;
using System.IO;	// StreamWriter
using System.Text;	// Encoding

class GUI_tools
{
	// インスタンスの場合は規模が大きい時
	public TreeView treeview;
	public TextBox editbox;
	TextBox focusbox;
	public TextBox bookmarkbox;
	TextBox counterbox;

	Label edit_lbl;
	Label focus_lbl;
	Label bookmark_lbl;
	Label counter_lbl;

	Button btn0;
	Button btn1;
	Button btn2;

	ContextMenuStrip contxt;

	ToolStripMenuItem contxt_jumpbmk;
	ToolStripMenuItem contxt_setbmk;
	ToolStripMenuItem contxt_cut;
	ToolStripMenuItem contxt_copy;
	ToolStripMenuItem contxt_paste;
	ToolStripMenuItem contxt_add;
	ToolStripMenuItem contxt_addchild;

	public GUI_tools(Main_form parent )
	{ 
		treeview= new TreeView()
		{
			Size=  new Size(200, 500),
			Location=  new Point(10, 10),
			HideSelection= false,
		};

		treeview.AfterSelect+= (sender, e)=>
		{
			Tree_Build.focus= e.Node;
			editbox.Text= (string) e.Node.Name;

			counterbox.Text= e.Node.Tag.ToString();	// int -> (string)キャストだとエラー
			focusbox.Text= Tree_Build.focus.Text;
		};

		treeview.MouseDown+= (sender, e)=>
 		{
			try{
				switch(e.Button){
				case MouseButtons.Left :	
					break;
				case MouseButtons.Right :
					contxt.Show(Cursor.Position);
					break;
				case MouseButtons.Middle :
					break;
				} // sw

			}catch (Exception ex){

				Console.WriteLine("ERR: treeview.MouseDown >");
				Console.WriteLine(ex);
 			}
 		};

		edit_lbl= new Label()
		{
			Text= "editbox",
			Size=  new Size(120,20),
			Location= new Point(220,10),
			TextAlign= ContentAlignment.MiddleCenter,
			BorderStyle= BorderStyle.Fixed3D,
			// ForeColor= Color.Black,
			// BackColor= Color.DodgerBlue,
		};

		editbox= new TextBox()
		{
			Size=  new Size(400, 200),
			Location=  new Point(220, 30),
			Multiline = true,
			AcceptsReturn= true,
		};

		editbox.Leave+= (sender, e)=>
		{
			Tree_Build.focus.Name= editbox.Text;

			string[] doc= editbox.Text.Split(new string[] { "\r\n" },  StringSplitOptions.None);

			Tree_Build.focus.Text= doc[0];	// 行頭
		};

		focus_lbl= new Label()
		{
			Text= "focusbox",
			Size=  new Size(120,20),
			Location= new Point(220,230),
			TextAlign= ContentAlignment.MiddleCenter,
			BorderStyle= BorderStyle.Fixed3D,
		};

		focusbox= new TextBox()
		{
			Size=  new Size(400, 100),
			Location=  new Point(220, 250),
			Multiline = true,
		};

		bookmark_lbl= new Label()
		{
			Text= "bookmarkbox",
			Size=  new Size(120,20),
			Location= new Point(220,350),
			TextAlign= ContentAlignment.MiddleCenter,
			BorderStyle= BorderStyle.Fixed3D,
		};

		bookmarkbox= new TextBox()
		{
			Size=  new Size(400, 100),
			Location=  new Point(220, 370),
			Multiline = true,
		};

		counter_lbl= new Label()
		{
			Text= "counterbox - read only",
			Size=  new Size(180,20),
			Location= new Point(220,470),
			TextAlign= ContentAlignment.MiddleCenter,
			BorderStyle= BorderStyle.Fixed3D,
		};

		counterbox= new TextBox()
		{
			Size=  new Size(400, 100),
			Location=  new Point(220, 490),
			Multiline = true,
		};

		btn0= new Button()
		{
			Size=  new Size(100, 100),
			Location=  new Point(220, 590),
			FlatStyle= FlatStyle.Popup,
			Text= "down search",
		};

		btn0.Click+= (sender, e)=>
		{
			if(editbox.SelectedText != ""){

				Search_Build.Down_search(parent );
			}
		};

		btn1= new Button()
		{
			Size=  new Size(100, 100),
			Location=  new Point(320, 590),
			FlatStyle= FlatStyle.Popup,
			Text= "upper search",
		};

		btn1.Click+= (sender, e)=>
		{
			if(editbox.SelectedText != ""){

				Search_Build.Upper_search(parent );
			}
		};

		btn2= new Button()
		{
			Size=  new Size(100, 100),
			Location=  new Point(420, 590),
			FlatStyle= FlatStyle.Popup,
			Text= "file output",
		};

		btn2.Click+= (sender, e)=>
		{
			string st= Tree_Build.DocNode(treeview );
			// Console.WriteLine("====");
			// Console.WriteLine("file output: "+ st);
			// Console.WriteLine("====");

			// $rtn | Out-File -Encoding UTF8 -FilePath ".\TEST-01.txt" # UTF8
			StreamWriter wr = new StreamWriter(@".\test-1.txt", false, Encoding.UTF8);

			wr.WriteLine(st);	// Out-File同様終端改行が付加
			wr.Close();	// file close
		};

		parent.Controls.AddRange(new Control[] { treeview, edit_lbl, editbox, focus_lbl,focusbox, bookmark_lbl,bookmarkbox, counter_lbl, counterbox } );
		parent.Controls.AddRange(new Control[] { btn0, btn1, btn2 } );	// 最後にtopを読む

		contxt= new ContextMenuStrip();

		contxt_jumpbmk= new ToolStripMenuItem()
		{
			Text= "Bookmark Jump",
		};

		contxt_jumpbmk.Click+= (sender, e)=>
		{
			treeview.SelectedNode= Tree_Build.bookmark;
		};

		contxt_setbmk= new ToolStripMenuItem()
		{
			Text= "Bookmark Set",
		};

		contxt_setbmk.Click+= (sender, e)=>
		{
			Tree_Build.bookmark= Tree_Build.focus;
 			parent.tools.bookmarkbox.Text= Tree_Build.bookmark.Text;
		};

		contxt_cut= new ToolStripMenuItem()
		{
			Text= "Cut",
		};

		contxt_cut.Click+= (sender, e)=>
		{
			Clipboard.SetText("tree.nodes.data.flag.clipboard", TextDataFormat.UnicodeText );
			Tree_Build.node_clip= Tree_Build.focus;
			Tree_Build.focus.Nodes.Remove(Tree_Build.focus);
		};

		contxt_copy= new ToolStripMenuItem()
		{
			Text= "Copy",
		};

		contxt_copy.Click+= (sender, e)=>
		{
			Clipboard.SetText("tree.nodes.data.flag.clipboard", TextDataFormat.UnicodeText );
			Tree_Build.node_clip= Tree_Build.focus;
 		};

		contxt_paste= new ToolStripMenuItem()
		{
			Text= "Paste",
		};

		contxt_paste.Click+= (sender, e)=>
		{
			string clip= Clipboard.GetText( TextDataFormat.UnicodeText );

			if( clip == "tree.nodes.data.flag.clipboard" ){
				NodePaste();
			}else{
				PlainPaste();
			}
		};

		contxt_add= new ToolStripMenuItem()
		{
			Text= "Add Paste",
		};

		contxt_add.Click+= (sender, e)=>
		{
			string clip= Clipboard.GetText( TextDataFormat.UnicodeText );

			if( clip == "tree.nodes.data.flag.clipboard" ){
				NodePaste("add");
			}else{
				PlainPaste("add");
			}
		};

		contxt_addchild= new ToolStripMenuItem()
		{
			Text= "Child Paste",
		};

		contxt_addchild.Click+= (sender, e)=>
		{
			string clip= Clipboard.GetText( TextDataFormat.UnicodeText );

			if( clip == "tree.nodes.data.flag.clipboard" ){
				ChildPaste("node");
			}else{
				ChildPaste();
			}
		};

		// contxt.Items.Add(contxt_jumpbmk);
		contxt.Items.AddRange(new ToolStripItem[] { contxt_cut, contxt_copy, contxt_paste, contxt_add, contxt_addchild } );
		contxt.Items.Insert(0, contxt_setbmk);
		contxt.Items.Insert(0, contxt_jumpbmk);
	}

	void ChildPaste(string sw= ""){		// 初期値ありで省略可能

		TreeView tree= treeview;	// 参照

		TreeNode y= Tree_Build.focus;

		if(sw == "node"){

			// y.Nodes.AddRange(Tree_Build.node_clip.Clone() );	//  これでも良い
			y.Nodes.Insert( 0, (TreeNode) Tree_Build.node_clip.Clone() );	// node list object first child paste

		}else{

			//y.Nodes.Add("Untitled");		// これでも良い
			 y.Nodes.Insert(0, "Untitled");	// node list object first child paste


			bool nn= Clipboard.ContainsText();	// text document チェック

			if(nn){
				string cc= Clipboard.GetText( TextDataFormat.UnicodeText );
				string[] doc= cc.Split(new string[] { "\r\n" },  StringSplitOptions.None);

				y.Nodes[0].Text= doc[0];	// 行頭
				y.Nodes[0].Name=  cc;		// clipboard
			}
		}

		y.Expand();	// 開状況

		Tree_Build.focus= y.Nodes[0];	// refocus
		tree.SelectedNode= Tree_Build.focus;

	} // method

	void PlainPaste(string sw= ""){		// 初期値ありで省略可能

		TreeView tree= treeview;	// 参照


		TreeNodeCollection y;	// node 配列


		if(Tree_Build.focus.Level > 0){

			y= Tree_Build.focus.Parent.Nodes;
		}else{
			y= tree.Nodes;
		}

		int[] dd= new int[2];

		if(sw == "add"){
			dd[0]= 1;
			dd[1]= 1;
		}else{
			dd[0]= 0;
			dd[1]= -1;
		}

		y.Insert(( y.IndexOf(Tree_Build.focus)+ dd[0]), "Untitled");
		TreeNode obj= y[ y.IndexOf(Tree_Build.focus)+ dd[1] ];

		bool nn= Clipboard.ContainsText();	// text document チェック

		if(nn){

			string cc= (string) Clipboard.GetText( TextDataFormat.UnicodeText );
			string[] doc= cc.Split(new string[] { "\r\n" },  StringSplitOptions.None);

			obj.Text= doc[0];	// 行頭
			obj.Name=  cc;		// clipboard
		}

		tree.SelectedNode= obj;		// refocus

	}	// method

	void NodePaste(string sw= ""){		// 省略可能な引数は初期値付ける

		TreeView tree= treeview;	// 参照

		TreeNodeCollection y;	// node 配列
		int nn= 0;

		if(Tree_Build.focus.Level > 0){	// $script:focus.Parent -eq $nullのため

			y= Tree_Build.focus.Parent.Nodes;	// forcusノードの下へadd
		}else{
			y= tree.Nodes;
		}

		nn= y.IndexOf(Tree_Build.focus);		// node 配列から index 出す


		if(sw == "add"){	// +1
			nn= nn+ 1;	// 下ノード # Insert node
		}else{
						// 兄弟ノード # .Insert node
		}

		y.Insert( nn, (TreeNode) Tree_Build.node_clip.Clone() );

		TreeNode z= y[nn];

		Tree_Build.focus= z;	// reforcus
		tree.SelectedNode=  Tree_Build.focus;

	} // method
}
