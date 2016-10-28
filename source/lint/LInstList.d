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
	    inst.insertBack (it);		
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

}
