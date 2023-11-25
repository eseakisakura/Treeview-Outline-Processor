using System;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Drawing2D;	// Path

class Lay_pict
{
	// bool mouse_capure= false;

	// Point pos;
	// int prev_X = 0;
	// int prev_Y = 0;

	// int Layer_number= 0;

	public Bitmap bg_img = new Bitmap(560, 310);

	public PictureBox bg_picture = new PictureBox()
	{
		Location = new Point(0, 0),
		Size = new Size(560, 310),
		BackColor = Color.Transparent,	// 透明化に必要
	};

	public Graphics gpb;	// static
	//GraphicsPath gph;

	// Color black = Color.FromArgb(255, 24, 39, 61);	// static Color型
	Color  skyblue = Color.FromArgb(210,176,224,230);	// powderblue

	Pen xpen;
	SolidBrush xbrush;

	// public  Lay_pict(int num, Lay_pict parent= null)	// 引数なしのoverLoad略ため、初期値セット
	public  Lay_pict(Bg_pict parent)
	{
		// Console.WriteLine(parent);

		xpen = new Pen(skyblue, 2);
		xbrush = new SolidBrush(skyblue);

		// Layer_number= num;

		// parent.bg_picture.Parent= this.bg_picture;	// 下へ重ねる
		this.bg_picture.Parent= parent.bg_picture;

		bg_picture.Image= bg_img;
		gpb = Graphics.FromImage(bg_img);
		// GraphicsPath gph= new GraphicsPath();

		// gpb.Clear(black);
		// gpb.Clear(Color.Transparent);

		gpb.DrawString("Layer", new Font("Segoe UI", 20), xbrush, 10, 10);
		// gpb.DrawString(Layer_number.ToString(), new Font("Segoe UI", 20), XBbrush, 0, 0);
		// string キャスト

		// gpb.DrawRectangle(XBpen, 9,19,63,103);
		// gpb.FillRectangle(XBbrush, 20,10, 45,158);

		bg_picture.Refresh();


/*		bg_picture.KeyDown+= (sender, e)=>
		{
			// 実行できない -> mainform側へ取られる
			Console.WriteLine("check0");
			this.bg_picture.Parent= null;
			this.gpb.Dispose();
		};

		bg_picture.MouseUp+= (sender, e)=>
		{
			mouse_capure= false;
			// Array Layer_store[Length- 1]= new Layer_pict();
			// Cursor.Clip = Rectangle.Empty;
		};
*/
		bg_picture.MouseHover+= (sender, e)=>
		{
			// Console.WriteLine("check--LayHover");
			if( Connect.hook == true){
				Connect.hook= false;
			}

		};

		bg_picture.MouseDown+= (sender, e)=>
		{
	switch( e.Button )	// Clickはe.Buttonがない
	{
	case MouseButtons.Right :

			// Lay_pict Lay_draw= new Lay_pict(Layer_number+ 1, this );
			break;
	case MouseButtons.Middle :
			break;
	case MouseButtons.Left :
			// Console.WriteLine("check--Left");

			Connect.Module_add(parent, this );
			// Box_mod box_draw= new  Box_mod(parent, this );
			// this.bg_picture.Controls.AddRange(new Control[] { box_draw.bg_picture } );

			// mouse_capure = true;
			// pos = e.Location;
			break;
	} // sw

			// gph.StartFigure();

			// from_pos = this.PointToClient(Cursor.Position);
			// Cursor.Clip = new Rectangle(num[0], num[1], num[2], num[3] );
		};

/*		bg_picture.MouseMove+= (sender, e)=>
		{
			if( mouse_capure == true){

				gpb.Clear(Color.Transparent);
				// gpb.Clear(black);

				Pen pen = new Pen(Color.Red,4);
				gpb.DrawLine(pen, pos.X, pos.Y, e.Location.X, e.Location.Y);

				bg_picture.Refresh();
			}
		};
*/
	}

	// void Draw_rect()
	// {
		// gpb.Clear(black);

		// gpb.DrawRectangle(XBpen, 9,19,63,103);
		// gpb.FillRectangle(XBbrush, 20,10, 45,158);

		// err_Picturebox.Refresh();
	// }
}
