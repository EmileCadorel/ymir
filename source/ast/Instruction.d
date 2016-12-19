module ast.Instruction;
import syntax.Word, ast.Block;

class Instruction {

    protected Word _token;
    protected Block _block;
    
    this (Word word) {
	this._token = word;
    }

    Word token () {
	return this._token;
    }

    Block father () {
	return this._block;
    }

    void father (Block father) {
	this._block = father;
    }
    
    Instruction instruction () {
	assert (false, "TODO");
    }
    
    void print (int nb = 0) {}
    
}
