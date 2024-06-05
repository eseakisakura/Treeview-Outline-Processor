using System; 
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;	// Brushes

class Panel_class
{
	public StackPanel panel2;
	public DockPanel panel3;

	public Panel_class(Main_app parent )
	{
		panel2= new StackPanel()
		{
			Orientation= Orientation.Horizontal,
			Background= Brushes.Red,
			Height= 120,
			Margin= new Thickness(20,20,20,20),
		};
		parent.bg_panel.Children.Add(panel2 );
		// parent.panel.Children.AddRange(new Control[] { panel2  } );	// できない


		panel3= new DockPanel()
		{
			Background= Brushes.Navy,
			// Height= 120,
			Margin= new Thickness(20,20,20,20),
		};
		parent.bg_panel.Children.Add(panel3 );
	}
}
