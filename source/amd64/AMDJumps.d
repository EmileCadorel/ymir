module amd64.AMDJumps;
import target.TInst, std.conv;

class AMDGoto : TInst {
    private ulong _id;
    this (ulong id) {
	this._id = id;
    }

    override string toString () {
	return "\tjmp\tLBL" ~ to!string (this._id);
    }
    
}

class AMDJe : TInst {

    private ulong _id;

    this (ulong id) {
	this._id = id;
    }

    override string toString () {
	return "\tje\tLBL" ~ to!string (this._id);
    }
    
}
