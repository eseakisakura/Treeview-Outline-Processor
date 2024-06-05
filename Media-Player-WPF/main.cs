using System; 
using System.IO;
using System.Windows;

public class Programs
{
	static Main_app app;

	[STAThread]
	public static void Main(string[] args )	// Entry point
	{
	try{
		app= new Main_app(args );

		// InitializeComponent();	// sampleForm.Designer.csでのmethod
		// app.StartupUri = new Uri(".\\main-window.xaml", UriKind.Relative);


		Setpath_current();
		Console.WriteLine("Hello World!"+ "\r\n");

		// Application.EnableVisualStyles();	// ビジュアルスタイル有効化 form

		// メッセージ・ループ（メッセージ・ ポンプ）処理
		// app.window.ShowDialog();
		app.Run(app.window_form );

	}catch (Exception ex){

		Console.WriteLine("ERR: main-method >");
		Console.WriteLine(ex);
	}finally{
		// app.Dispose();
		Console.ReadKey();
		app.Shutdown();
	}
	}

	static void Setpath_current()
	{
		string dir_path= System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);	// exeカレント取得

		System.IO.Directory.SetCurrentDirectory(dir_path);	// <- argsカレントを変更

		Console.WriteLine(System.IO.Directory.GetCurrentDirectory());
	}
}
