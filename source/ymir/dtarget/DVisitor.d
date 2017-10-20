module ymir.dtarget.DVisitor;
import ymir.lint._;
import ymir.dtarget._;
import ymir.semantic._;
import ymir.ast._;
import ymir.utils._;
import ymir.syntax._;
import ymir.compiler._;


import std.stdio, std.container, std.outbuffer;
import std.format, std.process, std.string, std.path;
import std.algorithm, std.file, std.typecons;


class DVisitor : LVisitor {

    private DFrame _currentFrame;

    private Array!StructInfo _structToCst;

    private TupleInfo[string] _tupleToCst;    

    private LFrame [string] _preCompiled;
    
    override Array!LFrame visit () {
	Array!LFrame frames;

	foreach (it ; ExternFrame.frames) {
	    if (it.proto !is null && it.isFromC)
		frames.insertBack (this.visit (it));
	}

	foreach (it ; FrameTable.instance.finals) {
	    frames.insertBack (this.visit (it));
	}

	foreach (it ; this._preCompiled) {
	    frames.insertBack (it);
	}

	this._preCompiled = null;
	
	return frames;
    }

    void addStructToCst (StructInfo info) {
	if (this._structToCst[].find!("a.name == b.name") (info).empty)
	    this._structToCst.insertBack (info);
    }

    string addTupleToCst (string file, TupleInfo info) {
	auto tupleName = Mangler.mangle!"tuple" (new Namespace (file), info.simpleTypeString);
	if (tupleName !in this._tupleToCst)
	    this._tupleToCst [tupleName] = info;
	return tupleName;
    }
    
    Namespace toDNamespace (Namespace space) {
	return space.addSuffix ("Ymir");
    }

    void clean () {
	this._tupleToCst = null;
	this._structToCst = make!(Array!StructInfo);
    }
    
    string toFile (Array!LFrame frames, string filename, string extension) {
	auto imports = new OutBuffer ();
	auto funcs = new OutBuffer ();
	auto modName = toDNamespace (new Namespace (filename));
	
	mkdirRecurse ("out/" ~ modName.directory);
	auto file = File ("out/" ~ modName.asFile (extension), "w");
	Array!string toImports;
	
	imports.writefln ("module %s;", modName.toString);
	imports.writefln ("import std.typecons;");
	imports.writefln ("import core.memory;");       

	foreach (it ; this._structToCst) {
	    auto src = toDStruct (it);
	    funcs.writef ("\n%s\n", src);
	}
	
	foreach (it ; frames) {
	    auto dframe = cast (DFrame) it;
	    foreach (ip ; dframe.importsD) {
		auto name = ip.toString ();
		if (toImports[].find (name).empty) {
		    toImports.insertBack (name);
		}
	    }

	    foreach (ip ; dframe.imports) {
		auto name = toDNamespace (ip).toString;
		if (toImports[].find (name).empty)
		    toImports.insertBack (name);
	    }

	    funcs.writef ("\n%s\n", dframe.toString);
	}

	foreach (it ; toImports) {
	    imports.writefln ("import %s;", it);
	}
		
	file.writef ("%s\n\n%s", imports.toString, funcs.toString);
	return modName.asFile (extension);
    }
    
    void finalize (string [] files) {
	string [] options;
	if (Options.instance.isOn (OptionEnum.ASSEMBLE))
	    options ~= ["-c"];
	else {
	    if (Options.instance.isOn (OptionEnum.OUTFILE))
		options = ["-of=" ~ Options.instance.getOption (OptionEnum.OUTFILE)];
	    else
		return;
	}
	
	options ~= ["-I=" ~ buildPath (Options.instance.getPath (), "out/")] ~ Options.instance.libs ~ buildPath (Options.instance.getPath(), "liblibymir.a");

	if (Options.instance.isOn (OptionEnum.VERBOSE))
	    writeln (["dmd"] ~ options ~ files);

	chdir ("out/");

	auto pid = spawnProcess (["dmd"] ~ options ~ files);
	if (wait (pid) != 0) assert ("Compilation raté");

	if (Options.instance.isOn (OptionEnum.OUTFILE)) {
	    copy (Options.instance.getOption (OptionEnum.OUTFILE), "../" ~ Options.instance.getOption (OptionEnum.OUTFILE), Yes.preserveAttributes);
	}
	chdir ("../");
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
	auto frame = new DFrame (Mangler.mangle!"function" (semFrame));
	frame.space = semFrame.namespace;
	this._currentFrame = frame;
	frame.type = this.visitType (semFrame.type.type);
	
	foreach (it ; semFrame.vars) {
	    frame.addVar (this.visitParam (it));
	}

	DAuxVar.reset ();
	
	frame.block = this.visitBlock (semFrame.block);
	return frame;
    }        

    private DBlock visitBlock (Block block) {
	auto bl = DBlock.open ();
	foreach (it ; block.insts) {
	    bl.addInst (visit (it));
	}
	bl.close ();
	return bl;
    }

    public void addDImport (Namespace space) {
	if (this._currentFrame.importsD[].find (space).empty) {
	    this._currentFrame.importsD.insertBack (space);
	}
    }
    
    public void addImport (Namespace space) {
	bool hasAlready = false;
	if (this._currentFrame.space.isSubOf (space)) hasAlready = true;
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
	    (Block bl) => visitBlock (bl),
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
	auto dv = COMPILER.getLVisitor!(DVisitor);
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

    private DExpression visit (FuncPtr fptr) {
	if (fptr.expr is null) {
	    return new DNull ();
	} else {
	    auto ptr = cast (PtrFuncInfo) fptr.info.type;
	    if (ptr.score) return new DBefUnary (new DVar (ptr.score.name), Tokens.AND);
	    else return visit (fptr.expr);
	}
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
	DExpression expr;
	if (ret.elem) {
	    if (ret.instCast) {		
		if (ret.instCast.leftTreatment) {
		    expr = cast (DExpression) ret.instCast.leftTreatment (ret.instCast, ret.elem, null);
		} else {
		    expr = visit (ret.elem);
		}
		if (ret.instCast.lintInstS.length > 0)
		    expr = cast (DExpression) ret.instCast.lintInst (expr);
	    } else expr = visit (ret.elem);
	    if (ret.instComp) {
		expr = cast (DExpression) ret.instComp.lintInst (expr);
	    }	    
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
	auto params = new DParamList ();
	auto inst = new LInstList ();
	foreach (it ; 0 .. acc.params.length) {
	    params.addParam (visit (acc.params [it]));
	}
	
	auto type = acc.info.type;
	LInstList left;
	if (acc.info.type.leftTreatment) 
	    left = acc.info.type.leftTreatment (acc.info.type, acc.left, null);
	else left = visit (acc.left);
	
	for (long nb = acc.info.type.lintInstS.length - 1 ; nb >= 0; nb --) {
	    left = acc.info.type.lintInst (left, nb);
	}
	return cast (DExpression) type.lintInst (left, make!(Array!LInstList) (params));
    }

    private DExpression visit (ArrayAlloc all) {
	auto type = visitType (all.type.info.type);
	auto param = new DParamList ();
	auto size = visit (all.size);
	param.addParam (size);
	param.addParam (new DNew (new DVar (type.name ~ "*"), new DBinary (new DDot (new DVar (type.name), new DVar ("sizeof")), size, Tokens.STAR)));
	return new DPar (new DVar ("tuple"), param);
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

	auto res = cast (DExpression) bin.info.type.lintInst (left, right);
	if (auto dbin = cast (DBinary) res) {
	    if (!isAffect (dbin.op)) return new DCast (visitType (bin.info.type), dbin);
	    else return dbin;
	} else 
	    return res;
    }

    private DExpression visit (Cast cs) {
	auto type = visitType (cs.type.info.type);
	auto value = visit (cs.expr);
	return new DCast (type, value);
    }

    private DExpression visit (Decimal dc) {
	import std.bigint, std.conv;
	try {
	    return new DCast (new DType (fromDecimalConst (cast (DecimalConst) dc.type)), new DDecimal (cast (DecimalConst) dc.type, dc.value));	    
	} catch (ConvOverflowException exp) {
	    throw new CapacityOverflow (dc.info, dc.value.to!string);
	}
    }

    private DExpression visit (Char c) {
	return new DChar (cast (char) c.code);
    }

    private DExpression visit (Float fl) {
	return new DDouble (fl.totale);
    }

    public DExpression visit (String st) {
	auto space = this._currentFrame.space;
	auto name = Mangler.mangle!"function" (new Namespace (space, "0CstString"));
	auto fr = name in this._preCompiled;
	if (fr is null) {
	    auto frame = new DFrame (name);
	    auto ptr = new DVar ("ptr"), len = new DVar ("len");
	    frame.type = new DType ("Tuple!(ulong, char*)");
	    frame.addVar (new DTypeVar (new DType (Dlang.ULONG), len));
	    frame.addVar (new DTypeVar (new DType ("const (char)*"), ptr));
	    auto bl = DBlock.open ();
	    auto iter = new DAuxVar (), res = new DAuxVar;
	    auto decl = new DVarDecl ();
	    
	    decl.addVar (new DTypeVar (new DType (Dlang.ULONG), iter));
	    decl.addExpression (new DBinary (iter, new DDecimal (0), Tokens.EQUAL));
	    decl.addVar (new DTypeVar (new DType ("char*"), res));
	    decl.addExpression (new DBinary (res, new DNew (new DVar ("char*"), len), Tokens.EQUAL));
	    bl.addInst (decl);
	    
	    auto test = new DBinary (new DBefUnary (ptr, Tokens.STAR), new DDecimal (0), Tokens.NOT_EQUAL);
	    auto inside = DBlock.open ();
	    inside.addInst (new DBinary (new DAccess (res, iter), new DBefUnary (ptr, Tokens.STAR), Tokens.EQUAL));
	    inside.addInst (new DBefUnary (ptr, Tokens.DPLUS));
	    inside.addInst (new DBefUnary (iter, Tokens.DPLUS));
	    inside.close ();
	    
	    bl.addInst (new DWhile (test, inside));
	    auto paramList = new DParamList ();
	    paramList.addParam (new DCast (new DType (Dlang.ULONG), iter));
	    paramList.addParam (res);
	    
	    bl.addInst (new DReturn (new DPar (new DVar ("tuple"), paramList)));
	    bl.close ();
	    frame.block = bl;
	    this._preCompiled [name] = frame;
	}
	auto paramList = new DParamList ();
	paramList.addParam (new DDecimal (st.content.length));
	paramList.addParam (new DDot (new DString (st.content), new DVar ("ptr")));
	return new DPar (new DVar (name), paramList);
    }

    private DExpression visit (Bool bl) {
	return new DBool (bl.value);
    }

    private DExpression visit (Null n) {
	return new DNull ();
    }

    private DExpression visit (ConstArray cr) {
	auto ca = new DConstArray ();
	auto length = cr.params.length;
	auto type = cast (ArrayInfo) cr.info.type;
	auto dtype = new DType (visitType (type.content).name ~ "*");	
	auto array = new DNew (new DVar (dtype.name), new DBinary (new DDecimal (length), new DDecimal (type.content.size), Tokens.STAR));

	auto bl = DBlock.current ();

	auto decl = new DVarDecl ();	
	auto aux = new DAuxVar ();

	decl.addVar (new DTypeVar (dtype, aux));
	decl.addExpression (new DBinary (aux, array, Tokens.EQUAL));
	
	bl.addInst (decl);
	
	foreach (it ; 0 .. cr.params.length) {
	    auto cster = cr.casters [it];
	    DExpression ret = visit (cr.params [it]);
	    if (cster) {
		for (long nb = cster.lintInstS.length - 1; nb >= 0; nb --) {		
		    ret = cast (DExpression) cster.lintInst (ret, nb);
		}		
	    }
	   
	    bl.addInst (new DBinary (new DAccess (aux, new DDecimal (it)), ret, Tokens.EQUAL));
	}
    
	auto paramList = new DParamList ();
	paramList.addParam (new DCast (new DType (Dlang.ULONG), new DDecimal (cr.params.length)));
	paramList.addParam (aux);
		
	return new DPar (new DVar ("tuple"), paramList);
    }

    private DExpression visit (ConstRange cr) {
	auto params = new DParamList ();
	if (cr.lorr == 1) {
	    params.addParam (cast (DExpression) cr.caster.lintInst (visit (cr.left)));
	    params.addParam (visit (cr.right));
	} else if (cr.lorr == 2) {
	    params.addParam (visit (cr.left));
	    params.addParam (cast (DExpression) cr.caster.lintInst (visit (cr.right)));
	} else {
	    params.addParam (visit (cr.left));
	    params.addParam (visit (cr.right));
	}
	return new DPar (new DVar ("tuple"), params);
    }
    
    private DExpression visit (DColon dot) {
	DExpression exprs;
	if (dot.info.value) return cast (DExpression) dot.info.value.toLint (dot.info);
	if (dot.info.type.leftTreatment) {
	    exprs = cast (DExpression) dot.info.type.leftTreatment (dot.info.type, dot.left, null);
	}

	auto left = visit (dot.left);
	if (dot.info.type.lintInstS.length > 0) {
	    for (long nb = dot.info.type.lintInstS.length - 1 ; nb >= 0 ; nb --) {
		left = cast (DExpression) dot.info.type.lintInst (left, nb);
	    }
	}

	return cast (DExpression) dot.info.type.lintInst (exprs, left);	
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


    private DExpression visit (LambdaFunc func) {
	return new DBefUnary (new DVar (Mangler.mangle!"function" (func.proto.name, func.proto)), Tokens.AND);
    }
    
    private DExpression visit (Match mt) {
	assert (false);
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
		return new DPar (new DVar (par.score.name), params);
	    }
	}
    }

    private DExpression visit (ConstTuple tp) {
	auto params = new DParamList ();
	foreach (it ; tp.params) {
	    params.addParam (this.visit (it));
	}
	return new DPar (new DVar ("tuple"), params);
    }

    private DExpression visit (TypeOf tp) {
	assert (false);
    }

    private DExpression visit (BefUnary bf) {
	if (cast (PtrFuncInfo) bf.info.type) {
	    return cast (DExpression) PtrFuncUtils.InstConstFunc (bf.info.type, null, null);
	} else {
	    auto ret = visit (bf.elem);
	    for (long nb = bf.info.type.lintInstS.length - 1 ; nb >= 0; nb --) {
		ret = cast (DExpression) bf.info.type.lintInst (ret, nb);
	    }
	    return ret;
	}
    }

    private DExpression visit (AfUnary af) {
	assert (false);
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
	    case DecimalConst.BYTE.id : return new DType (Dlang.BYTE, type.isConst);
	    case DecimalConst.UBYTE.id : return new DType (Dlang.UBYTE, type.isConst);
	    case DecimalConst.SHORT.id : return new DType (Dlang.SHORT, type.isConst);
	    case DecimalConst.USHORT.id : return new DType (Dlang.USHORT, type.isConst);
	    case DecimalConst.INT.id : return new DType (Dlang.INT, type.isConst);
	    case DecimalConst.UINT.id : return new DType (Dlang.UINT, type.isConst);
	    case DecimalConst.LONG.id : return new DType (Dlang.LONG, type.isConst);
	    case DecimalConst.ULONG.id : return new DType (Dlang.ULONG, type.isConst);		
	    }
	} else if (auto fl = cast (FloatInfo) type) {
	    return new DType ("double", type.isConst);
	} else if (auto arr = cast (ArrayInfo) type) {
	    return new DType (format ("Tuple!(ulong, %s*)", visitType (arr.content).name), type.isConst);
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
	    auto t = visitType (range.content).name;
	    return new DType (format("Tuple!(%s, %s)", t, t), type.isConst);
	} else if (auto _ref = cast (RefInfo) type) {
	    return new DType (format("%s*", visitType (_ref.content).name), type.isConst);
	} else if (auto str = cast (StringInfo) type) {
	    return new DType ("Tuple!(ulong, char*)", type.isConst);
	} else if (auto tl = cast (TupleInfo) type) {
	    auto name = new OutBuffer ();
	    name.write ("Tuple!(");
	    foreach (it; tl.params) {
		name.write (visitType (it).name);
		if (it !is tl.params[$ - 1]) name.write(", ");
	    }
	    name.write (")");
	    return new DType (name.toString, type.isConst);
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

    private bool isAffect (Token op) {
	return [
	    Tokens.EQUAL, Tokens.AND_AFF, Tokens.DIV_AFF, Tokens.PIPE_EQUAL,
	    Tokens.MINUS_AFF, Tokens.PLUS_AFF, Tokens.LEFTD_AFF, Tokens.RIGHTD_AFF,
	    Tokens.EQUAL
	].find (op) != [];
    }
    
}

