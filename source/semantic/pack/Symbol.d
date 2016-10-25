module semantic.pack.Symbol;
import syntax.Word;
import semantic.types.InfoType;

class Symbol {

    private Word _sym;
    private InfoType _type;
    private bool _isConst;
    
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
    
}
