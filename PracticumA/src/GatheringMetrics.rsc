module GatheringMetrics

// Some general libraries
import IO;
import List;
import String;

// Own defined module
import MetricsGrading;
import MetricsMeasurement;
import MetricsDuplication;

// File IO for acaching
import ValueIO;

import util::Math;
import Set;

public JavaFileMetrics GatherFileStatistics(JavaFileMetrics fInfo)
{	
	javaFile = fInfo.fileName;
	//println(javaFile.file);
	
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
	projectName = |project://Jabberpoint/|;
	//projectName = |project://TestCode/|;
	//projectName = |project://org.eclipse.epsilon.epl.engine/|;
	
	println("Gathering project statistics...");	
	set[loc] files = getListOfJavaUnits(projectName);
	
	JavaFileMetrics fileInfo = info(|project://./|,0,0,0,0,[]);
	set[JavaFileMetrics] projectInfo = {};
	
	// Built up method statistics like SLOC and complexity
	JavaFileMetrics methodStatistics = info(|project://./|,0,0,0,0,[]);
		
	println("Gathering method statistics...");
	methodStatistics = GatherMethodStatistics(fileInfo, projectName);	
	
	// Built up a list of statistics for each file in the project
	for(loc javaFile<-files)
	{			
		fileInfo = info(javaFile,0,0,0,0,[]);
		fileInfo = GatherFileStatistics(fileInfo);
		
		fileInfo.methods = methodStatistics.methods;
		//println(fileInfo.methods);
						
		projectInfo = projectInfo + fileInfo;
	}
	
	println("Gathering per class statistics...");
	set[classMetrics] classMeasurements = {};
	
	// Fill class metrics
	for(jfm<-projectInfo)
	{	
		classData = cm(jfm.fileName, "",0,0,0,[]);
		
		stringToFind = "/" + replaceAll(jfm.fileName.file, ".java", "") + "/";
		println(stringToFind);
		
		classData.className = stringToFind;
		
		int numberOfMethods = 0;
		int sizeAllMethods  = 0;
		
		for(int i <- [0..size(jfm.methods)])
		{
			a = jfm.methods[i].methodName.path;
			
			if(contains(a,stringToFind))
			{
				numberOfMethods += 1;
				sizeAllMethods += jfm.methods[i].methodSLOC;
				classData.methods = classData.methods + jfm.methods[i];
				//println("<a>: <jfm.methods[i].methodComplexity>");
			}
		}		
		
		classData.totalMethods = numberOfMethods;
		classData.classSize    = sizeAllMethods;

		classMeasurements += classData;
	}	
	
	println("Calculating total number of lines in project...");	
	projectLinesOfCode 		= CalculateProjectLinesOfCode(projectInfo);
	//
	//println("Calculating percentage of duplication in project...");	
	//percentageDuplicated 	= MeasureDuplicationOfCode(projectName);
	percentageDuplicated = 0.0;	
	
	println("Writing class metrics to file....");
	writeBinaryValueFile(|file:///d:/ClassMetrics.bin|, classMeasurements, compression=true);
	
	println("Writing project metrics to file....");
	writeBinaryValueFile(|file:///d:/ProjectMetrics.bin|, projectInfo, compression=true);
	
	gradeVolume 		= GradeProjectVolume(projectLinesOfCode);
	gradeComplexity 	= GradeProjectComplexityDistribution(methodStatistics, projectLinesOfCode);
	gradeDuplication	= GradeProjectDuplication(percentageDuplicated);	
	gradeMethodSize		= GradeProjectMethodSizeDistribution(methodStatistics, projectLinesOfCode);
	
	gradeProject 		= GradeProjectOverall(gradeVolume, gradeComplexity, gradeDuplication, gradeMethodSize);
	
	println("Grade for project complexity: <gradeComplexity>*");
	println("Grade for project size of <projectLinesOfCode> SLOC: <gradeVolume>*");
	println("Grade for project overal method size: <gradeMethodSize>*");
	println("Grade for code duplication of <percentageDuplicated>%: <gradeDuplication>*");
	println;
	println("Overal project grade: <toInt(gradeProject)>*");
	
	projectRating rates = _rating(toInt(gradeProject), gradeComplexity, gradeVolume, gradeMethodSize, gradeDuplication);
	writeBinaryValueFile(|file:///d:/ProjectGrades.bin|, rates, compression=true);
}


