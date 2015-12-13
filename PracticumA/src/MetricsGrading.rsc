// This module takes care of ranking several code metrics as proposed by the SIG Quality model
// Ranking will return a value between [1..5] which maps to the SIG ranking as: 
// -- = 1 ; - = 2; 0 = 3; + = 4; ++ ==5
//
// Folowing ranking calculations are supported:
// - Project Volume; Number of codelines compared to industry standards
// - Method Complexity; Distribution of method complexity in the project per class (moderage; high; very high)
// - Duplication of code; Percentage of code lines which are duplicated
// - Method Size; Distribution of method size in the project per class (moderate; high; very high)
//
// - System Level ranking; Based on different weightings of the system a ranking is calculated for the system based on the above mentioned values
module MetricsGrading

import List;
import Map;
import IO;
import util::Math;

// Define own data type to gather java project metrics
public data methodMetrics = mm(loc methodName, int methodSLOC, int methodComplexity);

public data JavaFileMetrics = info(
	loc fileName, 
	int totalLines, 
	int emptyLines, 
	int linesOfComments, 
	int linesOfCode, 
	list[methodMetrics] methods);
	
// Maps used to lookup quickly ranking values

// Total number of code lines in project
map[int, real] projectSize = (
2:1310000.0,
3:665000.0,
4:246000.0,
5:66000.0
);

// Duplicate code lines in percentage of total amount of code lines of project
public map[int, real] codeDuplication = (
2:0.20,
3:0.10,
4:0.05,
5:0.03
);

// Percentage of code NOT covered by unit tests
map[int, real] unitTestCoverage = (
2:0.80,
3:0.40,
4:0.20,
5:0.05
);

data categories = cls(real moderate, real high, real veryHigh);

list[categories]  classBoundaries = [	
	cls(0.50, 0.15, 0.05),
	cls(0.40, 0.10, 0.0),
	cls(0.30, 0.05, 0.0),
	cls(0.25, 0.0, 0.0),
	cls(0.0,0.0,0.0)
];

categories CalculateCCPercentagePerCategory(JavaFileMetrics info, int SLOCProject)
{
	perCategory = cls(0.0,0.0,0.0);
	
	// Cyclic complexity classes to be identified
	real noRisk = 0.0;
	real moderateRisk = 0.0;
	real highRisk = 0.0;
	real veryHighRisk = 0.0;
	
	// Count total number of lines that occur in methods with a certain complexity 
	for(methodMetrics i<-info.methods)
	{
		if(i.methodComplexity > 50)
			veryHighRisk += i.methodSLOC;				
		else if (i.methodComplexity > 20)
			highRisk += i.methodSLOC;
		else if (i.methodComplexity > 10)
			moderateRisk += i.methodSLOC;
		else
			noRisk += i.methodSLOC;
	}
	
	// Determine percentages based on total number of code in project
	if (SLOCProject>0)
	{
		perCategory.moderate = moderateRisk / SLOCProject;
		perCategory.high     = highRisk / SLOCProject;
		perCategory.veryHigh = veryHighRisk / SLOCProject;		
	}
	
	println("CC Distribution over <SLOCProject> SLOC results in: [<noRisk>:<moderateRisk>:<highRisk>:<veryHighRisk>]");	
	
	return perCategory;
}

categories CalculateMethodSizePercentagePerCategory(JavaFileMetrics info, int SLOCProject)
{
	perCategory = cls(0.0,0.0,0.0);
	
	// Cyclic complexity classes to be identified
	real noRisk = 0.0;
	real moderateRisk = 0.0;
	real highRisk = 0.0;
	real veryHighRisk = 0.0;
	
	int totalMethodLines = 0;
	
	// Count total number of lines that occur in methods with a certain complexity 
	for(methodMetrics i<-info.methods)
	{
		if(i.methodComplexity > 35)
			veryHighRisk += i.methodSLOC;				
		else if (i.methodComplexity > 20)
			highRisk += i.methodSLOC;
		else if (i.methodComplexity > 9)
			moderateRisk += i.methodSLOC;
		else
			noRisk += i.methodSLOC;
			
		totalMethodLines += i.methodSLOC;
	}
	
	// Determine percentages based on total number of code in project
	if (SLOCProject>0)
	{
		perCategory.moderate = moderateRisk / SLOCProject;
		perCategory.high     = highRisk / SLOCProject;
		perCategory.veryHigh = veryHighRisk / SLOCProject;		
	}
	
	println("Method Size Distribution over <SLOCProject> SLOC results in: [<noRisk>:<moderateRisk>:<highRisk>:<veryHighRisk>]");
	println("Number of lines in methods: <totalMethodLines>");	
	
	return perCategory;
}

// Generic Method to look up grading in a single value based table
int SingleValueGrading(real metricsValue, map[int,real] singleValueGradingTable)
{
	int grade = 1;
	
	for(idx <- [(size(projectSize)+1)..1])
	{
		 if(metricsValue < singleValueGradingTable[idx])
		 {
		 	grade = idx;
		 	break;
		 }
	}  
	
	return grade;
}

int GradeProjectVolume(int volume)
{	
	return SingleValueGrading(toReal(volume), projectSize);
}

// Lookup in which row the provided percentages fit
// The index returned is indicating SIG grade
int GradeCategory(categories perc)
{
	int grade = 1;
	
	while ( (perc.veryHigh <= classBoundaries[grade-1].veryHigh) && 
	         (perc.high <= classBoundaries[grade-1].high) && 
	          (perc.moderate <= classBoundaries[grade-1].moderate) &&
	           (grade < 5) )
	{
		//println(perc);
		//println(classBoundaries[grade-1]);
		grade = grade + 1;
	}
	
	return grade;
}

// Calculate the cyclic complexity per category project wide and return the SIG grading mark for the score
public int GradeProjectComplexityDistribution(JavaFileMetrics metrics, int slocProject)
{
	percentagePerCategory = CalculateCCPercentagePerCategory(metrics, slocProject);
	grade = GradeCategory(percentagePerCategory);
	
	return grade;
}

public int GradeProjectDuplication(real percentageOfDuplication)
{
	return SingleValueGrading(percentageOfDuplication, codeDuplication);
}

public int GradeProjectMethodSizeDistribution(JavaFileMetrics metrics, int slocProject)
{
	percentagePerCategory = CalculateMethodSizePercentagePerCategory(metrics, slocProject);
	grade = grade = GradeCategory(percentagePerCategory);
	return grade;
}

public real GradeProjectOverall(int volume, int complexity, int duplication, int methodSize)
{
	return (toReal(volume+complexity+duplication+methodSize)/4);
}