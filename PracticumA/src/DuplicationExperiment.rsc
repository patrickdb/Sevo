module DuplicationExperiment

import lang::java::jdt::m3::Core;
import util::Resources;

import IO;
import Set;
import String;
import List;
import DateTime;

data SplittedLine = line(str codeLine, bool duplicate);

// Make seperate lines of the total file input and remove all trailing and leading spaces
// Also skip those lines which do not contain information (are empty)
//
// The list returned has an additonal flag per line, which is used later on to mark
// a line duplicate
public list[SplittedLine] SplitContentAndRemoveTrailingSpacesAndEmptyLines(str fileContents)
{	
	return [line(trim(codeLine),false) | codeLine<-split("\n",fileContents), (!isEmpty(trim(codeLine))&& !(/[\/*].*/ := trim(codeLine)))];
}

// Merge the splitted lines into one liners that
// contain the number of lines as given by chunkSize
// This will reduce the number of comparisons needed for all text
public list[str] MergeNLinesTo1Line(splitted, chunkSize, totalLines, startLine)
{	
	list[str] mergedLines = [];
	int n = startLine;
	
	while (n <= (totalLines - chunkSize))
	{		
		bool allLinesDuplicate = false;
		str mergedLine = "";
		
		//	If all lines merged for this chunk are already marked duplicate
		// we add an empty line, signalling to the check for duplication this  line can be skipped
		for (i <- [0..chunkSize])
			allLinesDuplicate = allLinesDuplicate && splitted[n+i].duplicated;
		
		if (!allLinesDuplicate)
		{
			for (i <- [0..chunkSize])
				 mergedLine = mergedLine + splitted[n+i].codeLine;
						
			mergedLines = mergedLines + mergedLine;
		}
				
		n = n + chunkSize;
	}	

	return mergedLines;
}

public list[SplittedLine] MarkDuplicateLines(splitted, chunkSize)
{
	int blockProcessingLine = 0;
	
	int totalLines = size(splitted);	
	
	// Evaluate all relevant lines until we reached the end - chunkSize
	while (blockProcessingLine <= (totalLines - chunkSize))
	{	
		// Merge n lines (identified by chunkSize together in 1 line, to reduce number of comparisons needed
		// The window of comparison is shifted one line by one line through the file
		mergedItems = MergeNLinesTo1Line(splitted, chunkSize, totalLines, blockProcessingLine);
		//println("<blockProcessingLine>:<size(mergedItems)>");

		int idxMergedItems = 1;		
		str stringToProcess = mergedItems[0];
		
		//println(mergedItems);
					
		while ( (idxMergedItems <= (size(mergedItems)-1)) )
		{	
			// Chunks in which all lines  were already marked duplicate, are written as an empty string
			// and do not need additional comparison (we already now it is duplicate)
			// If string is not empty, compare if there is a duplicate line here
			if(!isEmpty(stringToProcess) && (stringToProcess==mergedItems[idxMergedItems]))
			{
				println("<blockProcessingLine>:<size(mergedItems)>");
				
				//println("Duplicate Found @ index: <idxMergedItems>, <stringToProcess>, <blockProcessingLine>, <chunkSize>");					
				for(i <- [0..chunkSize])
				{	
					splitted[blockProcessingLine + (chunkSize*idxMergedItems) + i].duplicate 	= true;			
					splitted[blockProcessingLine + i].duplicate 	= true;						
				}
			}	
					
			idxMergedItems = idxMergedItems + 1;
		}
			
		 
		blockProcessingLine = blockProcessingLine + 1;	
		//println(splitted);
	}
	
	return splitted;
}

public real CalculateDuplicationOfCode(LinesMarkedDuplicate)
{	
	nrOfDuplicatedLines = 0.0;
	
	totalLines = size(LinesMarkedDuplicate);
	
	
	for(SplittedLine t<-LinesMarkedDuplicate)	
		nrOfDuplicatedLines = nrOfDuplicatedLines + (t.duplicate?1.0:0.0);
	
	return (nrOfDuplicatedLines / totalLines) * 100.0;
}

public void main_()
{	
	//str fileContents = readFile(|project://PracticumA/FullDuplicationMutliLine.txt|);
	//str fileContents = readFile(|project://PracticumA/FullDuplicationSingleChar.txt|);
	//str fileContents = readFile(|project://PracticumA/MultiLineDuplicationExceedsChunkSize.txt|);			
	//str fileContents = readFile(|project://PracticumA/DuplicationSmallerThanChunkSize.txt|);
	
	str fileContents = "";
	Resource project = getProject(|project://smallsql|);
	listOfJavaFiles =[ item | /file(item) <- project, item.extension == "java"];
	
	for (filename <- listOfJavaFiles)
	{
		fileContents = fileContents + readFile(filename);
	}
	
	//println(fileContents);	  
	
	// Empty lines and spaces are not taken into account while looking for duplication
	splitted = SplitContentAndRemoveTrailingSpacesAndEmptyLines(fileContents);	
		
	//println(splitted);
	//println(size(splitted));
	
	startTime=now();	
	
	// Find and mark duplicate lines 
	// number is chunk size
	splitted = MarkDuplicateLines(splitted, 6);	
	
	endTime = now();
	println("totaltime: <endTime-startTime>");

	percentageDuplicatedCode = CalculateDuplicationOfCode(splitted);
		
	println("<percentageDuplicatedCode>% duplication"); 
}