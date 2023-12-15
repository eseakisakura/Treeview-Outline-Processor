using System;
using System.Windows;
using System.Windows.Controls;

class Button_class
{
	Button okButton;

	public Button_class(Main_app parent )
	{
		// イベントハンドラ - コードビハインド
		okButton= (Button) parent.window.FindName("ok_button");
/*		// 丁寧な書き方 - コンストラクタの外にメソッド記述
		okButton.AddHandler(
			Button.ClickEvent,
			new RoutedEventHandler(okButton_Click)
		);
*/
		// 変数指定があるパターン
		// okButton.Click+= (object sender, RoutedEventArgs e)=>
		okButton.Click+= (sender, e)=>
		{
			Console.WriteLine("click! button test");
			okButton.Content= "-----chk-chk";
			Console.WriteLine(okButton.Content);	//コンテントproperty
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
