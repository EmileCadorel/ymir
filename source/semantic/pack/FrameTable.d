module semantic.pack.FrameTable;
import utils.Singleton, semantic.pack.Frame;
import std.container, std.algorithm;

class FrameTable {

    private Array!PureFrame _pures;
    private Array!FinalFrame _finals;

    void insert (PureFrame frame) {
	this._pures.insertBack (frame);
    }

    void insert (FinalFrame frame) {
	this._finals.insertBack (frame);
    }

    FinalFrame existFinal (string name) {
	foreach (it ; _finals) {
	    if (it.name == name) return it;
	}
	return null;
    }
    
    Array!PureFrame pures () {
	return this._pures;
    }

    Array!FinalFrame finals () {
	return this._finals;
    }    
    
    mixin Singleton!FrameTable;    
}

