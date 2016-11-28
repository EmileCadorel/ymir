module amd64.AMDFrame;
import target.TFrame, amd64.AMDConst, target.TInstList;
import amd64.AMDLabel, std.outbuffer;

class AMDFrame : TFrame {

    private AMDConstQWord _size;
    private TInstList _inst;
    
    this (AMDConstQWord size, TInstList inst) {
	this._size = size;
	this._inst = inst;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; this._inst.inst) {
	    buf.writef("%s\n", it.toString ());
	}
	return buf.toString ();
    }
    

}