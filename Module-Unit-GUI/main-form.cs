using System; 
using System.Drawing;
using System.Windows.Forms;

class Main_form : Form	// partial 
{
	// from class inner to field side (this and instance)

	// int num= 0;
	// Watch watcher = new Watch();

	public Main_form(string[] args_path)	// constructor 返値はない
	{
		{
			Text= "Module Unit GUI";
			Size= new Size(606, 406);

			Font= new Font("Segoe UI", 11);
			KeyPreview= true;
			AllowDrop= true;

			Deactivate+= (sender, e)=>
			{
				Cursor.Clip = Rectangle.Empty;
				// safty -- カーソルの移動制限を解除
			};

			//(sender, e) = $this, $_
			KeyDown+= (sender, e)=>
			{
				Console.WriteLine("mainform - check0");
			};

			Click+= (sender, e)=>
			{
				Console.WriteLine("check1");
				// Errbox_Console("==== : "+ num);
				// num++;
			};

			Click+= (sender, e)=>
			{
				Console.WriteLine("check2");
			};

			Shown+= (sender, e)=>
			{
				if(args_path.Length > 0){
					Watch_drop(args_path);
				}
			};

			DragEnter+= (sender, e)=>
			{
				if (e.Data.GetDataPresent(DataFormats.FileDrop)){

					e.Effect = DragDropEffects.Copy;
				}else{
					e.Effect = DragDropEffects.None;
				}
			};

			DragDrop+= (sender, e)=>
			{
				Watch_drop((string[]) e.Data.GetData(DataFormats.FileDrop));
			};

		}

		Main_parts_load();
		// this.ShowDialog();
	}

	static void Watch_drop(string[] drop_Path)
	{
		Console.WriteLine(drop_Path[0]);
	}

	void Main_parts_load()
	{
		Bg_pict bg_draw= new  Bg_pict();
		this.Controls.AddRange(new Control[] { bg_draw.bg_picture } );

		Lay_pict Lay_draw= new  Lay_pict(bg_draw );


/*		Mml_picture_insert_form();
		Bg_picture_insert_form();
		Panel_insert_form();
		Menu_insert_form();
		Status_insert_form();


		err_Label_insert_form();
		err_Textbox_insert_form();
		err_Context_insert_form();
		err_Listbox_insert_form();
		err_Button_insert_form();
		err_Checkbox_insert_form();
		err_Combobox_insert_form();
		err_xml_insert_form();
		err_Group_insert_form();
*/
	}
}
