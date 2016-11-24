module ybyte.YBRegRead;
import target.TExp, target.TReg;
import std.outbuffer;

class YBRegRead : TExp {

    private TExp _where;
    private ulong _begin;
    private int _size;
    
    this (TExp where, ulong begin, int size) {
	this._where = where;
	this._begin = begin;
	this._size = size;
    }

    ref TExp where () {
	return this._where;
    }

    ref ulong begin () {
	return this._begin;
    }

    override int size () {
	return this._size;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("%d(%s)",
		    this._begin,
		    this._where.toString ());
	return buf.toString ();
    }
       
}
