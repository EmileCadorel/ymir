module ymir.dtarget.DBlock;
import ymir.dtarget._;
import std.container;

import std.outbuffer, std.string;

class DBlock : DInstruction {

    private ulong _nbIndent;
    
    private Array!DInstruction _insts;

    void addInst (DInstruction inst) {
	this._insts.insertBack (inst);
	if (inst) inst.father = this;
    }

    ref ulong nbIndent () {
	return this._nbIndent;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	buf.writefln (" {", rightJustify ("", this._nbIndent, ' '));
	foreach (it ; this._insts) {
	    buf.writefln ("%s%s%s",
			  rightJustify ("", this._nbIndent, ' '),
			  it.toString,
			  cast (DExpression) it ? ";" : "");
	}
	buf.writef ("%s}", rightJustify ("", this._nbIndent - 4, ' '));
	return buf.toString ();
    }
    
}
