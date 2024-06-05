using System;
using System.Windows;
using System.Windows.Controls;

class Button_class
{
	Button ok_button;

	public Button_class(Main_app parent )
	{
		// イベントハンドラ - コードビハインド
		// ok_button= (Button) parent.window.FindName("ok_button");
		ok_button= new Button()
		{
			Width= 100,
			Height= 100,
			// UseLayoutRounding= true,
		};

		parent.panel_inst.panel2.Children.Add(ok_button );

/*		// 丁寧な書き方 - コンストラクタの外にメソッド記述
		ok_button.AddHandler(
			Button.ClickEvent,
			new RoutedEventHandler(ok_button_Click)
		);
*/
		// 変数指定があるパターン
		// okButton.Click+= (object sender, RoutedEventArgs e)=>
		ok_button.Click+= (sender, e)=>
		{
			Console.WriteLine("click! button test");
			ok_button.Content= "-----chk-chk";
			Console.WriteLine(ok_button.Content);	//コンテントproperty
			// MessageBox.Show("Hello, Button!");
		};
	}

/*	public static void ok_button_Click(object sender, RoutedEventArgs e)
	{
		Console.WriteLine("click! button test");
		// MessageBox.Show("Hello, Button!");
	}
*/
}
