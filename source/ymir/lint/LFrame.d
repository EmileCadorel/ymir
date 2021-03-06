module ymir.lint.LFrame;
import ymir.lint._;

import std.container, std.outbuffer, std.math;
import std.conv, std.stdio;

class LFrame {

    private string _file;
    private static LFrame [string] __preCompiled__;
    private ulong _number;
    private static ulong __lastNum__ = 0;
    private string _name;
    private string _unmangled;
    private LLabel _entry_lbl;
    private LLabel _return_lbl;
    private Array!LReg _args;
    private LReg _return_reg;
    private int stack = 0;
    private bool _is_main = false;
    private ulong _lastId;
    private bool _std = true;

    
    static LFrame[ulong] __table__;

    protected this () {}
    
    this (ulong number, string name, string unmangle) {
	this._name = name;
	this._number = number;
	__table__ [this._number] = this;
	this._unmangled = unmangle;
    }

    this (string name, string unmangle, LLabel entry_lbl, LLabel return_lbl, LReg return_reg, Array!LReg args) {
	this._name = name;
	this._entry_lbl = entry_lbl;
	this._return_reg = return_reg;
	this._return_lbl = return_lbl;
	this._args = args;
	this._unmangled = unmangle;
    }

    this (string name, LLabel entry_lbl, LLabel return_lbl, LReg return_reg, Array!LReg args) {
	this._name = name;
	this._entry_lbl = entry_lbl;
	this._return_reg = return_reg;
	this._return_lbl = return_lbl;
	this._args = args;
    }
    
    static ref LFrame [string] preCompiled () {
	return __preCompiled__;
    }

    ref bool isStd () {
	return this._std;
    }
    
    ref string file () {
	return this._file;
    }
    
    ulong number () {
	return this._number;
    }

    ref ulong lastId () {
	return this._lastId;
    }
    
    string name () {
	return this._name;
    }
    
    LLabel entryLbl () {
	return this._entry_lbl;
    }

    LLabel returnLbl () {
	return this._return_lbl;
    }

    Array!LReg args () {
	return this._args;
    }
    
    LReg returnReg () {
	return this._return_reg;
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer ();
	if (this._unmangled != "")  buf.writef ("%s => ", this._unmangled);
	
	buf.writef ("%s: (rr: %s, pr:", this._name, to!string (this._return_reg));
	buf.write ("[");
	
	foreach (it ; this._args) {	    
	    buf.write (it.toString ());
	    if (it != this._args[$ - 1]) buf.write (", ");
	}
	
	buf.writefln ("]) {\n%s%s\n}",
		      this._entry_lbl.toString (),
		      this._return_lbl.toString ());
	
	return buf.toString ();
    }
   

}

