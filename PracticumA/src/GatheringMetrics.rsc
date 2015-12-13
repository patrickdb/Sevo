module GatheringMetrics

// Some general libraries
import IO;

// Own defined module
import MetricsGrading;
import MetricsMeasurement;
import MetricsDuplication;

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
	//projectName = |project://smallsql/|;
	//projectName = |project://Jabberpoint/|;
	//projectName = |project://TestCode/|;
	projectName = |project://hsqldb/|;
	
	println("Gathering project statistics...");
	
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
	
	println("Gathering method statistics...");
	methodStatistics 		= GatherMethodStatistics(methodStatistics, projectName);
	
	println("Calculating total number of lines in project...");	
	projectLinesOfCode 		= CalculateProjectLinesOfCode(projectInfo);
	
	println("Calculating percentage of duplication in project...");	
	percentageDuplicated 	= MeasureDuplicationOfCode(projectName);	
	
	gradeVolume 		= GradeProjectVolume(projectLinesOfCode);
	gradeComplexity 	= GradeProjectComplexityDistribution(methodStatistics, projectLinesOfCode);
	gradeDuplication	= GradeProjectDuplication(percentageDuplicated);
	gradeMethodSize		= GradeProjectMethodSizeDistribution(methodStatistics, projectLinesOfCode);
	
	gradeProject 	= GradeProjectOverall(gradeVolume, gradeComplexity, gradeDuplication, gradeMethodSize);
	
	println("Grade for project complexity: <gradeComplexity>*");
	println("Grade for project size of <projectLinesOfCode> SLOC: <gradeVolume>*");
	println("Grade for project overal method size: <gradeMethodSize>*");
	println("Grade for code duplication of <percentageDuplicated>%: <gradeDuplication>*");
	println;
	println("Overal project grade: <gradeProject>*");
}