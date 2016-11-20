module ybyte.YBRegRead;
import target.TExp, target.TReg;
import std.outbuffer;

class YBRegRead : TExp {

    private TReg _where;
    private ulong _begin;
    private int _size;
    
    this (TReg where, ulong begin, int size) {
	this._where = where;
	this._begin = begin;
	this._size = size;
    }

    ref TReg where () {
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
