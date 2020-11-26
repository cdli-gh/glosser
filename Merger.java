import java.io.*;
import java.util.*;

public class Merger {

	public static void main(String argv[]) throws Exception {
		System.err.println("synopsis: Merger -pos INT -gloss INT [-code INT]");
		if(argv[0].toLowerCase().startsWith("-h"))
			System.err.println(
				"\t-pos   column containing POS information; column numbering starts at 0\n"+
				"\t-gloss column containing a morphological gloss, should contain the (predicted) POS\n"+
				"\t-code  column with gloss prediction metadata as produced by Glosser, i.e.,\n"+
				"\t  D  dictionary match\n"+
				"\t  I...  unseen word (with various inference strategies\n"+
				"Merging strategy:\n"+
				"  - if POS=\"_\" or POS=\"?\", predict GLOSS, else\n"+ 
				"  - if CODE=\"D\", predict GLOSS, else\n"+
				"  - if GLOSS matches \"(.*[^a-zA-Z0-9])?POS([^a-zA-Z0-9].*)?\", predict GLOSS, else\n"+
				"  - predict POS\n"+
				"reads a TSV file from stdin, appends one column with merged prediction and one column with merge/inference code:\n"+
				" D     dictionary match, from GLOSS\n"+
				" I...  inference, from GLOSS (original inference code), compliant with POS column\n"+
				" POS   POS column\n"+
				" GLOSS from GLOSS, no original code given");
		int POS=-1;
		int GLOSS=-1;
		int CODE=-1;
		for(int i = 0; i<argv.length; i++) {
			if(argv[i].toLowerCase().equals("-pos")) POS=Integer.parseInt(argv[++i]); else 
			if(argv[i].toLowerCase().equals("-gloss")) GLOSS=Integer.parseInt(argv[++i]); else
			if(argv[i].toLowerCase().equals("-code")) CODE=Integer.parseInt(argv[++i]);
		}
		
		System.err.println("running Merger -pos "+POS+" -gloss "+GLOSS+" -code "+CODE);
		
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		for(String line = in.readLine(); line!=null; line=in.readLine()){
			System.out.print(line);
			if(!line.startsWith("#") && !line.trim().equals("")) {
				String form=line.replaceFirst("[#\t].*","").trim();
				String[] fields=line.split("\t");
				if(fields.length>POS && fields.length>GLOSS && fields.length>CODE) {
					String pos=fields[POS];
					String gloss=fields[GLOSS];
					if(gloss.equals(""))
						gloss="_";
					String code="GLOSS";
					if(CODE>=0)
						code=fields[CODE];
					if(pos.equals("_") || pos.equals("?")) {
						System.out.print("\t"+gloss+"\t"+code);
					} else if(code.equals("D")) {
						System.out.print("\t"+gloss+"\t"+code);
					} else if(gloss.matches("^(.*[^a-zA-Z0-9])?"+pos+"([^a-zA-Z0-9].*)?$")) {
						System.out.print("\t"+gloss+"\t"+code);
					} else
						System.out.print("\t"+pos+"\t"+"POS");
				}
			}
			System.out.println();
		}
	}
}