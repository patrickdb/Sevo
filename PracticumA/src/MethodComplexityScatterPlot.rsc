// This module is responsible to draw the plot where method size and complexity per method are displayed
module MethodComplexityScatterPlot

import VisualAssists;

import vis::Figure;
import vis::Render;
import util::Math;

import MetricsGrading;

// Global variable keeping the maximum x and y value which is used in drawing & calculating oringal values when hovering over the points
real maxX = 0.0;
real maxY = 0.0;

// Normalize values to [0.0 .. 1.00]
// Needed to draw coordinates on right position in box
private lrel[real,real] NormalizeXY(lrel[real,real] xy_values)
{	
	for(<x,y> <-xy_values)
	{
		maxX = max(maxX,x);
		maxY = max(maxY,y);		
	}	
	
	xy_values = [<x/maxX,y/maxY> | <x,y> <- xy_values];	
	
	return xy_values;
}

public lrel[real,real] DetermineMethodSizeAgainstComplexity(set[classMetrics] classInfo)
{	
	lrel[real,real] xypoints= [];
	
	for (cls <- classInfo)
	{	
		xypoints = xypoints + [ <toReal(methodData.methodSLOC), toReal(methodData.methodComplexity)> | methodData <- cls.methods];
	}
	
	xypoints = NormalizeXY(xypoints);	
	
	return xypoints;
}

private Figure GenerateYAxis(str axisName)
{
 	return text(axisName, fontSize(16), fontColor("red"), textAngle(-90),align(0.02,0.5));
}

private Figure GenerateXAxis(str axisName)
{
	return text(axisName, fontSize(16), fontColor("red"),align(0.5,0.97));
}

Figure point(num x, num y){ return ellipse(size(5),fillColor("red"),align(x,1.0-y),resizable(false),PopupBox(text("<toInt(x*maxX)>:<toInt(y*maxY)>"),right()));}

// Plots provided coords as xy-coordinates
// pre: xy coordinates are normalized between [0.0 .. 1.0]
private Figure drawXYPlot(plotArea, coords)
{		
	Figure square = box(size(plotArea),fillColor("white"),resizable(false));
	Figures o_points = square + [point(x,y) | <x,y> <- coords];
		
 	return overlay(o_points);
}

public Figure DisplayMethodComplexityQQ(lrel[real,real] xy_points)
{	
	// The box where axis + plot area will be contained in
	Figure plot = box(size(250),resizable(false));
	
	// xy axis
	Figure yaxis_text = GenerateYAxis("Complexity");
	Figure xaxis_text = GenerateXAxis("Method Size");
	
	// Plot area, including points	
	Figure plotArea = drawXYPlot(350, xy_points);
	
	//Merge seperate Figure elements together into one image
	Figure p = overlay([plot, plotArea, yaxis_text, xaxis_text],resizable(false));
	merged = vcat([text("Project complexity/method size", fontSize(16)), p]); 
	Figure containingBox = box(merged,size(400,500),resizable(false));
	return containingBox;
}