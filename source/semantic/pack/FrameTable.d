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

    const (Array!PureFrame) pures () {
	return this._pures;
    }

    const (Array!FinalFrame) finals () {
	return this._finals;
    }    
    
    mixin Singleton!FrameTable;    
}

