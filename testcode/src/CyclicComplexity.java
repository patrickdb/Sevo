



public class CyclicComplexity {
	
	public CyclicComplexity()
	{
	
	}
	
	public void CC1()
	{
		// comment
		int a=0;
		a=a+1;
	}
	
	public void CC2()
	{
		//cpmment
		//comment
		
		int i=0;
		while(i<10)
		{
			i++;
		}
	}
	
	public void CC4()
	{
		/* and another one */
		int i=0;
		while(i<10)
		{			
			if (i==2)
			{
				i=i+2;
			}
			else
			{
				i++;
			}			
		}
	}
}



