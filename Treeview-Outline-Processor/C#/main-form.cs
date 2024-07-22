using System; 
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Text;	// Encoding.GetEncoding を使用するのに必要


class Main_form : Form
{
	public GUI_tools tools;	// フィールド内記述は、外部へのフックため

	public Main_form()	// constructor 返値はない
	{
		try{
			string[] args= Environment.GetCommandLineArgs();	// コマンドライン引数

			string dir_path= Path.GetDirectoryName(args[0]);

			Directory.SetCurrentDirectory(dir_path);	// <- argsカレントを変更
			Console.WriteLine("CurrentDirectory: "+ Directory.GetCurrentDirectory());


			string location= "";

			if(args.Length > 1){	// D&D起動のため

				location= args[1];	// args[0]= exe自体
				Console.WriteLine("D&D location: "+ location);
			}

			tools= new GUI_tools(this );

			Console.WriteLine("---- main-form start ! ");

			{	// Form
				Text= "Test Form";
				Size= new Size(646, 736);
				Font= new Font("Segoe UI", 11);
				AllowDrop= true;
			}

			// this.Controls.AddRange(new Control[] {  } );

		}catch (Exception ex){

			Console.WriteLine("ERR: main-window-constructor >");
			Console.WriteLine(ex);
		}finally{
			// this.Dispose();
		}


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
	}	// constructor
}	//class
