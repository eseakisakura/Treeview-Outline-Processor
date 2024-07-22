using System; 
using System.Windows.Forms;


static class Program
{
	[STAThread]
	static void Main()
	{
	try{
		Console.WriteLine("Hello World!"+ "\r\n");

		Application.EnableVisualStyles();	// ビジュアルスタイル有効化
		Application.Run(new Main_form());


	}catch (Exception ex){

		Console.WriteLine("ERR: main");
		Console.WriteLine(ex);
	}finally{
		// main_form.Dispose();
		// Console.ReadKey();
	}
	}
}
