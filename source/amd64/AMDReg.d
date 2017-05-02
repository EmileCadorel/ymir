module amd64.AMDReg;
import amd64.AMDSize, std.typecons;
import utils.Singleton, std.container, amd64.AMDObj;
import std.conv, std.outbuffer;
import std.math;

alias R = Tuple!(AMDSize, "size", string, "name");

class AMDRegInfo {
    
    private R [] _subs;
    private AMDReg _reg;
    private string _name;

    this (string name, R [] subs) {
	this._name = name;
	this._subs = subs;
    }

    this (AMDReg reg) {
	this._reg = reg;
    }

    string name () {
	return this._subs [0].name;
    }
    
    R* opBinaryRight (string op : "in") (AMDSize size) {
	foreach (ref it ; this._subs) {
	    if (it.size == size) return &it;
	}
	return null;
    }
    
    bool opBinaryRight (string op : "in") (string name) {
	foreach (value ; this._subs) {
	    if (value.name == name) return true;
	}
	return false;
    }
    
    override bool opEquals (T : Object) (T other) {
	if (name is null) return reg == other;
	else {
	    if (other is null) return false;
	    else if (other.name == name) return true;
	}
	return false;
    }
    
    static R empty (AMDSize size) {
	return R (size, null);
    }	
}

alias REG = AMDRegTable.instance;


class AMDRegTable {

    private static AMDRegInfo [string] __table__;
    private static bool [string] __free__;
    private static AMDRegInfo [] __params__;
    private static Array!AMDRegInfo __paramsFloat__;
    private static Array!AMDRegInfo __aux__;
    private static Array!AMDRegInfo __auxFloat__;
    
    static this () {
	__table__ = ["rax" : new AMDRegInfo ("rax", [R(AMDSize.QWORD, "rax"), R(AMDSize.DWORD, "eax"), R(AMDSize.WORD, "ax"), R(AMDSize.BYTE, "al"), R(AMDSize.BYTE, "ah")]),
		     "rbx" : new AMDRegInfo ("rbx", [R(AMDSize.QWORD, "rbx"), R(AMDSize.DWORD, "ebx"), R(AMDSize.WORD, "bx"), R(AMDSize.BYTE, "bl"), R(AMDSize.BYTE, "bh")]),
		     "rcx" : new AMDRegInfo ("rcx", [R(AMDSize.QWORD, "rcx"), R(AMDSize.DWORD, "ecx"), R(AMDSize.WORD, "cx"), R(AMDSize.BYTE, "cl"), R(AMDSize.BYTE, "ch")]),
		     "rdx" : new AMDRegInfo ("rdx", [R(AMDSize.QWORD, "rdx"), R(AMDSize.DWORD, "edx"), R(AMDSize.WORD, "dx"), R(AMDSize.BYTE, "dl"), R(AMDSize.BYTE, "dh")]),
		     "rsi" : new AMDRegInfo ("rsi", [R(AMDSize.QWORD, "rsi"), R(AMDSize.DWORD, "esi"), R(AMDSize.WORD, "si"), R(AMDSize.BYTE, "sil")]),
		     "rdi" : new AMDRegInfo ("rdi", [R(AMDSize.QWORD, "rdi"), R(AMDSize.DWORD, "edi"), R(AMDSize.WORD, "di"), R(AMDSize.BYTE, "dil")]),
		     "rbp" : new AMDRegInfo ("rbp", [R(AMDSize.QWORD, "rbp"), R(AMDSize.DWORD, "ebp"), R(AMDSize.WORD, "bp"), R(AMDSize.BYTE, "bpl")]),
		     "rsp" : new AMDRegInfo ("rsp", [R(AMDSize.QWORD, "rsp"), R(AMDSize.DWORD, "esp"), R(AMDSize.WORD, "sp"), R(AMDSize.BYTE, "spl")]),
		     "rsp" : new AMDRegInfo ("rsp", [R(AMDSize.QWORD, "rsp"), R(AMDSize.DWORD, "esp"), R(AMDSize.WORD, "sp"), R(AMDSize.BYTE, "spl")]),
		     "r8" : new AMDRegInfo ("r8", [R(AMDSize.QWORD, "r8"), R(AMDSize.DWORD, "r8d"), R(AMDSize.WORD, "r8w"), R(AMDSize.BYTE, "r8b")]),
		     "r9" : new AMDRegInfo ("r9", [R(AMDSize.QWORD, "r9"), R(AMDSize.DWORD, "r9d"), R(AMDSize.WORD, "r9w"), R(AMDSize.BYTE, "r9b")]),
		     "r10" : new AMDRegInfo ("r10", [R(AMDSize.QWORD, "r10"), R(AMDSize.DWORD, "r10d"), R(AMDSize.WORD, "r10w"), R(AMDSize.BYTE, "r10b")]),
		     "r11" : new AMDRegInfo ("r11", [R(AMDSize.QWORD, "r11"), R(AMDSize.DWORD, "r11d"), R(AMDSize.WORD, "r11w"), R(AMDSize.BYTE, "r11b")]),
		     "r12" : new AMDRegInfo ("r12", [R(AMDSize.QWORD, "r12"), R(AMDSize.DWORD, "r12d"), R(AMDSize.WORD, "r12w"), R(AMDSize.BYTE, "r12b")]),
		     "r13" : new AMDRegInfo ("r13", [R(AMDSize.QWORD, "r13"), R(AMDSize.DWORD, "r13d"), R(AMDSize.WORD, "r13w"), R(AMDSize.BYTE, "r13b")]),
		     "r14" : new AMDRegInfo ("r14", [R(AMDSize.QWORD, "r14"), R(AMDSize.DWORD, "r14d"), R(AMDSize.WORD, "r14w"), R(AMDSize.BYTE, "r14b")]),
		     "r15" : new AMDRegInfo ("r15", [R(AMDSize.QWORD, "r15"), R(AMDSize.DWORD, "r15d"), R(AMDSize.WORD, "r15w"), R(AMDSize.BYTE, "r15b")]),
		     "rip" : new AMDRegInfo ("rip", [R(AMDSize.QWORD, "rip")]),
		     "xmm0" : new AMDRegInfo ("xmm0", [R(AMDSize.DPREC, "xmm0"), R(AMDSize.SPREC, "xmm0")]),
		     "xmm1" : new AMDRegInfo ("xmm1", [R(AMDSize.DPREC, "xmm1"), R(AMDSize.SPREC, "xmm1")]),
		     "xmm2" : new AMDRegInfo ("xmm2", [R(AMDSize.DPREC, "xmm2"), R(AMDSize.SPREC, "xmm2")]),
		     "xmm3" : new AMDRegInfo ("xmm3", [R(AMDSize.DPREC, "xmm3"), R(AMDSize.SPREC, "xmm3")]),
		     "xmm4" : new AMDRegInfo ("xmm4", [R(AMDSize.DPREC, "xmm4"), R(AMDSize.SPREC, "xmm4")]),
		     "xmm5" : new AMDRegInfo ("xmm5", [R(AMDSize.DPREC, "xmm5"), R(AMDSize.SPREC, "xmm5")]),
		     "xmm6" : new AMDRegInfo ("xmm6", [R(AMDSize.DPREC, "xmm6"), R(AMDSize.SPREC, "xmm6")]),
		     "xmm7" : new AMDRegInfo ("xmm7", [R(AMDSize.DPREC, "xmm7"), R(AMDSize.SPREC, "xmm7")]),
		     ];

	__params__ = [__table__ ["rdi"],
		      __table__ ["rsi"],
		      __table__ ["rdx"],
		      __table__ ["rcx"],
		      __table__ ["r8"],
		      __table__ ["r9"]];

	
	__aux__.insertBack (__table__["rbx"]);
	__aux__.insertBack (__table__["rcx"]);
	__aux__.insertBack (__table__["r8"]);
	__aux__.insertBack (__table__["r9"]);
	__aux__.insertBack (__table__["r10"]);
	__aux__.insertBack (__table__["r11"]);
	__aux__.insertBack (__table__["r13"]);
	__aux__.insertBack (__table__["r12"]);
	__aux__.insertBack (__table__["r15"]);

	__auxFloat__.insertBack (__table__ ["xmm1"]);
	__auxFloat__.insertBack (__table__ ["xmm2"]);
	__auxFloat__.insertBack (__table__ ["xmm3"]);
	__auxFloat__.insertBack (__table__ ["xmm4"]);
	__auxFloat__.insertBack (__table__ ["xmm5"]);
	__auxFloat__.insertBack (__table__ ["xmm6"]);
	__auxFloat__.insertBack (__table__ ["xmm7"]);


	__paramsFloat__.insertBack (__table__ ["xmm0"]);
	__paramsFloat__.insertBack (__table__ ["xmm1"]);
	__paramsFloat__.insertBack (__table__ ["xmm2"]);
	__paramsFloat__.insertBack (__table__ ["xmm3"]);
	__paramsFloat__.insertBack (__table__ ["xmm4"]);
	__paramsFloat__.insertBack (__table__ ["xmm5"]);
	__paramsFloat__.insertBack (__table__ ["xmm6"]);
	__paramsFloat__.insertBack (__table__ ["xmm7"]);

	// r13 registre d'adresse
	// r14 registre de swap entier
	// xmm0 registre de swap flottant
    }

    static R getReg (string name, AMDSize size = AMDSize.QWORD) {
	if (name == "rbp" && size == AMDSize.BYTE) assert (false);
	auto elem = (name in __table__);
	if (elem is null) {
	    foreach (key, value ; __table__) {
		if (name in value) {
		    auto reg = (signedOne (size) in value);
		    if (reg is null) assert (false, "Pas de registre " ~ name ~ " de taille " ~ to!string (size));
		    return *reg;
		}
	    }
	    assert (false, "Pas de registre " ~ name);
	}
	else {
	    if (elem.name.length == 4 && elem.name[0 .. 3] == "xmm") {
		auto reg = (AMDSize.DPREC in *elem);
		return *reg;
	    }
	    auto reg = (signedOne (size) in *elem);
	    if (reg is null) assert (false, "Pas de registre " ~ name);
	    return *reg;
	}
    }
       
    static R param (ref ulong nbInt, ref ulong nbFloat, AMDSize size = AMDSize.QWORD) {
	if (size == AMDSize.SPREC || size == AMDSize.DPREC) {
	    if (nbFloat < __paramsFloat__.length) {
		auto reg = (size in (__paramsFloat__ [nbFloat]));
		nbFloat ++;
		if (reg is null) assert (false);
		return *reg;
	    } return AMDRegInfo.empty (size);
	} else {
	    if (nbInt < __params__.length) {
		auto reg = (signedOne (size) in (__params__ [nbInt]));
		nbInt++;
		if (reg is null) assert (false);
		return *reg;
	    } return AMDRegInfo.empty (size);
	}
    }

    static R getSwap (AMDSize size = AMDSize.QWORD) {
	if (size == AMDSize.SPREC || size == AMDSize.DPREC) {
	    auto elem = (signedOne (size) in __table__ ["xmm0"]);
	    if (elem !is null) return *elem;
	    else assert (false);
	} else {
	    auto elem = (signedOne (size) in __table__ ["r14"]);
	    if (elem !is null) return *elem;
	    else assert (false);
	}
    }
    
    static R aux (AMDSize size = AMDSize.QWORD) {
	if (size == AMDSize.SPREC || size == AMDSize.DPREC) {
	    foreach (reg ; __auxFloat__) {
		auto inside = (reg.name in __free__);
		if (inside is null || * inside) {
		    __free__ [reg.name] = false;
		    auto it = (signedOne (size) in reg);
		    if (it is null) assert (false, "Taille inconny pour " ~ reg.name ~ " " ~ to!string (size));
		    return *it;
		}
	    }
	} else {
	    foreach (reg ; __aux__) {
		auto inside = (reg.name in __free__);	    
		if (inside is null || *inside) {
		    __free__ [reg.name] = false;
		    auto it = (signedOne (size) in reg);
		    if (it is null) assert (false, "Taille inconnu pour " ~ reg.name ~ " " ~ to!string(size));
		    return *it;
		}
	    }
	}
	return AMDRegInfo.empty (size);
    }

    static AMDRegInfo getInfo (string name) {
	foreach (it ; __table__) {
	    if (name in it) return it;
	}
	assert (false, "Pas un registre " ~ name);
    }
    
    static R getRet (AMDSize size) {
	if (size == AMDSize.SPREC || size == AMDSize.DPREC) {
	    auto reg = __table__ ["xmm0"];	    
	    auto it = (size in reg);
	    if (it is null)
		assert (false, "Taille inconnu pour " ~ reg.name ~ " " ~ to!string(size));
	    return *it;	    
	} else {
	    auto reg = __table__ ["rax"];
	    auto it = (signedOne (size) in reg);
	    if (it is null)
		assert (false, "Taille inconnu pour " ~ reg.name ~ " " ~ to!string(size));
	    return *it;
	}	    	
	assert (false, "Erreur" ~ to!string (size));
    }
    
    static void reserve (AMDReg elem) {
	if (elem && elem.isStd && !elem.isOff) {
	    auto reg = getInfo (elem.name);
	    __free__ [reg.name] = false;
	}
    }

    static void free (AMDReg elem) {
	if (elem && elem.isStd && !elem.isOff) {
	    auto reg = getInfo (elem.name);
	    __free__ [reg.name] = true;
	}
    }
    
    static void free (string name) {
	__free__ [name] = true;
    }

    static void freeAll () {
	__free__.clear ();
    }
    
    mixin Singleton!AMDRegTable;
    
}

class AMDReg : AMDObj {

    private AMDSize _size;
    private ulong _id;
    private string _name;
    private bool _isStd = false;
    private bool _isOff = false;
    private bool _pos = false;
    private long _offset;
    static long __globalOffset__ = 0;   
    static long [ulong] __offsets__;
    static ulong __lastId__;
    
    protected this () {}

    this (R info) {
	if (info.name !is null) {
	    this._isStd = true;
	    this._name = info.name;
	    this._size = info.size;
	} else {
	    this._isStd = false;
	    this._id = lastId ();
	    this._size = info.size;
	    this.toAsm ();
	}
    }
    
    this (ulong id, AMDSize size) {
	this._isStd = false;
	this._id = id;
	this._size = size;
	this.toAsm ();
    }

    this (AMDSize size) {
	this._isStd = false;
	this._id = lastId ();
	this._size = size;
	this.toAsm ();
    }

    this (AMDSize size, ulong offset) {
	this._isStd = true;
	this._id = lastId ();
	this._size = size;
	this._offset = offset;
	this._isOff = true;
	this._pos = true;
	auto r = REG.getReg ("rbp");
	this._name = r.name;
    }

    this (string name, AMDSize size) {
	this._isStd = true;
	this._name = name;
	this._size = size;
    }

    ref long offset () {
	return this._offset;
    }
    
    ref bool isOff () {
	return this._isOff;
    }

    ref bool isStd () {
	return this._isStd;
    }
    
    ref string name () {
	return this._name;
    }

    override bool opEquals (Object other) {
	auto reg = cast (AMDReg) other;
	if (!reg) return false;
	else {
	    if (this._isOff) {
		if (!reg._isOff || reg._offset != this._offset || this._name != reg._name || reg._pos != this._pos)
		    return false;
		return true;
	    } else if (this._isStd) {
		if (!reg._isStd || reg._name != this._name) return false;
		return true;	
	    } else return reg._id == this._id;
	}
    }
    
    static ulong globalOff () {
	return __globalOffset__;
    }
    
    static void lastId (ulong last) {
	__lastId__ = last;
    }

    static ulong lastId () {
	auto id = __lastId__;
	__lastId__++;
	return id;
    }
    
    private void toAsm () {
	if (this._isStd) return;
	auto off = this._id in __offsets__;
	long o;
	if (off is null) {	    
	    auto res = __globalOffset__ % this._size.size;
	    if (res  != 0) {
		res =  (this._size.size - res);
		__globalOffset__ += res;
	    }
	    o = __globalOffset__ + abs (this._size.size);
	    __offsets__ [this._id] = o;
	    __globalOffset__ = o;
	} else o = *off;
	auto r = REG.getReg ("rbp");
	this._isStd = true;
	this._offset = o;
	this._name = r.name;
	this._isOff = true;	
    }

    static void resetOff () {
	__offsets__.clear ();
	__globalOffset__ = 0;
    }
    
    void resize (AMDSize size) {	
	if (this._isStd && !this._isOff) {
	    auto info = REG.getReg (this._name, size);
	    this._name = info.name;
	    this._size = info.size;	    
	} else {
	    this._size = size;
	}
    }
       
    AMDReg clone (AMDSize size) {
	if (this._isStd && !this._isOff) {	    
	    return new AMDReg (REG.getReg (this._name, size));
	} else {
	    return new AMDReg (this._id, size);
	}
    }
    
    override AMDSize sizeAmd () {
	return this._size;
    }

    override string toString () {
	auto buf = new OutBuffer;
	if (this._isStd) {
	    if (this._isOff && this._offset != 0) {
		if (!this._pos)
		    return to!string (-this._offset) ~ "(%" ~ this._name ~ ")";
		else
		    return to!string (this._offset) ~ "(%" ~ this._name ~ ")";
	    } else if (this._isOff) {
		return "(%" ~ this._name ~ ")";
	    } else return "%" ~ this._name;
	}
	return "%tr:" ~ to!string (this._id) ~ ":" ~ to!string (this._size);
    }
   
}
