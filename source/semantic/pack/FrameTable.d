module semantic.pack.FrameTable;
import utils.Singleton, semantic.pack.Frame;
import std.container, std.algorithm;

class FrameTable {

    private Array!PureFrame _pures;
    private Array!FinalFrame _finals;
    private Array!FrameProto _protos;

    void insert (PureFrame frame) {
	this._pures.insertBack (frame);
    }

    void insert (FinalFrame frame) {
	this._finals.insertBack (frame);
    }

    void insert (FrameProto proto) {
	this._protos.insertBack (proto);
    }    
    
    FinalFrame existFinal (string name) {
	foreach (it ; _finals) {
	    if (it.name == name) return it;
	}
	return null;
    }
    
    FrameProto existProto (string name) {
	foreach (it ; _protos) {
	    if (it.name == name) return it;
	}
	return null;
    }
    
    ref Array!PureFrame pures () {
	return this._pures;
    }

    ref Array!FinalFrame finals () {
	return this._finals;
    }    
    
    mixin Singleton!FrameTable;    
}

