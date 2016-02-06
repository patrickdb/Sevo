module MethodBarDiagram

import VisualAssists;
import MetricsGrading;

import vis::Figure;
import vis::Render;
import vis::KeySym;

import List;
import IO;

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

public Figure DisplayBarsLegend()
{
	Figure title = text("CyclicComplexity ",size(100,15),resizable(false));
	
	b4 = box(size(16,16),resizable(false),fillColor("red"));
	b3 = box(size(16,16),resizable(false),fillColor("orange"));
	b2 = box(size(16,16),resizable(false),fillColor("yellow"));	
	b1 = box(size(16,16),resizable(false),fillColor("green"));
	
	t1 = text("<ccb["low"]>-<ccb["Medium"]>", fontSize(12), size(80,20), resizable(false));
	t2 = text("<ccb["Medium"]>-<ccb["High"]>", fontSize(12), size(80,20), resizable(false));
	t3 = text("<ccb["High"]>-<ccb["veryHigh"]>", fontSize(12), size(80,20), resizable(false));
	t4 = text("<ccb["veryHigh"]>-...", fontSize(12), size(80,20), resizable(false));	
	
	legendaLine = hcat([b1, t1, b2, t2, b3, t3, b4, t4], resizable(false));
	return hcat([title, legendaLine],resizable(false));
}

public Figure DisplayMethodComplexityBars(list[methodMetrics] listOfMethods, str className, bool sizeSorting)
{
	maxBarWidth = 750;
	barHeight   = 16;	
	
	barWidthMul = maxBarWidth / FindMaxSLOC(listOfMethods);	

	strSort = sizeSorting?"Size":"Complexity";
	
	Figure title = text("Method Size & Complexity", fontSize(16));
	Figure sub1 = text("Class: <className>");
	Figure sub2 = text("Sorted by: <strSort>");
	
	bars = [box([size(methodData.methodSLOC * barWidthMul, barHeight), fillColor(colorBasedOnComplexity(methodData.methodComplexity)),left(), 
	             onMouseDown(bool (int butNr, map[KeyModifier,bool] modifiers) {
				    println(methodData.methodName);
	                return true;
	             }),
	             resizable(false),left(),top(),
	             PopupBox(text("<methodData.methodName.file> = <methodData.methodSLOC> SLOC ; Complexity: <methodData.methodComplexity>"), right())
	            ]) | 
				methodData<-selectedSort(listOfMethods, sizeSorting)];
	
	
	// Make the bardiagram scrollable
	scrollableDiagram = vscrollable(vcat(bars,resizable(false)),shrink(1.0),top());
	plotbars = box(scrollableDiagram,size(800,550),resizable(false),top());
	
	header = vcat([title, sub1, sub2]);
	combined = vcat([header, plotbars]);
	return 	combined;
}