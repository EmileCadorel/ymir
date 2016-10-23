module semantic.pack.Frame;
import ast.Function;
import std.stdio;

class PureFrame {

    private string _name;
    private string _namespace;
    private Function _function;
    
    this (string namespace, Function func) {
	this._name = func.ident.str;
	this._namespace = namespace;
	this._function = func;
    }

    void validate () const {
	writefln ("On est la, %s", this._name);
    }    
    
}

class FinalFrame {
}
