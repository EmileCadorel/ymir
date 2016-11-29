module amd64.AMDSet;
import std.typecons, amd64.AMDReg;
import target.TInst, amd64.AMDObj;
import std.outbuffer;

alias SET = Tuple!(string, "descr");

enum AMDSetType : SET {
    LOWER = SET ("l"),
    GREATER = SET ("g"),
    EQUALS = SET ("e"),
    NOT_EQ = SET ("ne"),
    LOWER_E = SET ("le"),
    GREATER_E = SET ("ge")
}

class AMDSet : TInst {

    AMDObj _where;
    AMDSetType _type;

    this (AMDObj reg, AMDSetType type) {
	this._where = reg;
	this._type = type;
    }

    static AMDSetType Inv (AMDSetType type) {	
	if (type == AMDSetType.LOWER) return AMDSetType.GREATER;
	else if (type == AMDSetType.GREATER) return AMDSetType.LOWER;
	else if (type == AMDSetType.NOT_EQ) return AMDSetType.NOT_EQ;
	else if (type == AMDSetType.EQUALS) return AMDSetType.EQUALS;
	else if (type == AMDSetType.LOWER_E) return AMDSetType.GREATER_E;
	else if (type == AMDSetType.GREATER_E) return AMDSetType.LOWER_E;
	else assert (false);	
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\tset%s\t%s",
		    this._type.descr,
		    this._where.toString ());
	return buf.toString ();
    }
    
}
