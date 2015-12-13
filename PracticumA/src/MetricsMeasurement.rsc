module MetricsMeasurement

import IO;
import List;
import Set;
import Tuple;
import String;

// Import modules for M3 model and analysis support
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import MetricsGrading;

// Retrieve all java files from project based on the M3 model data
public set[loc] getListOfJavaUnits(loc projectName)
{
	m3_model = createM3FromEclipseProject(projectName);
	return {src | <name, src> <- m3_model@declarations, isCompilationUnit(name)};
}

// Total lines of a java file is indicated by the endline in the location info
// Assumption here is that only 1 class is defined in 1 java file. No explicit checks
// While compiler is already complaining if you try to make 2 class declarations in 1 file
// Counting is 0 based, so +1 indicates real number of lines
public int countTotalLinesInJavaUnit(loc fileName)
{
	return (fileName.end.line - fileName.begin.line) + 1;
}

public bool isEmptyLine(str oneLine)
{
	return isEmpty(oneLine);
}

public bool isScopeDelimiterLine(str oneLine)
{
	//return (oneLine=="}" || oneLine=="{" || oneLine=="};");
	return (/\s*[{}][;]?/ := oneLine) ? true : false;	
}

// This method will count the number of empty lines given by the unit defined in fileName
// Also scope delimitters { and } are treated as empty lines
public int countEmptyLinesInJavaUnit(loc fileName)
{
	int nrOfWhiteLines = 0;
	int nrOfScopeDelimitters = 0;
	
	str fileContents = readFile(fileName);	
		
	list[str] splitted = split("\n",fileContents);	
	
	for(str oneLine<-splitted)
	{	
		oneLine = trim(oneLine);
		
		// Determine if string is empty, indicating whiteline
		// Or has only a {, } which actually is not code. Of this is integrated on the codeline
		nrOfWhiteLines = nrOfWhiteLines + (isEmptyLine(oneLine)?1:0);
		nrOfScopeDelimitters= nrOfScopeDelimitters + (isScopeDelimiterLine(oneLine)?1:0);			
	}
	
	// Unfortunately iteration over a set always skips last line in for statement
	// therefore explicit check on last element
	lastLine = splitted[size(splitted)-1];
	nrOfWhiteLines = nrOfWhiteLines + (isEmptyLine(lastLine)?1:0);
	nrOfScopeDelimitters= nrOfScopeDelimitters + (isScopeDelimiterLine(lastLine)?1:0);	
	
	//println("Number of whitelines: <nrOfWhiteLines>");
	//println("Number of scope delimitters: <nrOfScopeDelimitters>");
	return nrOfWhiteLines + nrOfScopeDelimitters;
}

// Determin the number of lines in a set of M3 @documentation annotations
public int determineNumberOfLinesInDocumentationSet(set[loc] documentationSet)
{
	int totalNrOfLines = 0;
	
	for(loc commentSection <- documentationSet)
	{
		nrOfLines = commentSection.end.line - commentSection.begin.line;
		totalNrOfLines = totalNrOfLines + nrOfLines + 1;
	}
	
	return totalNrOfLines;
}

// in the m3 model cretrieve the @document annotations and determine the number of commentlines in each annotation
public int countLinesOfCommentsInJavaUnit(loc fileName)
{
	M3 m3_model = createM3FromFile(fileName); 

	set[loc] documentationSet = {comment | <src,comment> <- m3_model@documentation};
	
	return determineNumberOfLinesInDocumentationSet(documentationSet);
}

public int CalculateProjectLinesOfCode(set[JavaFileMetrics] projectInfo)
{
	int projectTotalLinesOfCode = 0;
	int projectLinesOfCode = 0;
	int projectLinesOfComment = 0;
	int projectLinesOfEmpty = 0;
	
	// Print info from each java file in the project
	for(JavaFileMetrics infoBlock<-projectInfo)
	{
		projectTotalLinesOfCode = projectTotalLinesOfCode + infoBlock.totalLines;
		projectLinesOfCode = projectLinesOfCode + infoBlock.linesOfCode;
		projectLinesOfComment = projectLinesOfComment + infoBlock.linesOfComments;
		projectLinesOfEmpty = projectLinesOfEmpty + infoBlock.emptyLines;
	}
	
	//println("Total number of  lines in project: <projectTotalLinesOfCode>");
	//println("Total number of code lines in project: <projectLinesOfCode>");
	//println("Total number of comment lines in project: <projectLinesOfComment>");
	//println("Total number of empty lines in project: <projectLinesOfEmpty>");
	//println("Sum of comments+code+empty = equal? <projectLinesOfCode+projectLinesOfComment+projectLinesOfEmpty>");
	//
	return projectLinesOfCode;
}

// Built up metrics per method in the project. This is including constructors
// - Total lines of code per method
// - Complexity per method
//
// JavaFileMetrics are a bit abused here, because in this case actually all methods in the project are stored in one JavaFileMetrics. Room for improvement.
public JavaFileMetrics DetermineMethodMetrics(JavaFileMetrics metrics, loc projectName)
{
	m3_model = createM3FromEclipseProject(projectName);
	
	// Retrieves a set of 'method' . These methods can be directly used in other functions because they are returning loc type
	rel[loc methodname, loc methodText] methodList = { <declarationName,src> | <declarationName,src> <- m3_model@declarations, isConstructor(declarationName) || isMethod(declarationName)};
	
	int maxNrOfPredicates = 0;
		
	for (meth<-methodList)
	{
		int commentLinesTotal = countLinesOfCommentsInJavaUnit(meth.methodText);
		int emptyLinesTotal   = countEmptyLinesInJavaUnit(meth.methodText);
		int totalLines        = countTotalLinesInJavaUnit(meth.methodText);

		//println("<meth.methodname.file>:<l> associated lines of comments");
		//println("<meth.methodname.file>:has <p> empty lines");

		int nrOfPredicates = 0;
		
		// read stuff in AST format, which can be used to determine the cyclic complexity by counting statements while..if..etcera
		s = getMethodASTEclipse(meth.methodname, model=m3_model);
		
		visit (s)
		{
			case \do(_, _, _): 	nrOfPredicates += 1;
			case \if(_, _): 	nrOfPredicates += 1;
			case \if(_, _, _): 	nrOfPredicates += 1;
			case \for(_,_,_,_):	nrOfPredicates += 1;
			case \for(_,_,_):	nrOfPredicates += 1;
			case \case(_): 		nrOfPredicates += 1;
			case \while(_,_):	nrOfPredicates += 1;
		}
		
		//println("Method--:<meth.methodText> - CC = <nrOfPredicates+1> - Total Lines = <totalLines>:<emptyLinesTotal>:<commentLinesTotal>");
		maxNrOfPredicates = maxNrOfPredicates<nrOfPredicates+1 ? nrOfPredicates+1 : maxNrOfPredicates;
		
		MethodLinesOfCode = totalLines - emptyLinesTotal - commentLinesTotal;
		cyclicComplexity = nrOfPredicates + 1;
		
		metrics.methods = metrics.methods + mm(meth.methodname, MethodLinesOfCode, cyclicComplexity);		
	}		
	
	println("Max complexity encountered = <maxNrOfPredicates>");

	return metrics;
}