using System;

class Get_file
{
	static int index= 27;	// Duration

	[STAThread]
	static public string File_property(string location)
	{

		var shellAppType = Type.GetTypeFromProgID("Shell.Application");
		dynamic shell = Activator.CreateInstance(shellAppType);

		// Shell32.Folder
		var objFolder = shell.NameSpace(System.IO.Path.GetDirectoryName(location ));
		// Shell32.FolderItem
		var folderItem = objFolder.ParseName(System.IO.Path.GetFileName(location ));

		string ret = objFolder.GetDetailsOf(folderItem, index);

		return ret;
	}
}
