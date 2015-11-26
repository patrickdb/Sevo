module Relaties

import analysis::graphs::Graph;
import Relation;
import ListRelation;
import Set;

import IO;

public rel[str,str] paden = { 
	<"A","B">, <"A","D">, 
	<"B","D">, <"B","E">,
	<"C","E">, <"C","B">, <"C","F">,
	<"E","D">, <"E","F">
};

public int asize(rel[str,str] t)
{
	int count = 0;
 	for(tuple[str,str] i <- t) 
 	{
 		count=count+1;
 	}
 	
 	return count;
}

public void main()
{
	L="Gedefinieerde vertices: ";
	P=carrier(paden);
	println("<L> <P>");
	
	L="aantal paden: ";
	P=asize(paden);
	println("<L> <P>");
	
	L="Niet gerefereerde componenten";
	println(top(paden));
	
	L="Component van A";
	println((paden+)["A"]);
	
	L="Ongebruikte componenten van C";
	println(carrier(paden)-(paden*)["C"]);
	
	L="Aantal usages per component";
	
	map[str,int] s= (a:size(invert(paden)[a]) | a <- carrier(paden));
	println(s);
	
}

