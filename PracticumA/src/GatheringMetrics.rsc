module GatheringMetrics

// Import modules for M3 model and analysis support
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

// Some general libraries
import IO;
import Set;
import Tuple;
import List;
import String;

// Define own data type to gather java file related info
// - LinesOfCode
// - Number of comments
// - Tupel <MethodName, Number of code lines, Complexity>
data JavaFileInfo = info(loc fileLocation, int totalLines, int emptyLines, int linesOfComments, int linesOfCode, tuple[str methodName,int methodSLOC,int methodComplexity] methods);

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
	return fileName.end.line + 1;
}

public bool isEmptyLine(str oneLine)
{
	return (/\s*/ := oneLine) ? true : false;
	//return isEmpty(oneLine);
}

public bool isScopeDelimiterLine(str oneLine)
{
	//return (oneLine=="}" || oneLine=="{" || oneLine=="};");
	return (/\s*[{}][;]?/ := oneLine) ? true : false;	
}

// With a regular expression the number of empty files is counted
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

public void testAST()
{
	m3_model = createM3FromEclipseProject(|project://TestCode|);
	
	// Retrieves a set of 'method' . These can be directly used in other functions bcause they are loc
	rel[loc methodname, loc methodText] methodList = { <declarationName,src> | <declarationName,src> <- m3_model@declarations, isMethod(declarationName)};
	println(m3_model);
	println(methodList);
	
	for (meth<-methodList)
	{
		int l = countLinesOfCommentsInJavaUnit(meth.methodText);
		int p = countEmptyLinesInJavaUnit(meth.methodText);
		//int l2 = countLinesOfCommentsInJavaUnit(meth.method);
		println("<meth.methodname.file>:<l> associated lines of comments");
		println("<meth.methodname.file>:has <p> empty lines");
		//println(l2);
		
		// read stuff in AST format, which can be used to determine the cyclic complexity by counting statements while..if..etcera
		//s = getMethodASTEclipse(meth, model=m3_model);
		//println(s);
	}		
}

public JavaFileInfo CalculateLineStatistics(JavaFileInfo fInfo)
{	
	javaFile = fInfo.fileLocation;
	totalLines = countTotalLinesInJavaUnit(javaFile);
	emptyLines = countEmptyLinesInJavaUnit(javaFile);
	commentLines = countLinesOfCommentsInJavaUnit(javaFile);
	
	fInfo.totalLines = totalLines;
	fInfo.emptyLines = emptyLines;
	fInfo.linesOfComments = commentLines;
	fInfo.linesOfCode = totalLines - (emptyLines+commentLines);
	
	return fInfo;
}

public void main()
{	
	projectName = |project://TestCode|;
	
	set[loc] files = getListOfJavaUnits(projectName);
	
	set[JavaFileInfo] projectInfo = {};
	
	for(loc javaFile<-files) 
	{	
		JavaFileInfo fileInfo = info(javaFile,0,0,0,0,<"",0,0>);
		
		fileInfo = CalculateLineStatistics(fileInfo);
				
		projectInfo = projectInfo + fileInfo; //info(javaFile,totalLines,totalLines-emptyLines-commentLines,0,0,<"",0,0>); 	
	}
	
	int projectTotalLinesOfCode = 0;
	int projectLinesOfCode = 0;
	int projectLinesOfComment = 0;
	int projectLinesOfEmpty = 0;
	
	// Print info from each java file in the project
	for(JavaFileInfo infoBlock<-projectInfo)
	{
		println(infoBlock.fileLocation.file);
		println("Number of lines in file: <infoBlock.totalLines>");
		println("Number of empty lines in file: <infoBlock.emptyLines>");
		println("Number of comment lines in file: <infoBlock.linesOfComments>");
		println("Number of code lines in file: <infoBlock.linesOfCode>");
		println("");
		
		projectTotalLinesOfCode = projectTotalLinesOfCode + infoBlock.totalLines;
		projectLinesOfCode = projectLinesOfCode + infoBlock.linesOfCode;
		projectLinesOfComment = projectLinesOfComment + infoBlock.linesOfComments;
		projectLinesOfEmpty = projectLinesOfEmpty + infoBlock.emptyLines;
	}
	
	println("Total number of  lines in project: <projectTotalLinesOfCode>");
	println("Total number of code lines in project: <projectLinesOfCode>");
	println("Total number of comment lines in project: <projectLinesOfComment>");
	println("Total number of comment lines in project: <projectLinesOfEmpty>");
	println("Sum of comments+code+empty = equal? <projectLinesOfCode+projectLinesOfComment+projectLinesOfEmpty>");
}