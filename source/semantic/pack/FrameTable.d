module semantic.pack.FrameTable;
import utils.Singleton, semantic.pack.Frame;
import std.container;

class FrameTable {

    private Array!PureFrame _pures;
    private Array!FinalFrame _finals;

    void insert (PureFrame frame) {
	this._pures.insertBack (frame);
    }

    void insert (FinalFrame frame) {
	this._finals.insertBack (frame);
    }

    Array!PureFrame pures () {
	return this._pures;
    }

    Array!FinalFrame finals () {
	return this._finals;
    }    
    
    mixin Singleton!FrameTable;    
}

