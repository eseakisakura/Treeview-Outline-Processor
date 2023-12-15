using System;
using System.Windows;
using System.Windows.Controls;

class Menu_class
{
	MenuItem ok_menu;

	public Menu_class(Main_app parent )
	{
		// イベントハンドラ - コードビハインド
		ok_menu= (MenuItem) parent.window.FindName("ok_menu");
/*		// 丁寧な書き方 - コンストラクタの外にメソッド記述
		okButton.AddHandler(
			Button.ClickEvent,
			new RoutedEventHandler(okButton_Click)
		);
*/
		// 変数指定があるパターン
		// okButton.Click+= (object sender, RoutedEventArgs e)=>
		ok_menu.Click+= (sender, e)=>
		{
			Console.WriteLine("click! menu test");
			Console.WriteLine(ok_menu.Header);
			// MessageBox.Show("Hello, Button!");
		};
	}

/*	public static void okButton_Click(object sender, RoutedEventArgs e)
	{
		Console.WriteLine("click! button test");
		// MessageBox.Show("Hello, Button!");
	}
*/
}
