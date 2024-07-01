using System; 
using System.Windows.Forms;


static class Program
{
	[STAThread]
	static void Main(string[] args)
	{
	try{
		Setpath_current();

		Console.WriteLine("Hello World!"+ "\r\n");

		Application.EnableVisualStyles();	// ビジュアルスタイル有効化
		Application.Run(new Main_form(args));


	}catch (Exception ex){

		Console.WriteLine("ERR: main");
		Console.WriteLine(ex);
	}finally{
		// main_form.Dispose();
		// Console.ReadKey();
	}
	}

	static void Setpath_current()
	{

		string dir_path= System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);	// exeカレント取得
		
		System.IO.Directory.SetCurrentDirectory(dir_path);	// <- argsカレントを変更

		Console.WriteLine(System.IO.Directory.GetCurrentDirectory());
	}
}
