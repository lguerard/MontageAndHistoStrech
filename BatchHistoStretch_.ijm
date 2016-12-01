macro "BatchHistoStretch"
{
	/* This macro will apply the same histogram stretch to all the images in a folder.
	 * Then, once the stretch is applied, the images are saved as tiff.
	 * 
	 * Instructions:
	 * Choose the folder where the images are stored.
	 * Choose the min and max value for the histogram stretch
	 * 
	 * Macro created by Laurent Guerard 161108
	 * Version 1.00
	 */

	//Select the folder
	dir = getDirectory("Choose the folder where the images are stored");

	listDir = getFileList(dir);

	minStretch = newArray(3);
	maxStretch = newArray(3);

	//Create window to get the values
	Dialog.create("Min and Max values");
	Dialog.addMessage("Choose the minimal and maximal values for the histogram stretch");
	Dialog.addNumber("Minimal for Blue:",0);
	Dialog.addNumber("Maximal for Blue:",65536);
	Dialog.addNumber("Minimal for Red:",0);
	Dialog.addNumber("Maximal for Red:",65536);
	Dialog.addNumber("Minimal for Green:",0);
	Dialog.addNumber("Maximal for Green:",65536);
	Dialog.show();
	minStretch[0] = Dialog.getNumber();
	maxStretch[0] = Dialog.getNumber();
	minStretch[1] = Dialog.getNumber();
	maxStretch[1] = Dialog.getNumber();
	minStretch[2] = Dialog.getNumber();
	maxStretch[2] = Dialog.getNumber();

	for(b = 0; b < listDir.length ; b++)
	{
		tempDir = dir+listDir[b];
		if(File.isDirectory(tempDir))
		{
			//Get all the file in the folder
			list = getFileList(tempDir);
			//Create the output folder
			outputDir = tempDir+"HistoStretch"+File.separator;
			File.makeDirectory(outputDir);

			setBatchMode(true);

			//Loop through all the files in the folder
			for(a = 0; a < list.length ; a++)
			{
				//Show the progress in FIJI status bar
				showProgress(a+1, list.length);
				//Check if the file is not a folder and is a lsm file
				if(!File.isDirectory(tempDir+list[a]) && endsWith(list[a],".lsm"))
				{
					//Open it and get different information
					open(list[a]);
					name = getTitle();
					dotIndex = lastIndexOf(name,".");
					shortTitle = substring(name, 0, dotIndex);
					Stack.getDimensions(width,height,channels,slices,frames);

					//Loop through the channels
					for(i=1;i<=channels;i++)
					{
						Stack.setChannel(i);
						setMinAndMax(minStretch[i-1],maxStretch[i-1]);
					}
				}
				//Save as tiff in the output folder
				saveAs("tiff",outputDir+shortTitle);
			}
		}
	}
	//Finish message
	showMessage("The tiff images are now saved");
}