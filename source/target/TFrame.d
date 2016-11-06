module target.TFrame;
import target.TLabel, std.container, target.TReg;
import std.outbuffer;

class TFrame {

    private ulong _id;
    private string _name;
    private TLabel _entryLbl;
    private TLabel _returnLbl;
    private Array!TReg _paramRegs;
    private TReg _returnReg;

    this (ulong id, string name) {
	this._id = id;
	this._name = name;
    }

    ref TLabel entryLbl () {
	return this._entryLbl;
    }

    ref TLabel returnLbl () {
	return this._returnLbl;
    }

    ref Array!TReg paramRegs () {
	return this._paramRegs;
    }
    
    ref TReg returnReg () {
	return this._returnReg;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("#%s(", this._name);
	foreach (it ; this._paramRegs) {
	    buf.writef ("%s", it.toString ());
	    if (it !is this._paramRegs [$ - 1])
		buf.write (", ");	    
	}
	buf.write (")");
	if (this._returnReg !is null) 
	    buf.writef (": %s",
			  this._returnReg.toString ());
	
	buf.writefln (" {\n%s\n%s\n}",
		      this._entryLbl.toString (),
		      this._returnLbl.toString ());
	
	return buf.toString ();
    }
    
}

