module GatheringMetrics

// Import modules for M3 model and analysis support
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

// Some general libraries
import IO;
import Set;

// Retrieve all java files from project based on the M3 model data
public set[loc] getListOfJavaUnits(loc projectName)
{
	m3_model = createM3FromEclipseProject(projectName);
	return {src | <name, src> <- m3_model@declarations, isCompilationUnit(name)};
}

public int countTotalLinesInJavaUnit(loc fileName)
{
	return fileName.end.line;
}

public int countEmptyLinesInJavaUnit(loc fileName)
{
	return -1;
}

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

public void main()
{	
	projectName = |project://TestCode|;
	
	set[loc] files = getListOfJavaUnits(projectName);
	
	for(loc javaFile<-files) 
	{	
		fileName = javaFile.file;
		totalLines = countTotalLinesInJavaUnit(javaFile);
		emptyLines = countEmptyLinesInJavaUnit(javaFile);
		commentLines = countLinesOfCommentsInJavaUnit(javaFile);
			
		println("<fileName>:");
		println("Number of lines in file: <totalLines>");
		println("Number of empty lines in file: <emptyLines>");
		println("Number of comment lines in file: <commentLines>");
		println("");
	}		
}