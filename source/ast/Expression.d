module ast.Expression;
import ast.Instruction;
import syntax.Word;

class Expression : Instruction {

    this (Word word) {
	super (word);
    }

    override void print (int nb = 0) {}
    
}

