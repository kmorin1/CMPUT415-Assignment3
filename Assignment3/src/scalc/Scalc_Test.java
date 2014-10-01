package scalc;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.antlr.stringtemplate.StringTemplateGroup;
		       
public class Scalc_Test {
	public static void main(String[] args) throws RecognitionException {
		if (args.length != 2) {
			System.err.print("Insufficient arguments: ");
			System.err.println(Arrays.toString(args));
			System.exit(1);
		}

		ANTLRFileStream input = null;
		try {
			input = new ANTLRFileStream(args[0]);
		} catch (IOException e) {
			System.err.print("Invalid program filename: ");
			System.err.println(args[0]);
			System.exit(1);
		}

		try {
			simpleCalcLexer lexer = new simpleCalcLexer(input);
			TokenStream tokenStream = new CommonTokenStream(lexer);
			simpleCalcParser parser = new simpleCalcParser(tokenStream);
			simpleCalcParser.program_return entry = parser.program();
			Object ast = entry.getTree();

			// Pass over to verify no variable misuse
			CommonTreeNodeStream nodes = new CommonTreeNodeStream(ast);
			
			if (args[1].equals("int")) {
				// Run it through the Interpreter
				nodes.reset();
				Interpreter interpreter = new Interpreter(nodes);
				interpreter.program();
			} else {
				// Pass it all to the String templater!
				String templateFile = args[1] + ".stg";

				FileReader template;
				try {
					template = new FileReader(templateFile);

					StringTemplateGroup stg = new StringTemplateGroup(template);

					nodes.reset();

					Templater templater = new Templater(nodes);
					templater.setTemplateLib(stg);
					System.out.println(templater.program().getTemplate().toString());				
				} catch (FileNotFoundException e) {
					System.out.print("The template file is missing:");
					System.out.println(templateFile);
				}
			}
		} catch (RuntimeException e) {
			System.out.println("A problem has occured with the scalc input file:");
			System.out.println("Please check the input file for correctness.");
			System.exit(1);
			
		}
	}

}

