module ymir.dtarget.DVisitor;
import ymir.lint._;
import ymir.dtarget._;
import ymir.semantic._;
import ymir.ast._;
import ymir.utils._;
import ymir.syntax._;

import std.stdio, std.container, std.outbuffer;
import std.format, std.process, std.string;
import std.algorithm;

class DVisitor : LVisitor {

    private DFrame _currentFrame;

    private Array!StructInfo _structToCst;
    
    
    override Array!LFrame visit () {
	Array!LFrame frames;

	foreach (it ; ExternFrame.frames) {
	    if (it.proto !is null && it.isFromC)
		frames.insertBack (this.visit (it));
	}

	foreach (it ; FrameTable.instance.finals) {
	    frames.insertBack (this.visit (it));
	}

	return frames;
    }

    void addStructToCst (StructInfo info) {
	if (this._structToCst[].find!("a.namespace == b.namespace") (info).empty)
	    this._structToCst.insertBack (info);
    }
    
    void toFile (Array!LFrame frames, string filename) {
	auto file = File (filename, "w");
	auto imports = new OutBuffer ();
	auto funcs = new OutBuffer ();

	auto modName = new Namespace (filename [0 .. filename.lastIndexOf (".")]);

	imports.writefln ("module %s;", modName.toString);	
	foreach (it ; frames) {
	    auto dframe = cast (DFrame) it;
	    foreach (ip ; dframe.imports)
		imports.writefln ("import %s;", ip.toString);

	    funcs.writef ("\n%s\n", dframe.toString);
	}

	foreach (it ; this._structToCst) {
	    auto src = toDStruct (it);
	    funcs.writef ("\n%s\n", src);
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

    private string toDStruct (StructInfo info) {
	auto buf = new OutBuffer ();
	buf.writef ("struct %s {\n", info.name);
	foreach (it ; 0 .. info.params.length) {
	    buf.writefln ("%s %s; ", visitType (info.params [it]).name, info.attribs [it]);
	}
	buf.writef ("}\n");
	return buf.toString;
    }
    
    LFrame visit (ExternFrame extFrame) {
	auto frame = new DProto (extFrame.name);
	frame.space = extFrame.namespace;
	this._currentFrame = frame;
	frame.type = this.visitType (extFrame.proto.type.type);
	foreach (it ; extFrame.proto.vars) {
	    frame.addVar (this.visitParam (it));
	}
	
	frame.isVariadic = extFrame.isVariadic;
	return frame;
    }
    
    override LFrame visit (FinalFrame semFrame) {
	auto frame = new DFrame (semFrame.name);
	frame.space = semFrame.namespace;
	this._currentFrame = frame;
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

    private void addImport (Namespace space) {
	bool hasAlready = false;
	if (space == this._currentFrame.space) hasAlready = true;
	foreach (it ; this._currentFrame.imports) {
	    if (it == space) {
		hasAlready = true;
		break;
	    }
	}
	if (!hasAlready)
	    this._currentFrame.imports.insertBack (space);
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

    static DExpression visitExpressionOutSide (Expression exp) {
	auto dv = new DVisitor ();
	return dv.visit (exp);
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
	Array!Expression params;
	foreach (it ; _for.vars) {
	    it.info.value = null;
	    params.insertBack (it);
	}

	_for.iter.info.type.lintInstS = _for.ret.lintInstS;
	auto left = cast (DFor)_for.ret.leftTreatment (_for.ret, _for.iter,
							       new ParamList (Word.eof, params));
	auto bl = visitBlock (_for.block);	

	foreach (it ; bl.instructions)
	    left.block.addInst (it);
	
	return left;	
    }

    private DExpression visit (Is i) {
	assert (false);
    }
    
    private DIf visit (If i) {
	auto test = visit (i.test);
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
	auto ca = new DConstArray ();
	foreach (it ; 0 .. cr.params.length) {
	    auto cster = cr.casters [it];
	    DExpression ret = visit (cr.params [it]);
	    if (cster) {
		for (long nb = cster.lintInstS.length - 1; nb >= 0; nb --) {		
		    ret = cast (DExpression) cster.lintInst (ret, nb);
		}		
	    }
	    ca.addValue (ret);
	}
	return ca;
    }

    private DExpression visit (ConstRange cr) {
	assert (false);
    }
    
    private DExpression visit (DColon dc) {
	assert (false);
    }

    private DExpression visit (Dot dot) {
	DExpression exprs;
	if (dot.info.value) return cast (DExpression) dot.info.value.toLint (dot.info);
	if (dot.info.type.leftTreatment) {
	    exprs = cast (DExpression) dot.info.type.leftTreatment (dot.info.type, dot.left, null);
	}
	
	auto left = this.visit (dot.left);

	if (dot.info.type.lintInstS.length > 0) {
	    for (long nb = dot.info.type.lintInstS.length - 1 ; nb >= 0 ; nb --) {
		left = cast (DExpression) dot.info.type.lintInst (left, nb);
	    }
	}

	return cast (DExpression) dot.info.type.lintInst (exprs, left);
    }


    private DExpression visit (Match mt) {
	return null;
    }

    private DParamList visit (Array!InfoType treat, ParamList pm) {
	auto params = new DParamList;
	foreach (it ; 0 .. pm.params.length) {
	    auto exp = pm.params [it];	    
	    auto elist = visit (exp);
	    if (treat [it]) {
		for (long nb = treat [it].lintInstS.length - 1 ; nb >= 0 ; nb --) {
		    elist = cast (DExpression) treat [it].lintInst (elist, nb);
		}
	    }
	    writeln (elist, " ", exp.info.type.typeString);
	    params.addParam (elist);
	}
	return params;
    }
        
    private DExpression visit (Par par) {
	auto params = visit (par.score.treat, par.paramList);
	if (par.info.type.lintInstMult) {	    
	    DExpression left;

	    if (par.info.type.leftTreatment)
		left = cast (DExpression) par.info.type.leftTreatment (par.info.type, par.left, par.paramList);
	    else left = visit (par.left);
	    return cast (DExpression) par.info.type.lintInst (left, make!(Array!LInstList) (params));    
	} else {
	    if (par.score.dyn) {
		if (par.dotCall) {
		    auto leftTreat = cast (DExpression) par.dotCall.info.type.leftTreatment (par.dotCall.info.type, par.dotCall.left, null);
		    auto left = params.params [0];
		    if (par.dotCall.info.type.lintInstS.length > 0) {
			for (long nb = par.dotCall.info.type.lintInstS.length - 1 ; nb >= 0 ; nb --)
			    left = cast (DExpression) par.dotCall.info.type.lintInst (left, nb);
		    }		    
		
		    auto res = cast (DExpression) par.dotCall.info.type.lintInst (leftTreat, left);
		    return new DPar (res, params);
		} else {
		    auto left = visit (par.left);
		    if (par.score.left) {
			for (long nb = par.score.left.lintInstS.length - 1 ; nb >= 0 ; nb--) {
			    left = cast (DExpression) par.score.left.lintInst (left, nb);
			}
		    }
		    return new DPar (left, params);
		}
	    } else {
		auto left = visit (par.left);
		auto type = cast (FunctionInfo) par.left.info.type;
		if (type !is null) {
		    this.addImport (type.space);
		}
		return new DPar (left, params);
	    }
	}
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

    static DType visitType (InfoType type) {
	if (auto dec = cast (DecimalInfo) type) {
	    final switch (dec.type.id) {
	    case DecimalConst.BYTE.id : return new DType ("byte", type.isConst);
	    case DecimalConst.UBYTE.id : return new DType ("ubyte", type.isConst);
	    case DecimalConst.SHORT.id : return new DType ("short", type.isConst);
	    case DecimalConst.USHORT.id : return new DType ("ushort", type.isConst);
	    case DecimalConst.INT.id : return new DType ("int", type.isConst);
	    case DecimalConst.UINT.id : return new DType ("uint", type.isConst);
	    case DecimalConst.LONG.id : return new DType ("long", type.isConst);
	    case DecimalConst.ULONG.id : return new DType ("ulong", type.isConst);		
	    }
	} else if (auto fl = cast (FloatInfo) type) {
	    return new DType ("double", type.isConst);
	} else if (auto arr = cast (ArrayInfo) type) {
	    return new DType (visitType (arr.content).name ~ "[]", type.isConst);
	} else if (cast (BoolInfo) type) {
	    return new DType ("bool", type.isConst);
	} else if (cast (CharInfo) type) {
	    return new DType ("char", type.isConst);
	} else if (auto en = cast (EnumInfo) type) {
	    return new DType (visitType (en.content).name, type.isConst);
	} else if (auto ptr = cast (PtrFuncInfo) type) {
	    auto buf = new OutBuffer ();
	    buf.writef ("%s function(", visitType (ptr.ret).name);
	    foreach (it ; ptr.params) {
		buf.writef ("%s%s", visitType (it).name, it is ptr.params [$ - 1] ? "" : ", ");
	    }
	    buf.writef (")");
	    return new DType (buf.toString, type.isConst);
	} else if (auto ptr = cast (PtrInfo) type) {
	    return new DType (visitType (ptr.content).name ~ "*", type.isConst);
	} else if (auto range = cast (RangeInfo) type) {
	    return new DType (format("range!(%s)", visitType (range.content).name), type.isConst);
	} else if (auto _ref = cast (RefInfo) type) {
	    return new DType (format("ref %s", visitType (_ref.content).name), type.isConst);
	} else if (auto str = cast (StringInfo) type) {
	    return new DType ("char[]", type.isConst);
	} else if (auto tl = cast (TupleInfo) type) {
	    return new DType (tl.typeString, type.isConst);
	} else if (cast (VoidInfo) type) {
	    return new DType ("void", type.isConst);	
	} else if (auto str = cast (StructCstInfo) type) {
	    return new DType (str.name ~ " *", type.isConst);
	} else if (auto str = cast (StructInfo) type) {
	    return new DType (str.name ~ " *", type.isConst);
	} else {
	    assert (false, "TODO" ~ type.typeString);
	}
    }
    
}

