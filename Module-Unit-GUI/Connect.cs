using System;
using System.Drawing;
using System.Windows.Forms;

class Connect	// non static to field
{
	public static bool hook= false;
	public static int send_id= 0;
	public static int post_id= 0;
	public static Box_mod[] mod= new Box_mod[0];	// instance count
	public static Pen xpen = new Pen(Color.Blue, 2);
	public static Pen ypen = new Pen(Color.Orange, 2);
	public static bool[] arr_tog= new bool[0];


	static public void Module_remove(Lay_pict parent, int select )
	{
		if( mod.Length > 0 ){	// Safety

			parent.bg_picture.Controls.Remove( mod[select].bg_picture );

			Box_mod[] brr= new Box_mod[mod.Length- 1 ];
			int num= mod.Length;
			int j= 0;

			for( int i= 0; i < num; i++){
				if( i == select ){
				}else{
					brr[j]= mod[i];
					brr[j].assign= j;
					j++;
				}
			} //
			mod= brr;

			int x= arr_tog.Length;

			int number= mod.Length;
			int y= Convert.ToInt32( Math.Pow(number, 2) );	// 4^2
			bool[] brray= new bool[y];
			int h= 0;

			for( int i= 0; i< x; i++){
				if( i/ num == select){
				}else if( i% num == select){
				}else{
					brray[h]= arr_tog[i];
					h++;
				}
			} //
			arr_tog= brray;

			foreach( bool f in arr_tog)
				Console.WriteLine("arr_tog--- "+ f);
		}
	}

	static public void Bg_draw(Bg_pict grand)
	{
		int num= mod.Length;
		int x= arr_tog.Length;

		grand.gpb.Clear(Color.RoyalBlue);

		for( int i= 0; i< x; i++){

			if ( i% num == i/ num){	// 00,11,.. // <- false only
			}else{
				if(arr_tog[i] == true){
					int ss= i/ num;
					int pp= i% num;

					grand.gpb.DrawLine(ypen, mod[ss].bg_picture.Location.X, mod[ss].bg_picture.Location.Y, mod[pp].bg_picture.Location.X, mod[pp].bg_picture.Location.Y );
				}
			}
		} //

		grand.bg_picture.Refresh();	// Bg描画
	}


	static public void Bg_toggle()	// MouseUp Event
	{

		int[] id_arr= { send_id, post_id };
		Array.Sort( id_arr );	// 20 -> 02変換

		Console.WriteLine("id_arr[0]--- "+ id_arr[0]);
		Console.WriteLine("id_arr[1]--- "+ id_arr[1]);

		int num= mod.Length;
		int x= id_arr[0]* num+ id_arr[1];

		Console.WriteLine("x--- "+ x );

		if(arr_tog[x] == true){
			arr_tog[x]= false;	// Cable Remove
		}else{
			arr_tog[x]= true;
		}

		foreach( bool f in arr_tog)
			Console.WriteLine("arr_tog--- "+ f);
	}


	static public void Module_add(Bg_pict grand, Lay_pict parent )
	{
		Console.WriteLine("add-start !");

		Array.Resize(ref mod, mod.Length+ 1);
		mod[ mod.Length- 1]= new Box_mod(grand, parent );

		int num= mod.Length;
		int fin= num- 1;

		mod[fin].assign= fin;


		parent.bg_picture.Controls.Clear();

		for( int i= fin; i >= 0; i--){	// 012 >>210 上下位置を修正
			parent.bg_picture.Controls.AddRange(new Control[] { mod[i].bg_picture } );
		} //

		int x= Convert.ToInt32( Math.Pow(num, 2) );	// 4^2 // 4^0.5
		bool[] brray= new bool[x];
		int j= 0;

		for( int i= 0; i< x; i++){
			if( i/ num == fin){
				brray[i]= false;
			}else if( i% num == fin){	// else space if
				brray[i]= false;
			}else{
				brray[i]= arr_tog[j];
				j++;
			}
		} //

		arr_tog= brray;

		// foreach( bool f in arr_tog)
		//	Console.WriteLine("arr_tog--- "+ f);
	}

	public static void Lay_draw(Lay_pict parent, int assign)
	{
		parent.gpb.Clear(Color.Transparent);
		parent.gpb.DrawLine(xpen, mod[assign].bg_picture.Location.X, mod[assign].bg_picture.Location.Y, parent.bg_picture.PointToClient(Cursor.Position).X, parent.bg_picture.PointToClient(Cursor.Position).Y );
		parent.bg_picture.Refresh();	// レイヤー描画
	}

}
