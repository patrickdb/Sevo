module DuplicationExperiment

import IO;
import Set;
import String;
import List;

public void main()
{
	// Read file contents
	str fileContents = readFile(|project://PracticumA/duplication.txt|);	
		
	list[str] splitted = split("\n",fileContents);
	println(splitted);
	
	int blockProcessingLine = 0; 
	int totalLines = size(splitted);
	
	while (blockProcessingLine < (totalLines-3))
	{
	int n=blockProcessingLine;
	list[str] mergedItems = [];
	while (n <= (size(splitted)-3))
	{
		if (splitted[n] != "*Duplicate*" && splitted[n+1] != "*Duplicate*" && splitted[n+2] != "*Duplicate*")
		{  
			mergedItems = mergedItems + (splitted[n]+splitted[n+1]+splitted[n+2]);
		}
		
		n=n+3;
	}
	
	println("merged: <mergedItems>");
	
	list[str] setOfMergedStrings = [];
	
	int CountOfMergeItems = size(mergedItems) - 1;
	int idxMergedItems = 0;
	
	//for(str new<-mergedItems)
	while ( (idxMergedItems <= CountOfMergeItems))
	{
		str stringToProcess = mergedItems[idxMergedItems];
		//println(stringToProcess);

		if(stringToProcess in setOfMergedStrings )
		{
			//println("<new> is found multiple times");
			println("Duplicate Found @ index: <idxMergedItems>");
			// remove duplicate from oriinal input ('splitted'). SO it is not re-counted later on.
			// list index mergeditems * chunkSize = index in 'splitted' list
			// first record a list of idx with duplicate
			
			splitted[blockProcessingLine + (3*idxMergedItems)] = "*Duplicate*";
			splitted[blockProcessingLine + (3*idxMergedItems) +1] = "*Duplicate*";
			splitted[blockProcessingLine + (3*idxMergedItems) +2] = "*Duplicate*";
			
			println(splitted);
			
			// also mark the bock being processed duplicate
			splitted[blockProcessingLine] = "*Duplicate*";
			splitted[blockProcessingLine +1] = "*Duplicate*";
			splitted[blockProcessingLine +2] = "*Duplicate*";
			
			println(splitted);
		}
		else
		{
			// not yet in set so add. As soon a duplicate is found, the if-clause is executed
			setOfMergedStrings = setOfMergedStrings + stringToProcess;
		}		
		
		// mark with a 'mark string' all duplicates from original list based on the idx of duplicates
		// at least the first 6 items of the original list are marked when a duplicate was found
		// directly skipping this 6 lines
		
		idxMergedItems = idxMergedItems + 1;
	}
	
		// rebuild chunks from the next line of code which is not marked 'duplicate'
		// with the remaining string in the original list again chunks
		// process is repeated until all lines processed
	
		println("Unique: <setOfMergedStrings>");
		blockProcessingLine = blockProcessingLine + 1;
	}
	
	println(splitted);
	
	dupl = 0.0;
	for(str t<-splitted)
	{	
		if(t=="*Duplicate*")
			dupl=dupl+1.0;
	}
	
		sizeInp = size(splitted);
		
		perc = (dupl / sizeInp) * 100.0;
		
		println(dupl); println(sizeInp);
		println("<perc>% duplication"); 
	
}