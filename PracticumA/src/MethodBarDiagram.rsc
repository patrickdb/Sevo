module MethodBarDiagram

import VisualAssists;
import MetricsGrading;

import vis::Figure;
import vis::Render;
import vis::KeySym;

import List;
import IO;

public void DisplayMethodComplexityBars(set[classMetrics] clsInfo)
{
	barwidth = 16;	
	
	bars = [box([size(classData.classSize,barwidth), fillColor("red"), onMouseDown(bool (int butNr, map[KeyModifier,bool] modifiers) {
				 println(classData.uri);
	             return true;
	             }),resizable(false),left(),top(),
	             PopupBox(text("<classData.classSize> SLOC ; Complexity"), right())
	            ]) | 
				classData<-sort(clsInfo, bool(classMetrics a, classMetrics b){return a.classSize > b.classSize;})];
	
	// Make the bardiagram scrollable
	scrollableDiagram = vscrollable(vcat(bars,resizable(false)),shrink(1.0));
	
	render(box(scrollableDiagram,size(500,200),resizable(false)));	
}

// Find largest method LOC and return the LOC of this method
private int FindMaxSLOC(list[methodMetrics] listOfMethods)
{
	maxSLOC = 0;
	
	for(metrics<-listOfMethods, maxSLOC < metrics.methodSLOC)
		maxSLOC = metrics.methodSLOC;
	
	return maxSLOC;	
}

// Based on the complexity return the desired bar color
private str colorBasedOnComplexity(int complexity)
{
	_col = "green";
	
	// TODO: some proper values for complexity
	if (complexity>ccb["veryHigh"])
		_col = "red";
	elseif (complexity>ccb["High"])
		_col = "orange";
	elseif (complexity>ccb["Medium"])
		_col = "yellow";
	
	return _col;
}

// Sort the list of methods on:
// 1. SLOC (SLOCSort=true)
// 2. Complexity (SLOCSort = false)
private list[methodMetrics] selectedSort(list[methodMetrics] listOfMethods, bool SLOCSort)
{
	list[methodMetrics] sortedMetrics = [];
	
	if (SLOCSort)
		sortedMetrics = sort(listOfMethods, bool(methodMetrics a, methodMetrics b){return a.methodSLOC > b.methodSLOC;});
	else
		sortedMetrics = sort(listOfMethods, bool(methodMetrics a, methodMetrics b){return a.methodComplexity > b.methodComplexity;});
		
	return sortedMetrics;
}

public void DisplayMethodComplexityBars2(list[methodMetrics] listOfMethods)
{
	maxBarWidth = 550;
	barHeight   = 16;	
	
	barWidthMul = maxBarWidth / FindMaxSLOC(listOfMethods);	

	bars = [box([size(methodData.methodSLOC * barWidthMul, barHeight), fillColor(colorBasedOnComplexity(methodData.methodComplexity)),left(), 
	             onMouseDown(bool (int butNr, map[KeyModifier,bool] modifiers) {
				    println(methodData.methodName);
	                return true;
	             }),
	             resizable(false),left(),top(),
	             PopupBox(text("<methodData.methodName.file> = <methodData.methodSLOC> SLOC ; Complexity: <methodData.methodComplexity>"), right())
	            ]) | 
				methodData<-selectedSort(listOfMethods, true)];
	
	// Make the bardiagram scrollable
	scrollableDiagram = vscrollable(vcat(bars,resizable(false)),shrink(1.0));
	
	render(box(scrollableDiagram,size(700,500),resizable(false)));	
}