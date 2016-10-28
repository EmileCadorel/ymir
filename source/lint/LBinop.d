module lint.LBinop;
import lint.LExp;
import semantic.types.InfoType, syntax.Tokens;
import std.outbuffer, std.string;

class LBinop : LExp {

    private LExp _left, _right;
    private Token _op;
    private InfoType _type;
    private ushort _size;
    
    this (LExp left, LExp right, Token op, InfoType type, ushort size) {
	this._left = left;
	this._right = right;
	this._op = op;
	this._type = type;
	this._size = size;
    }
}
