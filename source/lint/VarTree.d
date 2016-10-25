module lint.VarTree;
import std.outbuffer, lint.tree;

class VarTree : Tree {

    private string _name;
    private string _type;
    private bool _isStruct;
    
    ref string type () {
	return this._type;
    }

    ref string name () {
	return this._name;
    }

    ref bool isStruct () {
	return this._isStruct;
    }

    override void toC (ref OutBuffer buf) {
	if (!this._isStruct) 
	    buf.writef ("%s %s", this._type, this._name);
	else
	    buf.writef ("struct %s %s", this._type, this._name);
    }
    
}
