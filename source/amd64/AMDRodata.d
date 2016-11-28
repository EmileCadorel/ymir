module amd64.AMDRodata;
import target.TRodata, std.outbuffer;
import target.TInstList, utils.Singleton;

class AMDRodata : TRodata {
    
    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; __insts__.inst) {
	    buf.writefln ("%s", it.toString ());
	}
	return buf.toString ();
    }
    
}
