// Exercise 4
module RegularExpressions

import IO;

list[str] eu = ["Belgiee", "Bulgarije", "Cyprus", "Denemarken",
"Duitsland", "Estland", "Finland", "Frankrijk", "Griekenland",
"Hongarije", "Ierland", "Italie", "Letland", "Litouwen",
"Luxemburg", "Malta", "Nederland", "Oostenrijk", "Polen",
"Portugal", "Roemenie", "Slovenie", "Slowakije", "Spanje",
"Tsjechie", "Verenigd Koninkrijk", "Zweden"];

public list[str] countryContainsS()
{	
	return
		for(s <- eu)
		{
			if(/.*s.*/i := s)
			{
				append s;
			}		
		};
}

public list[str] countryAtLeast2E()
{
	return
		for(s <- eu)
		{
			if(/e.*e/i := s)
			{
				append s;
			}
		};
}

public list[str] countryExactly2E()
{
	return
		for(s <- eu)
		{	
			if(/([^e]*e){2}[^e]/i := s)
			{
				append s;
			}
		};
}

public list[str] countryNoNNoE()
{
return
		for(s <- eu)
		{	
			if(/^[^ne]*$/i := s)
			{
				append s;
			}
		};
}

public list[str] countryLetterIsRepeated()
{
     return
		for(s <- eu)
		{	
			if(/<x:\w>.*<x>/i := s)
			{
				append s;
			}
		};
}

public list[str] countryReplaceFirstAWithO()
{
}

public void main() {
  
  println ("The following countries have an s in their name");
  println (countryContainsS());
  
  println ("\nThe following countries have at least 2 e\'s in their name");
  println (countryAtLeast2E());
  
  println ("\nCountries with exactly 2 e\'s");
  println (countryExactly2E());
  
  println ("\nCountries with no N and no E");
  println (countryExactly2E());
  
  println ("\nCountries with having 2 occuring letters in their name");
  println(countryLetterIsRepeated());
  
   
}