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
}	//class
