module ybyte.YBCall;
import target.TExp, target.TInst;

class YBCall : TInst {

    private string _name;

    this (string name) {
	this._name = name;
    }
    
    override string toString () {
	return "\tcall\t" ~ this._name ~ "\n";
    }
    
}
