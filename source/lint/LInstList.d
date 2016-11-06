module lint.LInstList;
import lint.LInst, lint.LExp;
import std.container, std.outbuffer;

class LInstList {
    
    private Array!LInst _inst;

    this () {}
    
    this (LInst inst) {
	this._inst.insertBack (inst);
    }
    
    this (Array!LInst inst) {
	this._inst = inst;
    }

    this (LInstList other) {
	this._inst = other._inst;
    }

    ulong length () {
	return this._inst.length;
    }
    
    LExp getFirst () {
	if (!this._inst.empty) {
	    return this._inst.back ().getFirst ();
	} else return null;
    }
    
    LInstList opBinary(string op : "+") (LInstList other) {
	Array!LInst ret;
	foreach (it; this._inst) ret.insertBack (it);	
	foreach (it ; other._inst) ret.insertBack (it);	    	
	return new LInstList (ret);
    }

    LInstList opOpAssign(string op : "+")(LInst other) {
	this._inst.insertBack (other);
	return this;
    }
    
    LInstList opOpAssign(string op : "+")(LInstList other) {
	foreach (it ; other._inst) {
	    this._inst.insertBack (it);		
	}
	return this;
    }
    
    LInstList clean () {
	Array!LInst aux;
	foreach (it ; this._inst)
	    if (cast(LExp)it is null)
		aux.insertBack (it);
	this._inst = aux;
	return this;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer ();
	if (!this._inst.empty) buf.write ("\n");
	foreach (it ; this._inst) {
	    buf.writef ("\t%s", it.toString());
	}
	return buf.toString ();
    }
    
}
