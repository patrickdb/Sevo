module ClassTreeMap

import vis::Figure;
import vis::KeySym;
import vis::Render;

import IO;
import util::Math;


// Import necessary datatype for metrics
import MetricsGrading;

// Some general vis stuff
import VisualAssists;

// Some public function to retrieve data based on user interaction with treemap
// Get list of methods of latest selected class
str lastClassName = "";
list[methodMetrics] lastMethodMetrics;
bool _updated = false;

public list[methodMetrics] tmap_LastSelectedClassMethods()
{
	classSelected = false;
	return lastMethodMetrics;
}

// What was the last selected class in the treemap?
// Clients can retrieve this value 
public str tmap_LastSelectedClassName()
{	
	_updated = false;	
	
	return lastClassName;
}

// Has the treemap been recently updated? 
// This flag is set when user selects cell in treemap
public bool tmap_isUpdated()
{
	return _updated;
}

// Make it possible for clients to clear internal data that can be retrieved
public void tmap_clear()
{
	lastClassName = "";
	_updated = true;
}

// Find the method set belonging to a specific class
private list[methodMetrics] FindMethodMetrics(set[classMetrics] cms, str classNameToFind)
{
	list[methodMetrics] listOfClassMethodMetrics = [];	
	
	for(classMetrics <- cms, classMetrics.className == classNameToFind)
	{
		// To notify succesful selection was performed and which class + methods belong to this 
		lastClassName = classNameToFind;
		lastMethodMetrics = classMetrics.methods;	
		_updated = true;
	}
	
	return lastMethodMetrics;
}

// Retrieve color belonging to a complexity grade of the class
private str colorBasedOnGrade(int grade)
{	
	map[int, str] colorMap = (1:"red", 2:"orange", 3:"yellow", 4:"blue", 5:"green");
	return colorMap[grade];
}

// shows some extra info when hoovering over the class treemap
private FProperty popupClassInfo(cls)
{
	popupText = text("<cls.className>\n
Total Methods    = <cls.totalMethods>
Size             = <cls.classSize> LOC
Avg. Method Size = <cls.classSize / cls.totalMethods>\n", fontSize(9), fontBold(true));

	return PopupBox(popupText,right());
}

// Displays a legend to lookup meaning of used colors
private Figure LegendaLine()
{
	Figure title = text("Class complexity Rating",size(100,15),resizable(false));
	
	b1 = box(size(16,16),resizable(false),fillColor("red"));
	b2 = box(size(16,16),resizable(false),fillColor("orange"));
	b3 = box(size(16,16),resizable(false),fillColor("yellow"));
	b4 = box(size(16,16),resizable(false),fillColor("blue"));
	b5 = box(size(16,16),resizable(false),fillColor("green"));
	
	t1 = text("1-Star", fontSize(12), size(80,20), resizable(false));
	t2 = text("2-Star", fontSize(12), size(80,20), resizable(false));
	t3 = text("3-Star", fontSize(12), size(80,20), resizable(false));
	t4 = text("4-Star", fontSize(12), size(80,20), resizable(false));
	t5 = text("5-Star", fontSize(12), size(80,20), resizable(false));
	
	legendaLine = hcat([b5, t5, b4, t4, b3, t3, b2, t2, b1, t1], resizable(false));
	return vcat([title, legendaLine],resizable(false));	
}

// Shows a treemap where each cell is based on metrics of one class
// totalLOC is used to calculate percentage of total treemap area assigned to seperate class size
public Figure ShowClassMetricsTreeMap(set[classMetrics] cm)
{	
	Figures boxes = [];
	
	for(cls<-cm)	
	{
		//calculate distribution and grade class for complexity				
		cls.complexityRate = GradeCategory(CalculateCCPercentagePerCategoryM(cls));
		
		nameOfClass = cls.className; 
		areaSize = cls.classSize;
		if (areaSize>200)
		{
			areaSize = 200.0 + pow(toReal(cls.classSize),1.05);
		}
		
		boxes = boxes + box(area(areaSize), fillColor(colorBasedOnGrade(cls.complexityRate)), popupClassInfo(cls),
		onMouseDown(bool (int butNr, map[KeyModifier,bool] modifiers) {				 
				 FindMethodMetrics(cm, nameOfClass);
				 println("<nameOfClass> selected");
	             return true;
	             }));
	}
	
	Figure title = text("Class Size & Complexity", fontSize(16), size(80,30), resizable(false));
	t = treemap(boxes, shrink(0.9));
	
	Figure containingBox = box(vcat([title,t,LegendaLine()]), size(1200,200), resizable(false));
     
   	return containingBox;
}