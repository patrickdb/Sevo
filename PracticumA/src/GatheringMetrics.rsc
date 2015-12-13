module GatheringMetrics

// Some general libraries
import IO;

// Own defined module
import MetricsGrading;
import MetricsMeasurement;

public JavaFileMetrics GatherFileStatistics(JavaFileMetrics fInfo)
{	
	javaFile = fInfo.fileName;
	
	totalLines = countTotalLinesInJavaUnit(javaFile);
	emptyLines = countEmptyLinesInJavaUnit(javaFile);
	commentLines = countLinesOfCommentsInJavaUnit(javaFile);
	
	fInfo.totalLines = totalLines;
	fInfo.emptyLines = emptyLines;
	fInfo.linesOfComments = commentLines;
	fInfo.linesOfCode = totalLines - (emptyLines+commentLines);
	
	return fInfo;
}

public JavaFileMetrics GatherMethodStatistics(JavaFileMetrics fInfo, loc projectName)
{
	return DetermineMethodMetrics(fInfo, projectName);
}

public void main()
{	
	projectName = |project://Jabberpoint/|;
	
	set[loc] files = getListOfJavaUnits(projectName);
	
	set[JavaFileMetrics] projectInfo = {};
	
	// Built up a list of statistics for each file in the project
	for(loc javaFile<-files) 
	{	
		JavaFileMetrics fileInfo = info(javaFile,0,0,0,0,[]);
		
		fileInfo = GatherFileStatistics(fileInfo);				
		projectInfo = projectInfo + fileInfo;  	
	}
	
	// Built up method statistics like SLOC and complexity
	JavaFileMetrics methodStatistics = info(|project://./|,0,0,0,0,[]);
	methodStatistics = GatherMethodStatistics(methodStatistics, projectName);
	
	int projectTotalLinesOfCode = 0;
	int projectLinesOfCode = 0;
	int projectLinesOfComment = 0;
	int projectLinesOfEmpty = 0;
	
	// Print info from each java file in the project
	for(JavaFileMetrics infoBlock<-projectInfo)
	{
		//println(infoBlock.projectLocation.file);
		//println("Number of lines in file: <infoBlock.totalLines>");
		//println("Number of empty lines in file: <infoBlock.emptyLines>");
		//println("Number of comment lines in file: <infoBlock.linesOfComments>");
		//println("Number of code lines in file: <infoBlock.linesOfCode>");
		//println("");
		
		projectTotalLinesOfCode = projectTotalLinesOfCode + infoBlock.totalLines;
		projectLinesOfCode = projectLinesOfCode + infoBlock.linesOfCode;
		projectLinesOfComment = projectLinesOfComment + infoBlock.linesOfComments;
		projectLinesOfEmpty = projectLinesOfEmpty + infoBlock.emptyLines;
	}
	
	println("Total number of  lines in project: <projectTotalLinesOfCode>");
	println("Total number of code lines in project: <projectLinesOfCode>");
	println("Total number of comment lines in project: <projectLinesOfComment>");
	println("Total number of empty lines in project: <projectLinesOfEmpty>");
	println("Sum of comments+code+empty = equal? <projectLinesOfCode+projectLinesOfComment+projectLinesOfEmpty>");
	
	percentageDuplicated = MeasureDuplicationOfCode(projectName);
	
	gradeVolume 		= GradeProjectVolume(projectLinesOfCode);
	gradeComplexity 	= GradeProjectComplexityDistribution(methodStatistics);
	gradeDuplication	= GradeProjectDuplication(percentageDuplicated);
	
	gradeProject 	= GradeProjectOverall(gradeVolume, gradeComplexity, 1, 1);
	
	println("Grade for project complexity: <gradeComplexity>");
	println("Grade for project size: <gradeVolume>");
	println("Grade for overal method size: ");
	println("Grade for code duplication: <gradeDuplication>");
	println;
	println("Project grade: <gradeProject>");
}