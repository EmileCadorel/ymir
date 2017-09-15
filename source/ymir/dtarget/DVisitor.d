module ymir.dtarget.DVisitor;
import ymir.lint._;
import ymir.dtarget._;
import ymir.semantic._;
import ymir.ast._;
import ymir.utils._;

import std.stdio, std.container, std.outbuffer;
import std.format, std.process;

class DVisitor : LVisitor {

    override Array!LFrame visit () {
	Array!LFrame frames;
	foreach (it ; FrameTable.instance.finals) {
	    frames.insertBack (this.visit (it));
	}

	return frames;
    }

    void toFile (Array!LFrame frames, string filename) {
	auto file = File (filename, "w");
	auto imports = new OutBuffer ();
	auto funcs = new OutBuffer ();
	
	foreach (it ; frames) {
	    auto dframe = cast (DFrame) it;
	    foreach (ip ; dframe.imports)
		imports.writef ("import %s;", ip.toString);

	    funcs.writef ("\n%s\n", dframe.toString);
	}

	file.writef ("%s\n\n%s", imports.toString, funcs.toString);	
    }

    void finalize (string [] files) {
	string [] options;
	if (Options.instance.isOn (OptionEnum.TARGET))
	    options = ["-of=" ~ Options.instance.getOption (OptionEnum.TARGET)];
	else
	    options = ["-of=a.out"];
	
	auto pid = spawnProcess (["dmd"] ~ options ~ files);
	if (wait (pid) != 0) assert ("Compilation raté");
    }

    string extension () {
	return ".d";
    }
    
    override LFrame visit (FinalFrame semFrame) {
	auto frame = new DFrame (semFrame.name);
	frame.type = this.visitType (semFrame.type.type);

	foreach (it ; semFrame.vars) {
	    frame.addVar (this.visitParam (it));
	}
	
	frame.block = this.visitBlock (semFrame.block);	
	return frame;
    }        

    private DBlock visitBlock (Block block) {
	auto bl = new DBlock ();
	foreach (it ; block.insts) {
	    bl.addInst (visit (it));
	}
	return bl;
    }

    private DInstruction visit (Instruction inst) {
	return inst.matchRet (
	    (Assert ass) => visit (ass),
	    (Block bl) => visit (bl),
	    (Break br) => visit (br),
	    (Expression ex) => visit (ex),
	    (For fo) => visit (fo),
	    (If i) => visit (i),
	    (ElseIf el) => visit (el),
	    (Else el) => visit (el),
	    (Return re) => visit (re),
	    (TupleDest td) => visit (td),
	    (VarDecl vd) => visit (vd),
	    (While wh) => visit (wh)
	);
    }

    private DExpression visit (Expression exp) {
	return exp.matchRet (
	    (Access acc) => visit (acc),
	    (ArrayAlloc all) => visit (all),
	    (Binary bin) => visit (bin),
	    (Cast cs) => visit (cs),
	    (Decimal dc) => visit (dc),
	    (Char c) => visit (c),
	    (Float fl) => visit (fl),
	    (String st) => visit (st),
	    (Bool bl) => visit (bl),
	    (Null n) => visit (n),
	    (ConstArray cr) => visit (cr),
	    (ConstRange cr) => visit (cr),
	    (DColon dc) => visit (dc),
	    (Dot dt) => visit (dt),
	    (Expand ex) => visit (ex),
	    (FuncPtr fp) => visit (fp),
	    (Is i) => visit (i),
	    (LambdaFunc lm) => visit (lm),
	    (Match mt) => visit (mt),
	    (ParamList pm) => visit (pm),
	    (Par p) => visit (p),
	    (ConstTuple ct) => visit (ct),
	    (TypeOf tp) => visit (tp),
	    (BefUnary bf) => visit (bf),
	    (AfUnary af) => visit (af),
	    (Var var) => visit (var)	    
	);
    }
    
    private DInstruction visit (Assert ass) {
	if (ass.msg)
	    return new DAssert (visit (ass.expr), visit (ass.msg));	
	else
	    return new DAssert (visit (ass.expr), null);
    }

    private DInstruction visit (Break br) {
	if (br.hasId)
	    return new DBreak (br.id);
	else return new DBreak ();
    }

    private DInstruction visit (For _for) {
	assert (false, "TODO " ~ typeid(_for).toString);
    }

    private DIf visit (If i) {
	auto test = visit (i.test);
	writeln (i.test);
	auto bl = visitBlock (i.block);
	if (i.else_) return new DIf (test, bl, visit (i.else_));
	else return new DIf (test, bl);
    }

    private DIf visit (ElseIf el) {
	auto test = visit (el.test);
	auto bl = visitBlock (el.block);
	if (el.else_) return new DIf (test, bl, visit (el.else_));
	else return new DIf (test, bl);
    }

    private DIf visit (Else el) {
	if (auto elif = cast (ElseIf) el) return visit (elif);
	return new DIf (null, visitBlock (el.block));
    }

    private DInstruction visit (Return ret) {
	if (ret.elem) {
	    auto expr = visit (ret.elem);
	    if (ret.instComp) 
		expr = cast (DExpression) ret.instComp.lintInst (expr);
	    return new DReturn (expr);
	} else return new DReturn ();
    }

    private DInstruction visit (TupleDest tp) {
	assert (false);
    }

    private DInstruction visit (VarDecl vd) {
	auto vdecl = new DVarDecl ();
	foreach (it ; vd.decls) {
	    if (!cast (UndefInfo) it.info.type)
		vdecl.addVar (new DTypeVar (visitType (it.info.type),
					    new DVar (it.token.str))
		);			
	}

	foreach (it ; vd.insts) {
	    if (it && !cast (UndefInfo) it.info.type)
		vdecl.addExpression (visit (it));
	}
	
	return vdecl;
    }

    private DInstruction visit (While wh) {
	auto test = visit (wh.test);
	auto bl = visitBlock (wh.block);
	return new DWhile (test, bl);
    }

    private DExpression visit (Access acc) {
	assert (false, "TODO");
    }

    private DExpression visit (ArrayAlloc all) {
	assert (false, "TODO");
    }

    private DExpression visit (Binary bin) {
	DExpression left, right;
	if (bin.info.type.value !is null) 
	    return cast (DExpression) bin.info.type.value.toLint (bin.info);
	

	if (bin.info.type.leftTreatment !is null) 
	    left = cast (DExpression) bin.info.type.leftTreatment (bin.info.type, bin.left, bin.right);
	else left = visit (bin.left);

	for (long nb = bin.info.type.lintInstS.length - 1 ; nb >= 0; nb --) 
	    left = cast (DExpression) bin.info.type.lintInst (left, nb);

	if (bin.info.type.rightTreatment !is null)
	    right = cast (DExpression) bin.info.type.rightTreatment (bin.info.type, bin.left, bin.right);
	else right = visit (bin.right);
	
	for (long nb = bin.info.type.lintInstSR.length - 1 ; nb >= 0; nb --) 
	    right = cast (DExpression) bin.info.type.lintInstR (right, nb);


	return cast (DExpression) bin.info.type.lintInst (left, right);	
    }

    private DExpression visit (Cast cs) {
	return null;
    }

    private DExpression visit (Decimal dc) {
	return new DCast (new DType (fromDecimalConst (cast (DecimalConst) dc.type)), new DDecimal (dc.value));
    }

    private DExpression visit (Char c) {
	return new DChar (cast (char) c.code);
    }

    private DExpression visit (Float fl) {
	return new DDouble (fl.totale);
    }

    private DExpression visit (String st) {
	return new DString (st.content);
    }

    private DExpression visit (Bool bl) {
	return new DBool (bl.value);
    }

    private DExpression visit (Null n) {
	return new DNull ();
    }

    private DExpression visit (ConstArray cr) {
	assert (false);
    }

    private DExpression visit (ConstRange cr) {
	assert (false);
    }
    
    private DExpression visit (DColon dc) {
	assert (false);
    }

    private DExpression visit (Dot dt) {
	assert (false);
    }


    private DExpression visit (Match mt) {
	return null;
    }

    private DExpression visit (ParamList pm) {
	return null;
    }

    private DExpression visit (Par p) {
	return null;
    }

    private DExpression visit (ConstTuple tp) {
	return null;
    }

    private DExpression visit (TypeOf tp) {
	return null;
    }

    private DExpression visit (BefUnary bf) {
	return null;
    }

    private DExpression visit (AfUnary af) {
	return null;
    }

    private DExpression visit (Var var) {
	return new DVar (var.token.str);
    }
    
    private DTypeVar visitParam (Var var) {
	auto dvar = new DTypeVar (this.visitType (var.info.type), new DVar (var.token.str));
	return dvar;
    }    

    private DType visitType (InfoType type) {
	if (auto dec = cast (DecimalInfo) type) {
	    final switch (dec.type.id) {
	    case DecimalConst.BYTE.id : return new DType ("byte");
	    case DecimalConst.UBYTE.id : return new DType ("ubyte");
	    case DecimalConst.SHORT.id : return new DType ("short");
	    case DecimalConst.USHORT.id : return new DType ("ushort");
	    case DecimalConst.INT.id : return new DType ("int");
	    case DecimalConst.UINT.id : return new DType ("uint");
	    case DecimalConst.LONG.id : return new DType ("long");
	    case DecimalConst.ULONG.id : return new DType ("ulong");		
	    }
	} else if (auto fl = cast (FloatInfo) type) {
	    return new DType ("double");
	} else if (auto arr = cast (ArrayInfo) type) {
	    return new DType (visitType (arr.content).name ~ "[]");
	} else if (cast (BoolInfo) type) {
	    return new DType ("bool");
	} else if (cast (CharInfo) type) {
	    return new DType ("char");
	} else if (auto en = cast (EnumInfo) type) {
	    return new DType (en.name);
	} else if (auto ptr = cast (PtrFuncInfo) type) {
	    auto buf = new OutBuffer ();
	    buf.writef ("%s function(", this.visitType (ptr.ret).name);
	    foreach (it ; ptr.params) {
		buf.writef ("%s%s", this.visitType (it).name, it is ptr.params [$ - 1] ? "" : ", ");
	    }
	    buf.writef (")");
	    return new DType (buf.toString);
	} else if (auto ptr = cast (PtrInfo) type) {
	    return new DType (this.visitType (ptr.content).name ~ "*");
	} else if (auto range = cast (RangeInfo) type) {
	    return new DType (format("range!(%s)", visitType (range.content).name));
	} else if (auto _ref = cast (RefInfo) type) {
	    return new DType (format("ref %s", this.visitType (_ref.content).name));
	} else if (auto str = cast (StringInfo) type) {
	    return new DType ("string");
	} else if (auto tl = cast (TupleInfo) type) {
	    return new DType (tl.typeString);
	} else if (cast (VoidInfo) type) {
	    return new DType ("void");	
	} else {
	    assert (false, "TODO");
	}
    }
    
}

