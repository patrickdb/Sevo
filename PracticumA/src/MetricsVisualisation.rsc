module MetricsVisualisation

import vis::Figure;
import vis::Render;

import IO;
import String;
import ValueIO;

import MetricsGrading;

import VisualAssists;
import MethodBarDiagram;
import ClassTreeMap;
import MethodComplexityScatterPlot;

// Global state variable to handle interactivity in the diagrams
bool sizeSorting 		= true;
bool sortButtonPressed  = false;
str selectedClassName   = "";

Figure barChart;

set[classMetrics] _allClassMetrics;

// For some reason it is not always possible to directly use loaded binary values (type is not known)
set[classMetrics] toClassMetrics(set[classMetrics] inp)
{
	return inp;
}

// Display some general information of the project;
Figure ProjectInfo(projectRating rates)
{
	Figure Title = text("Project Info\n\n", fontSize(16));
	
	Figure name = text("org.eclipse.epsilon.epl.engine");
	Figure Info1 = text("\n\nRating overal: <rates.overall>*");
	Figure Info2 = text("Complexity: <rates.complexity>*");
	Figure Info3 = text("Volume: <rates.volume>*");
	Figure Info4 = text("methodLOC: <rates.methodSizes>*");
	
	Figure  infobox = box(vcat([Title, name, Info1, Info2, Info3, Info4]), fillColor("grey"),resizable(false));
	Figure containingBox = box(infobox, size(150),top(),resizable(false));
	return containingBox;
}

public list[methodMetrics] GetAllMethodsInProject(set[classMetrics] _allClassMetrics)
{
	list[methodMetrics] allMethods = [];
	
	for(classMetrics classMetric <- _allClassMetrics)
	{
		allMethods = allMethods + classMetric.methods;
	}
	
	return allMethods;
}

public Figure InteractiveBarChart()
{
	// Show bar plot for selected class and method size + complexity number
	// The bar will be clickable to explore code behind
	allMethods = GetAllMethodsInProject(_allClassMetrics);
	
	barChart = computeFigure(bool(){
			// When user request different sorting or a class has been selected
			// in the class treemap, the bar diagram has to be updated
	        if(sortButtonPressed || tmap_isUpdated()) 
	        { 
	            sortButtonPressed = false; 
	            return true;} 
	        else 
	        {
	        	return false;
	        } }, 
	        Figure(){	  
	           selectedClassName = tmap_LastSelectedClassName();	             
	              	            
	           if(isEmpty(selectedClassName))
	           {
	           		selectedClassName = "All Classes";
	           		allMethods = GetAllMethodsInProject(_allClassMetrics);
	           }
	           else
	           {
	           		allMethods = tmap_LastSelectedClassMethods();	
	           }
	           
	           return DisplayMethodComplexityBars(allMethods, selectedClassName, sizeSorting);
	        });
	        
	Figure allClsBtn  = button("All Classes",void(){tmap_clear();},
	size(75,15),resizable(false),top());	        
	
	Figure sortButton = button("Switch Sorting", void()
	{
	   if(!sizeSorting) sizeSorting=true; else sizeSorting = false; sortButtonPressed=true;
	}, size(75,15), resizable(false),top());
	
	Figure bottomLine = hcat([DisplayBarsLegend(), allClsBtn, sortButton]);
	        
	return vcat([barChart, bottomLine]);
}

public void main()
{
	loadedClassMetrics   =  readValueFile(|file:///d:/ClassMetrics.bin|);
	loadedProjectMetrics =  readValueFile(|file:///d:/ProjectMetrics.bin|);
	loadedGrades         =  readValueFile(|file:///d:/ProjectGrades.bin|);
	//loadedClassMetrics   =  readValueFile(|file:///d:/EML_ClassMetrics.bin|);
	//loadedProjectMetrics =  readValueFile(|file:///d:/EML_ProjectMetrics.bin|);
	//loadedGrades         =  readValueFile(|file:///d:/EML_ProjectGrades.bin|);
	
	_allClassMetrics = toClassMetrics(loadedClassMetrics); 
		
	// Show tree-map based on class size
	// Size of cells = class size; color of cells = complexity; mouseOver = sloc+complexity distribution
	// Treemap is interactive. when clicking cell the barchart is updated by displaying the complexity of all methods
	Figure tmap = ShowClassMetricsTreeMap(loadedClassMetrics);
	
	// Show q-q plot based on A. Class Size/% high complexity B. Method Size / Complexity
	//lrel[real,real] xy;
	xy = DetermineMethodSizeAgainstComplexity(loadedClassMetrics);
	Figure scatterplot = DisplayMethodComplexityQQ(xy);
	
	// By hoovering over a bar, more information is shown for each bar
	// Clicking on a bar will open the specific method in the editor view
	barChart = InteractiveBarChart();
	
	p2 = hcat([barChart, scatterplot]);
	Figure chart = vcat([hcat([tmap, ProjectInfo(loadedGrades)]), p2]);
	
	render(chart);
	renderSave(chart, |file:///d:/EML_1.png|);	
}
