module target.TJump;
import target.TInst, target.TExp;
import std.conv;

class TJump : TInst {

    private TExp _test;
    private ulong _id;

    this (TExp test, ulong id) {
	this._test = test;
	this._id = id;
    }

    override string toString () {
	return "\tif\t" ~ this._test.toString () ~ " " ~ to!string (this._id) ~ "\n";
    }
    
}
