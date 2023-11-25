using System;
using System.Drawing;
using System.Windows.Forms;

class Bg_pict	// 結線ビュー
{

	public Bitmap bg_img = new Bitmap(560, 310);

	public PictureBox bg_picture = new PictureBox()
	{
		Location = new Point(15, 30),
		Size = new Size(560, 310),
		BackColor = Color.Transparent,	// 透明化に必要
	};

	public Graphics gpb;	// static
	//GraphicsPath gph;

	Color black = Color.FromArgb(255, 24, 39, 61);	// static Color型
	Color  skyblue = Color.FromArgb(210,176,224,230);	// powderblue

	Pen xpen;
	// SolidBrush xbrush = new SolidBrush(skyblue);


	public  Bg_pict()
	{
		xpen = new Pen(skyblue, 2);

		bg_picture.Image= bg_img;
		gpb = Graphics.FromImage(bg_img);

		gpb.Clear(black);

		// gpb.DrawString(Layer_number.ToString(), new Font("Segoe UI", 20), XBbrush, 0, 0);
		// string キャスト

		// gpb.DrawRectangle(XBpen, 9,19,63,103);
		// gpb.FillRectangle(XBbrush, 20,10, 45,158);

		bg_picture.Refresh();
	}

	// void Draw_rect()
	// {
		// gpb.Clear(black);

		// gpb.DrawRectangle(XBpen, 9,19,63,103);
		// gpb.FillRectangle(XBbrush, 20,10, 45,158);

		// err_Picturebox.Refresh();
	// }
}
