module ast.Instruction;
import syntax.Word, lint.tree;

class Instruction {

    Word _token;

    this (Word word) {
	this._token = word;
    }

    Word token () {
	return this._token;
    }
    
    Instruction instruction () {
	assert (false, "TODO");
    }
    
    void print (int nb = 0) {}

    Tree toLint () {
	assert (false, "TODO");
    }
    
}
