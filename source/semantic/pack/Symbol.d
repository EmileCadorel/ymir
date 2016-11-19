module semantic.pack.Symbol;
import syntax.Word;
import semantic.types.InfoType;
import std.container;

class Symbol {

    private ulong _id;
    private Word _sym;
    private InfoType _type;
    private bool _isConst;
    private static SList!ulong __last__;
    
    this (Word word, InfoType type) {
	this._sym = word;
	this._type = type;
    }

    this (Word word, InfoType type, bool isConst) {
	this._sym = word;
	this._type = type;
	this._isConst = isConst;
    }
    
    ref InfoType type () {
	return this._type;
    }

    ref bool isConst () {
	return this._isConst;
    }

    string typeString () {
	if (this._isConst) {
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

    static void insertLast () {
	__last__.insertFront (1);
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
