using System; 
using System.Windows;
using System.Windows.Media;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Threading;	// DragStartedEvent
using System.Diagnostics;			// Stopwatch

class Player_class
{
	double time_set= 500;		// 通常インターバルmsec
	double time_set2= 12.0;	// 加速時のインターバルmsec
	double time_set3= 33.3;	// ブランクタイムmsec

	double duration= 6.0;	// 加速時のスキップsec

	Stopwatch swh= new Stopwatch();

	public DispatcherTimer tim = new DispatcherTimer()	// WPF timer
	{
		// Interval = TimeSpan.FromMilliseconds(500 ),
	};

	public DispatcherTimer tim2 = new DispatcherTimer()	// 加速装置
	{
		// Interval = TimeSpan.FromMilliseconds(50 ),
	};

	public DispatcherTimer tim3 = new DispatcherTimer()	// msec.再生時間
	{
		// Interval = TimeSpan.FromMilliseconds(5 ),
	};


	bool reverse= false;

	TimeSpan post_position;
	Slider ok_slider;
	Label ok_label;

	public MediaElement ok_player;

	public Player_class(Main_app parent, string location)	// ポンプ
	{

		tim.Interval = TimeSpan.FromMilliseconds(time_set );	// feild変数はここで読込み
		tim2.Interval = TimeSpan.FromMilliseconds(time_set2 );
		tim3.Interval = TimeSpan.FromMilliseconds(time_set3 );

		// ok_label= (Label) parent.window.FindName("ok_label");
		ok_label= new Label()
		{
			Content= "chk----chk",
		};

		parent.panel_inst.panel2.Children.Add(ok_label );
		Console.WriteLine(ok_label.Content );

		// ok_player= (MediaElement) parent.window.FindName("ok_player");
		ok_player= new MediaElement()	// XHTMLはelementで良し
		{
			LoadedBehavior= MediaState.Manual,
			UnloadedBehavior=MediaState.Stop,
			Stretch= Stretch.Uniform,
		};

		// player.Open(new Uri(location ) );
		ok_player.Source= new Uri(location, UriKind.Relative );
		Console.WriteLine(ok_player.Source );

		parent.panel_inst.panel2.Children.Add(ok_player );


		// ok_slider= (Slider) parent.window.FindName("ok_slider");
		ok_slider= new Slider()		// スライダー生成
		{
			Margin= new Thickness(20,20,20,20),
			// Height= 50,
			// Width= 500,
			// HorizontalAlignment= HorizontalAlignment.Stretch,
			IsMoveToPointEnabled= true,
			AutoToolTipPlacement= AutoToolTipPlacement.BottomRight,
		};
		// parent.panel_inst.panel3.Children.Add(ok_slider );
		// DockPanel.SetDock(ok_slider, Dock.Top);	// これで良いらしい

		parent.grid_inst.grid.Children.Add(ok_slider );
		Grid.SetColumn(ok_slider, 0);	// Grid.SetColumnこれで良いらしい

		Console.WriteLine("MaxWidth: "+ ok_slider.MaxWidth );




		string ret= Get_file.File_property(location );		// get_file.cs 
		Console.WriteLine(ret );

		TimeSpan dt= TimeSpan.Parse(ret );	// スライダー長
		int value= Convert.ToInt32(100* Math.Round (dt.TotalSeconds, 2, MidpointRounding.AwayFromZero ) );
		ok_slider.Maximum= value;

		ok_player.Play();
		tim.Start();

		tim3.Tick+= (sender, e)=>	// ブランクタイム
		{
			if(swh.ElapsedMilliseconds >= time_set3){
					tim3.Stop();
					tim2.Start();
					swh.Reset();
			}
		};
		
		tim2.Tick+= (sender, e)=>
		{
			if(reverse == true){

				slider_Postion();	// before just
				ok_player.Position+= TimeSpan.FromSeconds(- duration );	// skip time

				if(ok_player.Position <= post_position ){	// 到着
					tim2.Stop();
					tim.Start();
				}else{
					swh.Start();
					tim2.Stop();
					tim3.Start();
				}

			}else{
				ok_player.Position+= TimeSpan.FromSeconds(duration );
				slider_Postion();	// after just

				if(ok_player.Position >= post_position ){	// 到着

					tim2.Stop();
					tim.Start();
				}else{
					swh.Start();
					tim2.Stop();
					tim3.Start();
				}
			}
		};

		tim.Tick+= (sender, e)=>
		{
			slider_Postion();

			if(ok_slider.Value == ok_slider.Maximum ){

				ok_player.Stop();
				tim.Stop();
			}
		};

		ok_slider.AddHandler(	// Thumb event
			Thumb.DragStartedEvent,
			new DragStartedEventHandler(slider_MouseDrag)
		);
		ok_slider.AddHandler(
			Thumb.DragDeltaEvent,
			new DragDeltaEventHandler(slider_MouseDelta)
		);
		ok_slider.AddHandler(
			Thumb.DragCompletedEvent,
			new DragCompletedEventHandler(slider_MouseDrop)
		);

		// AddHandler(RoutedEvent, Delegate, Boolean)	// method -> event set
		ok_slider.AddHandler(
			Slider.PreviewMouseDownEvent,	// MouseDownの前で処理する
			new RoutedEventHandler(slider_MouseDown),
			true
			// 他によりハンドル済みとしてマークされていても、そのイベントを受け取りたい場合
		);

/*		ok_slider.PreviewMouseDown+= (sender, e)=>
		{
			Console.WriteLine("m---down "+ e );
			// e.IsHandled= true;	// 認識できない -> xaml側?
			Console.WriteLine("m---down" );
		};
*/
	}


	void slider_MouseDrag(object sender, DragStartedEventArgs e)
	{
		tim.Stop();
	}
	void slider_MouseDelta(object sender, DragDeltaEventArgs e)
	{
		Console.WriteLine("m-Delta" );
		ok_player.Position= player_Postion();
	}
	void slider_MouseDrop(object sender, DragCompletedEventArgs e)
	{
		Console.WriteLine("m-Drag" );
		ok_player.Position= player_Postion();

		tim.Start();
	}


	void slider_MouseDown(object sender, RoutedEventArgs e)
	{
		post_position= player_Postion();
		Console.WriteLine(post_position );

		TimeSpan min= post_position- ok_player.Position;

		if(TimeSpan.FromSeconds(-5 ) < min & min < TimeSpan.FromSeconds(5 )){

			ok_player.Position= player_Postion();
			// 5sec.以内は瞬間移動のみ

		}else{
			if(ok_player.Position > post_position ){
				reverse= true;
			}else{
				reverse= false;
			}
			tim.Stop();
			tim2.Start();
		}
	}

	TimeSpan player_Postion()
	{
		double bb= ok_slider.Value/ 100;
		Console.WriteLine(bb );

		TimeSpan ts= TimeSpan.FromSeconds(bb );	// 構造体

		return ts;
		// ok_player.Position= ts;
		// post_position= player_Postion();
	}

	void slider_Postion()
	{
		TimeSpan ts= ok_player.Position;
		ok_label.Content= ts.ToString("hh\\ \\:\\ mm\\ \\:\\ ss");

		Console.WriteLine(100* Math.Round (ts.TotalSeconds, 2, MidpointRounding.AwayFromZero ) );
		ok_slider.Value=  Convert.ToInt32(100* Math.Round (ts.TotalSeconds, 2, MidpointRounding.AwayFromZero ) );
	}
 }
