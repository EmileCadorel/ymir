module semantic.pack.Symbol;
import syntax.Word;
import semantic.types.InfoType;

class Symbol {

    private Word _sym;
    private InfoType _type;

    this (Word word, InfoType type) {
	this._sym = word;
	this._type = type;
    }

    ref InfoType type () {
	return this._type;
    }

    ref Word sym () {
	return this._sym;
    }
    
}
