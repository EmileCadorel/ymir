module semantic.pack.Symbol;
import syntax.Word;
import semantic.types.InfoType, semantic.pack.Table;
import std.container, lint.LInstList, lint.LReg;
import std.stdio;

class Symbol {

    private ulong _id;
    private Word _sym;
    private InfoType _type;
    //    private bool _isConst;
    private static SList!ulong __last__;
    
    this (Word word, InfoType type) {
	this._sym = word;
	this._type = type;
	Table.instance.garbage (this);
    }

    this (Word word, InfoType type, bool isConst) {
	this._sym = word;
	this._type = type;
	this._type.isConst = isConst;
	Table.instance.garbage (this);
    }

    this (bool garbage, Word word, InfoType type, bool isConst) {
	this._sym = word;
	this._type = type;
	this._type.isConst = isConst;
    }

    this (bool garbage, Word word, InfoType type) {
	this._sym = word;
	this._type = type;
    }
    
    bool isDestructible () {
	if (this._type !is null) return this._type.isDestructible ();
	return false;
    }

    ref InfoType type () {
	return this._type;
    }

    ref bool isConst () {
	return this._type.isConst;
    }

    void quit (string namespace) {
	this._type.quit (namespace);
    }

    LInstList destruct () {
	if (this._type.destruct !is null) {
	    writeln (this.typeString, " ", this._id);
	    return this._type.destruct (new LInstList (new LReg (this._id, this._type.size)));
	} else return new LInstList ();
    }
    
    string typeString () {
	if (this._type.isConst) {
	    return "const(" ~ this._type.typeString ~ ")";
	} else return this._type.typeString;
	    
    }
    
    ref Word sym () {
	return this._sym;
    }

    static ulong lastId () {
	if (__last__.empty) __last__.insertFront (1);
	return __last__.front();
    }
    
    ref ulong id () {
	return this._id;
    }	

    static void insertLast (ulong nbParam) {
	__last__.insertFront (nbParam + 1);
    }

    static ulong removeLast () {
	if (!__last__.empty) {
	    auto last = __last__.front ();
	    __last__.removeFront ();
	    return last;
	}
	return 0;
    }
    
    void setId () {
	if (__last__.empty) __last__.insertFront (1);
	this._id = __last__.front ();
	__last__.front ()++;
    }
    
}
