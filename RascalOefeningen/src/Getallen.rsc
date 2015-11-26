module Getallen

import Relation;
import IO;
import Set;
import Map;
import List;

public rel[int,int] DelersVan(int maxNumber)
{
	// For every a from 1 .. maxNumber, try the numbers from 1..a if the division results
	// in no remainder
	// Read as: 
	// create a relation <a,b> with:
	// a: cycling through 1 until (inclusive) maxNumber+1
	// b: Go for each a through 1..a (inclusive las number, so+1) 
	// result is valid if a%b has no remainder (a%b==0)
	return { <a,b> | a <- [1..maxNumber+1], b <- [1..a+1], a%b==0 };
	
}

public list[int] FindNumberWithMostDividers(rel[int,int] r)
{
	map[int, int] m = ( a:size(r[a]) | a <- domain(r) );
	println(m);
	mr = max(range(m));
	//println("Max divisors = "); println(mr);
	
	//println(domain(m));
	
	// Add to the list thosse elements that have an a which have a number of divisors equal to mr (max divisors)
	list[int] l = ( [a | a <- domain(m), m[a]==mr] );
		
	return l;
}

public void SortedPrime(rel[int,int] r)
{
	map[int, int] m = ( a:size(r[a]) | a <- domain(r) );
	list[int] l = ( [a | a <- domain(m), m[a]==2] );
	println(sort(l));
}

public void main()
{
	rel[int,int] r;
	r = DelersVan(5000);
	
	//println(sort(r));
	
	SortedPrime(r);
	//l = FindNumberWithMostDividers(r);
	//println(l);
	
	//map[int, int] m = ( a:size(r[a]) | a <- domain(r) );
	//max(range(m));
}