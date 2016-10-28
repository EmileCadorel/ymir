module ast.Instruction;
import syntax.Word;

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
    
}
