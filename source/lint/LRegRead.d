module lint.LRegRead;
import lint.LExp, lint.LReg, lint.LSize;
import lint.LConst;
import std.outbuffer, std.conv;

class LRegRead : LExp {

    private LExp _data;
    private LExp _beginStatic;
    private LSize _size;

    this (LExp reg) {
	this._data = reg;
	this._beginStatic = new LConstDWord (0);
	this._size = reg.size;
    }
    
    this (LExp str, LExp begin, LSize size) {
	this._data = str;
	this._beginStatic = begin;
	this._size = size;
    }
    
    ref LExp data () {
	return this._data;
    }

    ref LExp begin () {
	return this._beginStatic;
    }
    
    override LSize size () {
	return this._size;
    }

    override bool isInst () {
	return false;
    }
    
    override string toString () {
	return '{' ~ this._data.toString () ~ "}["
	    ~ this._beginStatic.toString () ~ ":" ~ this._size.value ~ "]";
    }
    
}
