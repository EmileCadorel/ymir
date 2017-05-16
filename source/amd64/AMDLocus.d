module amd64.AMDLocus;
import target.TInst, syntax.Word;
import std.outbuffer, std.path;
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

    static void reset () {
	this.__locusFiles__.clear ();
	this.__last__ = 1;
    }
    
}

class AMDLocus : TInst {
    
    private Location _loc;
    private ulong _id;

    this (Location locus) {
	this._loc = locus;
	if (this._loc.file != "" && this._loc.file.extension == ".yr") 
	    this._id = AMDFile.__locusFiles__ [locus.file];
    }

    Location loc () {
	return this._loc;
    }
    
    override string toString () {
	if (Options.instance.isOn (OptionEnum.DEBUG) && this._loc.file != "") {
	    auto buf = new OutBuffer ();
	    buf.writef ("\t.loc\t%d %d %d", this._id, this._loc.line, 0);
	    return buf.toString ();
	}
	return "";
    }
    
    
}
