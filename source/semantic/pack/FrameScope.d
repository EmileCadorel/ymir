module semantic.pack.FrameScope;
import semantic.pack.Scope, semantic.pack.Symbol;
import semantic.types.InfoType;
import std.container, std.outbuffer, std.string;


struct FrameReturnInfo {
    Symbol info;        

    static FrameReturnInfo empty () {
	return _empty;
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

    void quitBlock () {
	if (!this._local.empty)
	    this._local.removeFront ();
    }

    void insert (string name, Symbol info) {
	this._local.front [name] = info;
    }

    Symbol opIndex (string name) {
	foreach (it ; this._local) {
	    auto t = it [name];
	    if (t !is null) return t;
	}
	return null;
    }

    string namespace () const {
	return this._namespace;
    }
    
    ref FrameReturnInfo retInfo () {
	return this._retInfo;
    }
    
}
