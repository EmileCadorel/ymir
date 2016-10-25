module semantic.pack.Table;
import utils.Singleton, semantic.pack.Symbol;
import semantic.pack.FrameScope, semantic.pack.Scope;
import std.container;

class Table {

    private SList!FrameScope _frameTable;
    private Scope _globalScope;
    
    private this () {
	_globalScope = new Scope ();
    }

    void enterBlock () {
	if (!this._frameTable.empty) {
	    this._frameTable.front.enterBlock ();
	}
    }

    void quitBlock () {
	if (!this._frameTable.empty) {
	    this._frameTable.front.quitBlock ();
	}
    }

    void enterFrame (string space) {
	this._frameTable.insertFront (new FrameScope (space));
    }
    
    void quitFrame () {
	if (!this._frameTable.empty) {
	    this._frameTable.removeFront ();
	}
    }

    string namespace() {
	if (this._frameTable.empty) return "";
	else return this._frameTable.front.namespace;
    }

    void insert (Symbol info) {
	if (this._frameTable.empty) {
	    _globalScope [info.sym.str] = info;
	} else {
	    this._frameTable.front.insert (info.sym.str, info);
	}
    }

    Symbol get (string name) {
	if (this._frameTable.empty) return this._globalScope [name];
	auto ret = this._frameTable.front [name];
	if (ret is null) return this._globalScope [name];
	return ret;
    }

    ref FrameReturnInfo retInfo () {
	if (this._frameTable.empty) return FrameReturnInfo.empty;
	else return this._frameTable.front.retInfo ();
    }
    
    mixin Singleton!Table;
}
