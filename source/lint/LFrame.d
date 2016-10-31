module lint.LFrame;
import lint.LReg, lint.LLabel, lint.LInstList;
import std.container, std.outbuffer, std.math;
import std.conv, std.stdio;

class LFrame {
    
    private ulong _number;
    private static ulong __lastNum__ = 0;
    private string _name;
    private LLabel _entry_lbl;
    private LLabel _return_lbl;
    private Array!LReg _args;
    private LReg _return_reg;
    private int stack = 0;
    private bool _is_main = false;
    private LInstList _inst;

    private static LFrame[ulong] __table__;
    
    this (ulong number, string name) {
	this._name = name;
	this._number = number;
	__table__ [this._number] = this;
	this._inst = new LInstList;
    }

    this (string name, LLabel entry_lbl, LLabel return_lbl, LReg return_reg, Array!LReg args, LInstList inst) {
	this._name = name;
	this._entry_lbl = entry_lbl;
	this._return_reg = return_reg;
	this._return_lbl = return_lbl;
	this._args = args;
	this._inst = inst;
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("%s : (el: %s, rl: %s, rr: %s, pr:",
		    this._name,
		    this._entry_lbl.toString (),
		    this._return_lbl.toString (),
		    to!string (this._return_reg));
	buf.write ("[");
	foreach (it ; this._args) {	    
	    buf.write (it.toString ());
	    if (it != this._args[$ - 1]) buf.write (", ");
	}
	
	buf.writefln ("]) {%s}", this._inst.toString ());
	
	return buf.toString ();
    }
   

}

