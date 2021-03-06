module ymir.amd64.AMDStd;
import ymir.target.TInst, std.conv, std.outbuffer;
import ymir.amd64.AMDObj;
import ymir.amd64.AMDSize;

class AMDGlobal : TInst {
    private string _name;

    this (string name) {
	this._name = name;
    }

    override string toString () {
	return "\t.globl\t" ~ this._name;
    }    
}


enum AMDTypes : string {
    FUNCTION = "@function",
	OBJECT = "@object"
}

class AMDType : TInst {
    private AMDTypes _type;
    private string _name;

    this (string name, AMDTypes type) {
	this._type = type;
	this._name = name;
    }

    override string toString () {
	return "\t.type\t" ~ this._name ~ ", " ~ this._type ~ "\n";
    }
}

class AMDCfiStartProc : TInst {
    override string toString () {
	return "\t.cfi_startproc";
    }
}

class AMDPush : TInst {
    private AMDObj _reg;
    
    this (AMDObj reg) {
	this._reg = reg;
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("\tpush%s\t%s", this._reg.sizeAmd.id, this._reg.toString());
	return buf.toString ();
    }
}


class AMDPop : TInst {
    private AMDObj _reg;
    
    this (AMDObj reg) {
	this._reg = reg;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("\tpop%s\t%s", this._reg.sizeAmd.id, this._reg.toString());
	return buf.toString ();
    }
}

class AMDCmp : TInst {
    private AMDObj _left;
    private AMDObj _right;
    
    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	if (this._left.sizeAmd == AMDSize.SPREC ||
	    this._left.sizeAmd == AMDSize.DPREC) {
	    buf.writef ("\tucomi%s\t%s, %s",
			this._left.sizeAmd.id,
			this._left.toString (),
			this._right.toString ());
	} else {
	    buf.writef ("\tcmp%s\t%s, %s",
			this._left.sizeAmd.id,
			this._left.toString (),
			this._right.toString ());
	}
	return buf.toString ();
    }
}

class AMDCfiDefCfaOffset : TInst {
    private ulong _nb;
  
    this (ulong nb) {
	this._nb = nb;
    }

    override string toString () {
	return "\t.cfi_def_cfa_offset\t" ~ to!string (this._nb);
    }
}

class AMDCfiOffset : TInst {
    private ulong _fi, _se;
    this (ulong fi, ulong se) {
	this._fi = fi;
	this._se = se;
    }

    override string toString () {
	return "\t.cfi_offset\t" ~ to!string (this._fi) ~ ", -" ~ to!string (this._se);
    }
}

class AMDCfiDefCfaRegister : TInst {
    private ulong _nb;
    this (ulong nb) {
	this._nb = nb;
    }

    override string toString () {
	return "\t.cfi_def_cfa_register\t" ~ to!string (this._nb);
    }
}

class AMDCfiDefCfa : TInst {
    private ulong _fi, _se;
    this (ulong fi, ulong se) {
	this._fi = fi;
	this._se = se;
    }

    override string toString () {
	return "\t.cfi_def_cfa\t" ~ to!string (this._fi) ~", " ~ to!string (this._se);
    }
    
}

class AMDLeave : TInst {
    override string toString () {
	return "\tleave";
    }
}

class AMDCfiEndProc : TInst {
    override string toString () {
	return "\t.cfi_endproc\t";
    }
}

class AMDInstSize : TInst {
    private string _name;
    private string _size;

    this (string name) {
	this._name = name;
	this._size = null;
    }

    this (string name, string size) {
	this._name = name;
	this._size = size;
    }
    
    override string toString () {
	if (this._size is null)
	    return "\t.size\t" ~ this._name ~ ", .-" ~ this._name ~ "\n";
	else
	    return "\t.size\t" ~ this._name ~ ", " ~ this._size ~ "\n";
    }
}

class AMDRet : TInst {
    override string toString () {
	return "\tret";
    }
}

class AMDCqto : TInst {
    override string toString () {
	return "\tcqto";
    }
}

class AMDAlign : TInst {
    private ulong _nb;
    
    this (ulong nb) {
	this._nb = nb;
    }

    override string toString () {
	return "\t.align\t" ~ to!string (this._nb) ~ "\n";
    }
    
}
