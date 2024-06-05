using System; 
using System.IO;	// FileStream
using System.Windows.Media;
using System.Windows;
using System.Windows.Markup;	// XamlReader
using System.Windows.Controls;


class Main_app : Application
{
	public Window window_form= new Window();

	public StackPanel bg_panel= new StackPanel()		// background panel
	{
		Background= Brushes.Blue,
		// Height= 250,
		Margin= new Thickness(15,15,15,15),
	};

	Menu_class menu_inst;
	public Panel_class panel_inst;
	public Grid_class grid_inst;
	Button_class button_inst;
	Player_class player_inst;


	public Main_app(string[] args_path )
	{
	try{

		menu_inst= new Menu_class(this );
		panel_inst= new Panel_class(this );

		window_form.Content= bg_panel;

		grid_inst= new Grid_class(this );

		button_inst= new Button_class(this );

		string location= args_path[0];
		player_inst= new Player_class(this, location );


		window_form.MouseDown+= (sender, e)=>
		{
			Console.WriteLine("click! window test");
			Console.WriteLine(window_form.Content);	//コンテントproperty
		};

		window_form.Closed+= (sender, e)=>
		{
			// player_inst.ok_player.Stop();
			// player_inst.ok_player.Close();
			// player_inst.tim.Stop();
			// player_inst.tim2.Stop();

			Console.WriteLine("click! window Closed");
		};

	}catch (Exception ex){

		Console.WriteLine("ERR: main-window-constructor >");
		Console.WriteLine(ex);
	}finally{
		// this.Dispose();
	}
	}
}
