using System;
using System.Drawing;
using System.Windows.Forms;

class Box_mod
{

	public int assign= 0;
	Point start_pos;	// Location move adjust
	// Point adjust_pos;
	// Point adj_pos;
	// Point Loc_pos;

	bool location_capture= false;
	bool draw_capture= false;


	Bitmap bg_img = new Bitmap(100, 60);

	public PictureBox bg_picture = new PictureBox()
	{
		Location = new Point(10, 10),
		Size = new Size(100, 60),
		BackColor = Color.Transparent,	// 透明化に必要
	};

	Graphics gpb;	// static

	Color  skyblue = Color.FromArgb(150,176,224,230);	// powderblue
	Color  blue = Color.FromArgb(150,76,124,130);

	Pen xpen;
	//SolidBrush xbrush;

	public Box_mod( Bg_pict grand, Lay_pict parent )	// 親へのアクセス
	{
		bg_picture.Location= parent.bg_picture.PointToClient(Cursor.Position);	// Cursor.Position;


		bg_picture.Image= bg_img;
		bg_picture.ClientSize= bg_img.Size;
		gpb = Graphics.FromImage(bg_img);

		gpb.Clear(skyblue);

		 xpen = new Pen(blue, 2);
		// xbrush = new SolidBrush(skyblue);

		gpb.DrawRectangle( xpen, 1,1, 99,59 );
		//gpb.FillRectangle(XBbrush, 20,10, 45,158);

		bg_picture.Refresh();

		bg_picture.MouseMove+= (sender, e)=>
		{
			// Console.WriteLine("check--Move");

			if( location_capture == true){

				int X= parent.bg_picture.PointToClient(Cursor.Position).X- start_pos.X;
				int Y= parent.bg_picture.PointToClient(Cursor.Position).Y- start_pos.Y;
				bg_picture.Location= new Point(X, Y);
				Connect.Bg_draw(grand);
			}

			if( draw_capture == true){
				Connect.Lay_draw(parent, assign);
			}

	// parent.gpb.Clear(Color.Transparent);
	// parent.gpb.DrawLine(Connect.xpen, start_pos.X, start_pos.Y, parent.bg_picture.PointToClient(Cursor.Position).X, parent.bg_picture.PointToClient(Cursor.Position).Y );
	// parent.bg_picture.Refresh();	// レイヤー描画

				// Point to_pos= Cursor.Position;

				// int num_X= Loc_pos.X+ to_pos.X- from_pos.X;
				// int num_Y= Loc_pos.Y+ to_pos.Y- from_pos.Y;

				// box_picture.Location = new Point(num_X, num_Y);
		};

		bg_picture.MouseLeave+= (sender, e)=>
		{
			// Console.WriteLine("check--Leave"+ assign);
		};

		bg_picture.MouseHover+= (sender, e)=>
		{
			Connect.post_id= assign;

			// Down:0 >>Hover:0 ケースのマウスバッファ遅延ため
			if(Connect.send_id == Connect.post_id){
			}else{
				if( Connect.hook == true){
					Connect.Bg_toggle();
					Connect.Bg_draw(grand);
					Connect.hook= false;
				}

			}
			Console.WriteLine("check--Hover "+Connect.hook);
		};

		bg_picture.MouseUp+= (sender, e)=>
		{
			// Console.WriteLine("check--Up");

			parent.gpb.Clear(Color.Transparent);
			parent.bg_picture.Refresh();	// レイヤー描画
			draw_capture= false;
			location_capture= false;

			// grand.gpb.DrawLine(xpen, start_pos.X, start_pos.Y, e.Location.X, e.Location.Y );

			// parent.gpb.Render(grand.gpb);	// <- これがないので以下で行う
			// grand.gpb.DrawImage(parent.bg_img, 0, 0, parent.bg_img.Width, parent.bg_img.Height );
			// レイヤーを重ねた感じとなる

			// grand.bg_picture.Refresh();	// BG描画

		};

		bg_picture.MouseDown+= (sender, e)=>
		{
			switch( e.Button )	// Clickはe.Buttonがない
			{
			case MouseButtons.Right :
				location_capture= true;
				start_pos = this.bg_picture.PointToClient(Cursor.Position);
				break;
			case MouseButtons.Middle :
				Connect.Module_remove(parent, this.assign );
				Connect.Bg_draw(grand);
				break;
			case MouseButtons.Left :
				Console.WriteLine("check--Down");

				draw_capture = true;
				Connect.hook= true;
				Connect.send_id= assign;
				break;
			} // sw
		};
	}
}
