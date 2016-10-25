module lint.FunctionTree;
import lint.tree, lint.BlockTree, lint.VarTree;
import std.outbuffer, std.container;

class FunctionTree : Tree {

    private BlockTree _block;
    private string _type;
    private string _name;
    private Array!VarTree _vars;
    
    ref string type () {
	return this._type;
    }

    ref string name () {
	return this._name;
    }
    
    void addParam (Tree var) {
	this._vars.insertBack (cast(VarTree)var);
    }

    void setBlock (Tree block) {
	this._block = cast(BlockTree)block;
    }
    
    override void toC (ref OutBuffer buf) {
	buf.writef ("%s %s (", this._type, this._name);
	foreach (it ; 0 .. this._vars.length) {
	    this._vars [it].toC (buf);
	    if (it < this._vars.length - 1) {
		buf.write (",");
	    }
	}
	buf.writefln (") ");
	this._block.toC (buf);
    }

}
