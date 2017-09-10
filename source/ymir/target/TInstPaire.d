module ymir.target.TInstPaire;
import ymir.target._;


class TInstPaire {

    private TExp _where;
    private TInstList _what;

    this (TExp where, TInstList what) {
	this._where = where;
	this._what = what;
    }
    
    ref TInstList what () {
	return this._what;
    }

    ref TExp where () {
	return this._where;
    }
    
    
}
