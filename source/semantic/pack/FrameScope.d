module semantic.pack.FrameScope;
import semantic.pack.Scope, semantic.pack.Symbol;
import semantic.types.InfoType;
import std.container, std.outbuffer, std.string;


struct FrameReturnInfo {
    Symbol info;        

    static ref FrameReturnInfo empty () {
	return _empty;
    }
    
    bool has (string elem) {
	return false;
    }

    static FrameReturnInfo _empty;
}


class FrameScope {


    private FrameReturnInfo _retInfo;
    private SList!Scope _local;
    private string _namespace;

    this (string namespace) {
	this._namespace = namespace;
	this.enterBlock ();
    }

    ~this () {
	this.quitBlock ();
    }
    
    void enterBlock () {
	this._local.insertFront (new Scope ());
    }

    Array!Symbol quitBlock () {
	if (!this._local.empty) {
	    auto ret = this._local.front ().quit (this._namespace);
	    this._local.removeFront ();
	    return ret;
	}
	return make!(Array!Symbol);
    }

    void insert (string name, Symbol info) {
	this._local.front [name] = info;
    }

    void garbage (Symbol info) {
	this._local.front.garbage (info);
    }
    
    Symbol opIndex (string name) {
	foreach (it ; this._local) {
	    auto t = it [name];
	    if (t !is null) return t;
	}
	return null;
    }

    ref string namespace () {
	return this._namespace;
    }
    
    ref FrameReturnInfo retInfo () {
	return this._retInfo;
    }
    
}
