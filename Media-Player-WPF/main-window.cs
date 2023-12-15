using System; 
using System.IO;	// FileStream
using System.Windows;
using System.Windows.Markup;	// XamlReader
// using System.Windows.Controls;


class Main_app : Application
{
	public Window window;
	Button_class button_inst;
	Menu_class menu_inst;
	Player_class player_inst;

	public Main_app(string[] args_path )
	{
	try{
		// ファイルはGCの管理対象外ため -> using (try catch finally)
		using (var fs= new FileStream(".\\main-window.xaml", FileMode.Open, FileAccess.Read ) )
		{
			window= (Window)XamlReader.Load(fs );
		}

		window.MouseDown+= (sender, e)=>
		{
			Console.WriteLine("click! window test");
			Console.WriteLine(window.Content);	//コンテントproperty
		};

		button_inst= new Button_class(this );
		menu_inst= new Menu_class(this );

		string location= args_path[0];
		player_inst= new Player_class(this, location );

	}catch (Exception ex){

		Console.WriteLine("ERR: main-window-constructor >");
		Console.WriteLine(ex);
	}finally{
		// window.Dispose();
	}
	}
}
