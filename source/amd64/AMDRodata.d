module amd64.AMDRodata;
import target.TRodata, std.outbuffer;
import target.TInstList, utils.Singleton;
import std.algorithm;


class AMDData : TData {

    static bool exists (string name) {
	return find(__totals__, name) != [];
    }

    static void add (string name) {
	__totals__ ~= [name];
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; __insts__.inst) {
	    buf.writefln ("%s", it.toString ());
	}
	return buf.toString ();
    }

    private static string [] __totals__;

}

class AMDRodata : TRodata { 

    static bool exists (string name) {
	return find(__totals__, name) != [];
    }

    static void add (string name) {
	__totals__ ~= [name];
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; __insts__.inst) {
	    buf.writefln ("%s", it.toString ());
	}
	return buf.toString ();
    }

    private static string [] __totals__;
   
}
