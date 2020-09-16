import java.io.*;
import java.util.*;

public class TSVRandomizer {
	public static void main(String[] argv) throws Exception {
		System.err.println("synopsis: TSVRandomizer FILE.TSV\n"+
			"\tFILE.TSV file with tab-separated values\n"+
			"write randomized version of FILE.TSV to stdout, skip empty lines and #-marked comments");
	
		System.err.print("read from "+argv[0]);
		ArrayList<String> lines = new ArrayList<String>();
		BufferedReader in = new BufferedReader(new FileReader(argv[0]));
		for(String line = in.readLine(); line!=null; line=in.readLine()) 
			if(!line.trim().startsWith("#") && !line.trim().equals("")) {
				lines.add(line);
				if(lines.size() % 123 == 0) System.err.print("\rread from "+argv[0]+": "+lines.size()+" lines");
			}
		System.err.println("\rread from "+argv[0]+": "+lines.size()+" lines\n");
		
		System.err.println("reordering");
		Collections.shuffle(lines);
		for(String line : lines)
			System.out.println(line);
	}
}
		