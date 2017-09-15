module ymir.dtarget.DFrame;
import ymir.lint._;
import ymir.dtarget._;
import ymir.semantic._;

import std.container;
import std.outbuffer;

class DFrame : LFrame {

    private string _file;

    private string _name;

    private DBlock _block;

    private Namespace _namespace;    

    private Array!DTypeVar _params;

    private Array!Namespace _imports;
    
    private DType _type;
    
    this (string name) {	
	this._name = name;
    }

    void addVar (DTypeVar var) {
	this._params.insertBack (var);
    }

    ref DType type () {
	return this._type;
    }
    
    ref DBlock block () {
	return this._block;
    }

    ref Array!Namespace imports () {
	return this._imports;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("%s %s (", this._type.toString, this._name);
	foreach (it ; this._params) {
	    buf.writef ("%s%s", it, it is this._params [$ - 1] ? "" : ", ");
	}
	buf.writef (")");
	this._block.nbIndent = 4;
	buf.writef ("%s", this._block.toString);
	return buf.toString ();
    }    
    
}
