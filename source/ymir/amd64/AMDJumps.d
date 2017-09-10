module ymir.amd64.AMDJumps;
import ymir.target.TInst, std.conv;

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


class AMDJne : TInst {

    private ulong _id;

    this (ulong id) {
	this._id = id;
    }

    override string toString () {
	return "\tjne\tLBL" ~ to!string (this._id);
    }
    
}

