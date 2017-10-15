module ymir.dtarget.DBlock;
import ymir.dtarget._;
import std.container;

import std.outbuffer, std.string;
import std.container;

class DBlock : DInstruction {

    private ulong _nbIndent;
    
    private Array!DInstruction _insts;

    private static SList!DBlock __current__;
    
    private this () {
	__current__.insertFront (this);
    }
    
    void addInst (DInstruction inst) {
	this._insts.insertBack (inst);
	if (inst) inst.father = this;
    }

    Array!DInstruction instructions () {
	return this._insts;
    }

    static DBlock current () {
	return __current__.front ();
    }
    
    ref ulong nbIndent () {
	return this._nbIndent;
    }

    static DBlock open () {
	return new DBlock ();
    }
    
    static void close () {
	__current__.removeFront ();
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	if (auto bl = cast (DBlock) this._father) {
	    this._nbIndent = this._father.nbIndent + 4;
	}
	
	buf.writefln (" {", rightJustify ("", this._nbIndent, ' '));
	foreach (it ; this._insts) {
	    buf.writefln ("%s%s%s",
			  rightJustify ("", this._nbIndent, ' '),
			  it.toString,
			  cast (DExpression) it ? ";" : "");
	    
	}
	if (this._nbIndent > 0) {
	    buf.writef ("%s}", rightJustify ("", this._nbIndent - 4, ' '));
	} else {
	    buf.write ("}");
	}
	return buf.toString ();
    }
    
}
