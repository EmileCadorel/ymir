module amd64.AMDLocus;
import target.TInst, syntax.Word;
import std.outbuffer;
import utils.Options;

class AMDFile : TInst {

    static ulong [string] __locusFiles__;
    private static ulong __last__ = 1;
    private ulong _id;
    private string _file;
    private bool _needed = true;
    
    this (string file) {
	auto it = (file in __locusFiles__);
	if (it !is null) this._needed = false;
	else {
	    this._id = __last__;
	    __last__ ++;
	    __locusFiles__ [file] = this._id;
	}
	this._file = file;
    }

    override string toString () {
	if (Options.instance.isOn (OptionEnum.DEBUG)) {
	    if (this._needed) {
		auto buf = new OutBuffer ();
		buf.writef ("\t.file\t%d \"%s\"\n", this._id, this._file);
		return buf.toString ();
	    }
	}
	return "";
    }
    
}

class AMDLocus : TInst {
    
    private Location _loc;
    private ulong _id;

    this (Location locus) {
	this._loc = locus;
	this._id = AMDFile.__locusFiles__ [locus.file];
    }

    override string toString () {
	if (Options.instance.isOn (OptionEnum.DEBUG)) {
	    auto buf = new OutBuffer ();
	    buf.writef ("\t.loc\t%d %d %d", this._id, this._loc.line, 0);
	    return buf.toString ();
	}
	return "";
    }
    
    
}
