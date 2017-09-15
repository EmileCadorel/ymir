module ymir.dtarget.DBreak;
import ymir.dtarget._;

import std.format;

class DBreak : DInstruction {

    private string _name;
    
    this (string name = null) {
	this._name = name;
    }
    
    override string toString () {
	if (this._name)
	    return format ("break %s;", this._name);
	else return "break;";
    }
    

    
}
