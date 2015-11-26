module EclipseProject

import IO;
import util::Resources;
import lang::java::jdt::m3::Core;
import List;
import Map;
import Set;
import Relation;

public list[loc] RetrieveJavaFilesFromProject(Resource project)
{
/*
	list[loc] jf = [];
	jf = [ item | file(item) <- project, item.extenstion == "java"];
	
	visit(jabber) 
	{	
		case file(l):
		{
			if (l.extension == "java")
			{				
				jf=jf+l;
			}; 
		}
	}*/
		
	return [ item | /file(item) <- project, item.extension == "java"];
}

public map[loc,int] NumberOfLinesPerJavaFile(list[loc] listOfJavaFiles)
{
	map[loc,list[str]] codeMap;
	codeMap = (filename:readFileLines(filename) | filename <- listOfJavaFiles);	
	
	return (filename:size(codeMap[filename]) | filename <- codeMap);
}


public void CountMethodsPerClass(M3 model)
{
	listofmethods = { <_class,_method> | <_class,_method> <- model@containment,
									_class.scheme=="java+class",
									_method.scheme =="java+method" ||
									_method.scheme =="java+constructor" };
									
	println(domain(listofmethods));
	countMethods = { <uniqueMethod,size(listofmethods[uniqueMethod])> | uniqueMethod <- domain(listofmethods) };
	
	println(countMethods);
}

public void main()
{	
	Resource jabber = getProject(|project://Jabberpoint|);
	
	// Get a list with all javafiles from project
	javafiles = RetrieveJavaFilesFromProject(jabber);
	
	// Calculate number of lines in each javafile
	m = NumberOfLinesPerJavaFile(javafiles);	
	
	println("Files with number of lines. [loc]:numberOflines");
	
	// [m[k] : k <- loc]
	for( loc k<-m )
	{
		FileName = k.file;
		NumberOfLines = m[k];
		println("<FileName> : <NumberOfLines>");
	}
	
	NumberOfFiles = size(javafiles);
	println("number of files: <NumberOfFiles>");
	
	println(sort(toList(m), bool(tuple[loc,int] a , tuple[loc,int] b){return a[1]>b[1];}));
	
	M3 projectModel = createM3FromEclipseProject(|project://Jabberpoint/|);
	CountMethodsPerClass(projectModel);	
	
	println(projectModel@extends);
	subclasses = invert(projectModel@extends);
	println(domain(subclasses));
	
	countSubclassPerClass = { <a,size((subclasses+)[a])> | a <- domain(subclasses) };
	println(invert(countSubclassPerClass));
	
}