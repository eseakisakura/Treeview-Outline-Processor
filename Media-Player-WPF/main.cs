using System; 
using System.IO;
using System.Windows;

public class Programs
{
	[STAThread]
	public static void Main(string[] args )	// Entry point
	{
	try{
		Main_app app = new Main_app(args );

		// InitializeComponent();	// sampleForm.Designer.cs�ł�method
		// app.StartupUri = new Uri(".\\main-window.xaml", UriKind.Relative);


		Setpath_current();
		Console.WriteLine("Hello World!"+ "\r\n");

		// Application.EnableVisualStyles();	// �r�W���A���X�^�C���L���� form

		// ���b�Z�[�W�E���[�v�i���b�Z�[�W�E �|���v�j����
		// app.window.ShowDialog();
		app.Run(app.window );

	}catch (Exception ex){

		Console.WriteLine("ERR: main-method >");
		Console.WriteLine(ex);
	}finally{
		// app.Dispose();
		Console.ReadKey();
	}
	}

	static void Setpath_current()
	{
		string dir_path= System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);	// exe�J�����g�擾

		System.IO.Directory.SetCurrentDirectory(dir_path);	// <- args�J�����g��ύX

		Console.WriteLine(System.IO.Directory.GetCurrentDirectory());
	}
}
