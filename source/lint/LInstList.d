module lint.LInstList;
import lint.LInst, lint.LExp, lint.LLabel, lint.LLocus;
import std.container, std.outbuffer;
import lint.LGoto, lint.LJump;

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

    ref Array!LInst insts () {
	return this._inst;
    }

    LInst back () {
	return this._inst.back ();
    }
    
    LExp getFirst () {
	if (!this._inst.empty) {
	    auto ret = this._inst.back ().getFirst ();
	    if (cast (LExp) this._inst.back ()) 
		this._inst.removeBack ();
	    return ret;
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

    LInstList replace (string labelName, LInstList list) {
	Array!LInst ret;
	foreach (it ; this._inst) {
	    if (auto _l = cast (LLabel) it) {
		if (_l.name == labelName) {
		    foreach (__it__; list._inst) ret.insertBack (__it__);
		} else {
		    if (_l.insts)
			_l.insts = _l.insts.replace (labelName, list);
		    ret.insertBack (_l);
		}
	    } else ret.insertBack (it);
	}
	return new LInstList (ret);
    }
    
    LInstList clean () {
	LInstList aux = new LInstList;
	bool findLabel = true;
	foreach (it ; this._inst) {
	    auto exp = cast(LExp) it;
	    if (auto ll = cast (LLabel) it) {
		findLabel = true;
		auto insts = ll.clean ();
		aux._inst.insertBack (ll);
		if (insts)
		    aux += insts;
	    } else if (auto lg = cast (LGoto) it) {
		if (findLabel) {
		    aux += lg;
		    findLabel = false;
		}
	    } else if (exp is null || exp.isInst())
		aux += (it);
	}
	this._inst = aux._inst;
	return this;
    }

    override string toString () {
	import std.string;
	OutBuffer buf = new OutBuffer ();
	if (!this._inst.empty) buf.write ("\n");
	foreach (it ; this._inst) {
	    if (cast (LLabel) it is null && cast (LLocus) it is null)
		buf.writefln ("\t%s", it.toString());
	    else if (cast (LLabel) it)
		buf.writefln ("%s", it.toString());
	}
	return buf.toString ();
    }
    
}
