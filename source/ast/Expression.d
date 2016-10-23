module ast.Expression;
import ast.Instruction;
import syntax.Word, semantic.pack.Symbol;

class Expression : Instruction {

    protected Symbol _info;
    
    this (Word word) {
	super (word);
    }

    ref Symbol info () {
	return this._info;
    }

    Expression expression () {
	assert (false, "TODO");
    }
    
    override void print (int nb = 0) {}
    
}

