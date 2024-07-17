using System; 
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Text;	// Encoding.GetEncoding を使用するのに必要


class Main_form : Form
{
	public GUI_tools tools;	// フィールド内記述は、外部へのフックため

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

			tools= new GUI_tools(this );


			string file_doc= File.ReadAllText(@".\TEST.txt", Encoding.UTF8);
			// TreeBuild (cat '.\TEST.txt' | Out-String)

			Tree_Build.TreeBuild(this, file_doc );

			tools.treeview.SelectedNode= Tree_Build.focus;
			tools.bookmarkbox.Text= Tree_Build.bookmark.Text;

			Console.WriteLine("---- main-form start ! ");

			{	// Form
				Text= "Test Form";
				Size= new Size(646, 736);
				Font= new Font("Segoe UI", 11);
				AllowDrop= true;
			}

			// this.Controls.AddRange(new Control[] {  } );


			this.MouseDown+= (sender, e)=>
			{
			};

			this.DragEnter+= (sender, e)=>
			{
				e.Effect= DragDropEffects.All;
			};

			this.DragDrop+= (sender, e)=>
			{
				string[] file_name= (string[]) e.Data.GetData(DataFormats.FileDrop);
				tools.treeview.Nodes.Clear();	// TreeNodeCollection クラス

				string file_txt= File.ReadAllText(file_name[0], Encoding.UTF8);

				Tree_Build.TreeBuild (this,file_txt );
				tools.treeview.SelectedNode= Tree_Build.focus;
			};


		}catch (Exception ex){

			Console.WriteLine("ERR: main-window-constructor >");
			Console.WriteLine(ex);
		}finally{
			// this.Dispose();
		}
	}
}	//class
