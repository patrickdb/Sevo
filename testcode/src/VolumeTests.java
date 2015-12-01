/**
 * This file is used in performing some simple volume metrics
 * 
 * Volume metrics are calculated by taking total of lines of a file, minus blank lines and comments
 * 
 * Total Lines of code: 
 * 
 * @author 885982
 *
 */
public class VolumeTests {
	
	/**
	 * Sloc
	 */
	public void SLOC_4()
	{
		// This is some extra comment
		String s = new String();
		for (int i=0; i<10; ++i)
		{
			s = s+"a";
		}
		
		System.out.println(s);
	}
	
	public void SLOC_2()
	{
		int t=0;
		t=t+1;
	}
};



