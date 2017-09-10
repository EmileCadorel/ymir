module ymir.target.TReg;
import std.conv, ymir.target.TExp;

class TReg : TExp {
    private static ulong __last__;

    
    static ulong lastId () {
	ulong ret = __last__;
	__last__ ++;
	return ret;
    }
    
    static void lastId (ulong last) {
	__last__ = last;
    }

}
