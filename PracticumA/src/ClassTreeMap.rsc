module ClassTreeMap

// Import necessary datatype for metrics
import MetricsGrading;

// Some general vis stuff
import VisualAssists;

import vis::Figure;
import vis::KeySym;
import vis::Render;

import IO;
import util::Math;

// Find the method set belonging to a specific class
list[methodMetrics] FindMethodMetrics(set[classMetrics] cms, str classNameToFind)
{
	list[methodMetrics] listOfClassMethodMetrics = [];	
	
	for(classMetrics <- cms)
	{
		if (classMetrics.className == classNameToFind)
		{
			listOfClassMethodMetrics = classMetrics.methods;
			println(listOfClassMethodMetrics);
		}
	}
	
	return listOfClassMethodMetrics;
}

private str colorBasedOnGrade(int grade)
{
	_col = "green";
	
	// TODO: some proper values for complexity
	if (grade==1)
		_col = "red";
	elseif (grade==2)
		_col = "orange";
	elseif (grade==3)
		_col = "yellow";
	elseif (grade==4)
		_col = "blue";
	
	return _col;
}

// shows some extra info when hoovering over the class treemap
public FProperty popupClassInfo(cls)
{
	popupText = text("<cls.className>\n
Total Methods    = <cls.totalMethods>
Size             = <cls.classSize> LOC
Avg. Method Size = <cls.classSize / cls.totalMethods>\n", fontSize(9), fontBold(true));

	return PopupBox(popupText,right());
}

// Shows a treemap where each cell is based on metrics of one class
// totalLOC is used to calculate percentage of total treemap area assigned to seperate class size
public void ShowClassMetricsTreeMap(set[classMetrics] cm)
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
				 println(FindMethodMetrics(cm, nameOfClass));
	             return true;
	             }));
	}
	
	t = treemap(boxes);
     
   render(t);
}