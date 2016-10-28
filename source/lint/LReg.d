module lint.LReg;
import lint.LData;

class LReg : LData {
    
    private static ulong __last__ = 0;
    private ulong _id;
    private short _size;
    private string _name;
    private ulong _length;

    this (short size) {
	this._id = __last__;
	__last__ ++;
	this._size = size;
    }

    this (ulong id, short size) {
	this._id = id;
	this._size = size;
    }
    
    static ulong lastId () {
	ulong ret = __last__;
	__last__ ++;
	return ret;
    }

}
