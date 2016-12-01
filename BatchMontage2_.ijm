macro "Montage3x3"
{
	/* This macro will make two 3x3 montages of the images in a folder.
	 * One montage will be done for each channel, one will be done for composite images.
	 * Then, once the stretch is applied, the images are saved as tiff.
	 * 
	 * Instructions:
	 * Choose the folder where the images are stored.
	 * Choose the min and max value for the histogram stretch
	 * 
	 * Macro created by Laurent Guerard 161109
	 * Version 1.00
	 */

	//Select the folder
	dir = getDirectory("Choose the folder where the images are stored");

	color = newArray(3);
	color[0] = "Blue";
	color[1] = "Red";
	color[2] = "Green";

	
	listDir = getFileList(dir);
	//print("List : "+listDir.length);
	for(b = 0; b < listDir.length; b++)
	{
		//print("B = "+b);
		tempDir = dir + listDir[b];
		loopThroughFiles(tempDir, b);
		close("*");
		if(File.exists(tempDir+"HistoStretch"))
			loopThroughFiles(tempDir+"HistoStretch"+File.separator,b);
		close("*");
	}
	
	//Finish message
	showMessage("The tiff images are now saved");
}


function loopThroughFiles(tempDir, b)
{
	if(File.isDirectory(tempDir))
	{

		
		//print("TD: "+tempDir);
		//Get all the file in the folder
		list = getFileList(tempDir);
		//print("\t"+list.length);
		//Create the output folder
		outputDir = tempDir+"Montage"+File.separator;
		File.makeDirectory(outputDir);
		//print("OD: "+outputDir);

		setBatchMode(true);
		tempDir = substring(tempDir,0,lengthOf(tempDir)-1)+File.separator;

		//Show the progress in FIJI status bar
		showProgress(b+1, list.length);

		//Loop through all the files in the folder
		for(a = 0; a < list.length ; a++)
		{

			subString = substring(list[a],0,lengthOf(list[a])-1);
			//print(tempDir+list[a]);
			
			//Check if the file is not a folder and is a lsm file
			if(!File.isDirectory(tempDir+list[a]) && (endsWith(list[a],".lsm") || endsWith(list[a],".tif")))
			{
				//Open all the images
				open(tempDir + list[a]);
				if(endsWith(list[a],".lsm"))
					resetMinAndMax();
			}
		}

		//print("Nimages : "+nImages);
		if (nImages == 9)
			makeMontage();

	}

	
}

function makeMontage()
{
	Stack.getDimensions(width,height,channels,slices,frames);

		//print("TTD: "+tempDir);

		run("Concatenate...", "all_open title=[Concatenated Stacks]");
		run("Hyperstack to Stack");

		//Loop through the channels
		for(i = 1; i <= channels; i++)
		{
			selectWindow("Concatenated Stacks");
			run("Make Montage...", "columns=3 rows=3 first="+i+" increment=3 scale=1 border=5 font=12");
			run(color[i-1]);
			rename("Montage" + color[i-1]);
			name = getTitle();
			saveAs("tiff",outputDir+name);
			//print("Saved as : "+outputDir+name);
		}

		if(channels == 3)
			run("Merge Channels...", "c1=MontageRed.tif c2=MontageGreen.tif c3=MontageBlue.tif create");

		selectWindow("Composite");
		//Save as tiff in the output folder
		saveAs("tiff",outputDir+"CompositeMontage");

		close("*");
}