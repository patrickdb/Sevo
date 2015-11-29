module GatheringMetrics

// Import modules for M3 model and analysis support
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

// Some general libraries
import IO;
import Set;
import Tuple;


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
public int countTotalLinesInJavaUnit(loc fileName)
{
	return fileName.end.line;
}

// With a regular expression the number of empty files is counted
public int countEmptyLinesInJavaUnit(loc fileName)
{
	return -1;
}

// in the m3 model cretrieve the @document annotations and determine the number of commentlines in each annotation
public int countLinesOfCommentsInJavaUnit(loc fileName)
{
	return -1;
}

public void crap()
{
for(int i<-[1..10]) {println;}

//m3_model = createM3FromFile(projectName);//(projectName);
	
	//println(m3_model);
	//println(m3_model.comment);
	/*
	set[loc] compilationUnit = {src | <name, src> <- m3_model@declarations, isCompilationUnit(name)};
	loc compilationUnitSrc = getOneFrom(compilationUnit);
	println(compilationUnitSrc);
	println(compilationUnitSrc.end.line);*/

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
	projectName = |project://smallsql|;
	
	set[loc] files = getListOfJavaUnits(projectName);
	
	set[JavaFileInfo] projectInfo = {};
	
	for(loc javaFile<-files) 
	{	
		JavaFileInfo fileInfo = info(javaFile,0,0,0,0,<"",0,0>);
		
		fileInfo = CalculateLineStatistics(fileInfo);
				
		projectInfo = projectInfo + fileInfo; //info(javaFile,totalLines,totalLines-emptyLines-commentLines,0,0,<"",0,0>); 	
	}
	
	int projectLinesOfCode = 0;
	
	// Print info from each java file in the project
	for(JavaFileInfo infoBlock<-projectInfo)
	{
		println(infoBlock.fileLocation);
		println("Number of lines in file: <infoBlock.totalLines>");
		//println("Number of empty lines in file: <emptyLines>");
		//println("Number of comment lines in file: <commentLines>");
		//println("");
		
		projectLinesOfCode = projectLinesOfCode + infoBlock.totalLines;
	}
	
	println("Total number of lines in project: <projectLinesOfCode>");
}