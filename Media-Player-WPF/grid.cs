using System; 
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;	// Brushes

class Grid_class
{
	public Grid grid;
	ColumnDefinition col0;
	ColumnDefinition col1;

	public Grid_class(Main_app parent )
	{
		grid= new Grid()
		{
			Background= Brushes.Green,	// 静的プロパティ
			Height= 120,
			Margin= new Thickness(20,20,20,20),	// Thickness 構造体
		};

		col0= new ColumnDefinition()
		{
			Width= new GridLength(2.0, GridUnitType.Star ),	// GridLength 構造体
			// Width= GridLength.Auto,
		};
		col1= new ColumnDefinition()
		{
			Width= new GridLength(0.5, GridUnitType.Star ),
		};

		grid.ColumnDefinitions.Add(col0);
		grid.ColumnDefinitions.Add(col1);	// 0.5* - こちらが優先される

		Border border= new Border()
		{
			BorderBrush= Brushes.Pink,
			// BorderThickness= new Thickness(1,1,1,1),
			BorderThickness= new Thickness(1),
			CornerRadius = new CornerRadius(15),
		};
		grid.Children.Add(border );
		Grid.SetColumn(border, 1);	// Grid.SetColumnこれで良いらしい

		parent.bg_panel.Children.Add(grid );
	}
}
