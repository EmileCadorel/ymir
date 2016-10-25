module ast.Expression;
import ast.Instruction;
import syntax.Word, semantic.pack.Symbol;
import lint.tree;

class Expression : Instruction {

    protected Symbol _info;
    
    this (Word word) {
	super (word);
    }

    ref Symbol info () {
	return this._info;
    }

    override final Instruction instruction () {
	return this.expression ();
    }
    
    Expression expression () {
	assert (false, "TODO");
    }
    
    override void print (int nb = 0) {}
    
    override Tree toLint () {
	assert (false, "TODO");
    }
    
}

