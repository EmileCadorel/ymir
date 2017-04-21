module lint.LVisitor;
import semantic.pack.FrameTable, semantic.pack.Frame;
import lint.LFrame, lint.LInstList, lint.LLabel, lint.LReg;
import semantic.types.VoidInfo, lint.LSize;
import lint.LConst, lint.LRegRead, lint.LJump;
import semantic.pack.Symbol, lint.LGoto, lint.LWrite, lint.LCall;
import ast.all, std.container, std.conv, lint.LExp, lint.LSysCall;
import semantic.types.StringUtils, lint.LLocus, semantic.types.ArrayInfo;
import semantic.types.ArrayUtils, std.math, std.stdio, syntax.Keys;
import lint.LBinop, syntax.Tokens, semantic.types.PtrFuncInfo;
import semantic.types.InfoType;
import lint.LAddr, syntax.Word;
import semantic.types.RangeInfo, semantic.types.RangeUtils;
import semantic.types.StructUtils, semantic.types.TupleInfo;
import semantic.pack.FinalFrame;
import lint.LInst;
import std.array, std.typecons;
import semantic.types.StructInfo;
import semantic.value.all;

alias LPairLabel = Tuple! (LLabel, "vrai", LLabel, "faux");

class LVisitor {

    static string __ForEachBody__ = "_YPForEachBody__";
    static immutable string __AssertName__ = "_YPAssert__";
    static immutable string __ExitName__ = "exit";
    
    private LLabel [Instruction] _endLabels;
    static private LPairLabel __currentCondition__ = LPairLabel (null, null);

    static void createFunctions () {
	createAssert ();
    }
    

    static void createAssert () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto testVar = new LReg (LSize.BYTE);
	auto loc = new LReg (LSize.LONG);
	auto msg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	auto test = new LBinop (testVar, new LConstDecimal (0, LSize.BYTE), Tokens.DEQUAL);
	auto vrai = new LLabel (new LInstList), faux = new LLabel;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	auto printsName = "_YN23std46stdio46print5prints";
	vrai.insts += new LCall (printsName, make!(Array!LExp) (loc), LSize.NONE);
	auto test2 = new LBinop (msg, new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	auto vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	vrai.insts += new LJump (test2, vrai2);
	vrai.insts += new LGoto (faux2);
	vrai2.insts += new LCall (printsName, make!(Array!LExp) (msg), LSize.NONE);
	vrai.insts += vrai2;
	vrai.insts += faux2;
	vrai.insts += new LCall (__ExitName__, make!(Array!LExp) (new LConstDecimal (-1, LSize.INT)), LSize.NONE);
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__AssertName__, entry, end, null, make!(Array!LReg) ([testVar, loc, msg]));
	LFrame.preCompiled [__AssertName__] = fr;
	writeln (fr);
	LReg.lastId = last;
    }

    
    static LPairLabel isInCondition () {
	return __currentCondition__;
    }
    
    /**
     On visite toutes les frames sémantiques
     */    
    Array!LFrame visit () {
	Array!LFrame frames;
	foreach (it ; FrameTable.instance.finals) {
	    frames.insertBack (this.visit (it));
	}
	
	foreach (key, value ; LFrame.preCompiled) {
	    if (!value.isStd) {
		frames.insertBack (value);
	    }
	    LFrame.preCompiled.remove (key);
	}
	
	return frames;
    }

    /**
     On visite une frame généré par l'analyse sémantique et on la transforme en lint
     */
    LFrame visit (FinalFrame semFrame) {
	LLabel entry = new LLabel, end = new LLabel;
	LReg retReg = null;
	LReg.lastId = semFrame.last;
	
	if (semFrame.type !is null && cast(VoidInfo)semFrame.type.type is null) {
	    retReg = new LReg (semFrame.type.type.size);
	}

	entry.insts = new LInstList;
	Array!LReg args;
	foreach (it ; semFrame.vars) {
	    auto ret = new LReg (it.info.id, it.info.type.size);
	    args.insertBack (ret);
	    auto compS = it.info.type.ParamOp ();
	    if (compS) {
		LInstList list;
		if (compS.leftTreatment) {
		    list = compS.leftTreatment (it.info.type, it, null);
		} else list = new LInstList (ret);
		entry.insts += compS.lintInst (list);
	    }
	}
	
	visit (entry, end, retReg, semFrame.block);
 
	foreach (it ; semFrame.dest) {
	    end.insts += it.destruct ();
	}
	
	if (semFrame.name == Keys.MAIN.descr && retReg is null) {
	    retReg = new LReg (LSize.LONG);
	    end.insts += new LWrite (retReg, new LConstDecimal (0, LSize.LONG));
	}
	
	auto fr = new LFrame (semFrame.name, entry, end, retReg, args);
	fr.file = semFrame.file;
	fr.lastId = LReg.lastId;
	return fr;
    }

    private void visit (ref LLabel begin, ref LLabel end, ref LReg retReg, Block block) {
	if (begin.insts is null) begin.insts = new LInstList ();
	if (end.insts is null) end.insts = new LInstList ();
	foreach (it ; block.insts) {
	    visitInstruction (begin, end, retReg, it);
	}
	
	foreach (it ; block.dest) {
	    begin.insts += it.destruct ();
	}
	
	begin.insts.clean ();	
	end.insts.clean ();
    }

    private LInstList visitBlock (ref LLabel end, ref LReg retReg, Block block) {
	auto inst = new LInstList;
	foreach (it ; block.insts) {
	    visitInstruction (inst, end, retReg, it);
	}
	foreach (it ; block.dest) {
	    inst += it.destruct ();
	}
	
	inst.clean ();	
	end.insts.clean ();
	return inst;
    }
    
    private void visitInstruction (ref LInstList begin, ref LLabel end, ref LReg retReg, Instruction elem) {
	if (auto exp = cast(Expression)elem) begin += visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) begin += visitVarDecl (decl);
	else if (auto ret = cast(Return)elem) begin += visitReturn (end, retReg, ret);
	else if (auto _if = cast(If)elem) begin += visitIf (end, retReg, _if);
	else if (auto _while = cast(While) elem) begin += visitWhile (end, retReg, _while);
	else if (auto _for = cast (For) elem) begin += visitFor (end, retReg, _for);
	else if (auto _block = cast(Block) elem) begin += visitBlock (end, retReg, _block);
	else if (auto _break = cast (Break) elem) begin += visitBreak (_break);
	else if (auto _assert = cast (Assert) elem) begin += visitAssert (_assert);
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }
    
    private void visitInstruction (ref LLabel begin, ref LLabel end, ref LReg retReg, Instruction elem) {
	if (auto exp = cast(Expression)elem) begin.insts += visitExpression (exp);
	else if (auto decl = cast(VarDecl)elem) begin.insts += visitVarDecl (decl);
	else if (auto ret = cast(Return)elem) begin.insts += visitReturn (end, retReg, ret);
	else if (auto _if = cast(If)elem) begin.insts += visitIf (end, retReg, _if);
	else if (auto _while = cast(While)elem) begin.insts += visitWhile (end, retReg, _while);
	else if (auto _for = cast (For) elem) begin.insts += visitFor (end, retReg, _for);
	else if (auto _block = cast(Block) elem) begin.insts += visitBlock (end, retReg, _block);
	else if (auto _break = cast (Break) elem) begin.insts += visitBreak (_break);
	else if (auto _assert = cast (Assert) elem) begin.insts += visitAssert (_assert);
	else assert (false, "TODO visitInstruction ! " ~ elem.toString);
    }

    private LInstList visitIfWithValue (ref LLabel end, ref LReg retReg, If _if) {
	if (auto t = cast (BoolValue) _if.info.value) {
	    if (t.isTrue) {
		return visitBlock (end, retReg, _if.block);
	    } else {
		if (_if.else_) {
		    return visitElse (end, null, retReg, _if.else_);
		}
		return new LInstList;
	    }
	} else 
	    assert (false, typeid (_if.info.value).toString);
    }

    private LInstList visitElseIfWithValue (ref LLabel end, ref LReg retReg, ElseIf elseif) {
	if (auto t = cast (BoolValue) elseif.info.value) {
	    if (t.isTrue) {
		return visitBlock (end, retReg, elseif.block);
	    } else {
		if (elseif.else_)
		    return visitElse (end, null, retReg, elseif.else_);
		return new LInstList;
	    }
	} else
	    assert (false, typeid (elseif.info.value).toString);
    }
    
    
    private LInstList visitIf (ref LLabel end, ref LReg retReg, If _if) {
	auto insts = new LInstList;
	if (_if.info.value) {
	    return visitIfWithValue (end, retReg, _if);
	}
	insts += new LLocus (_if.token.locus);
	LLabel faux = new LLabel ();
	LLabel vrai = new LLabel ();
	LLabel fin = new LLabel ();
	LInstList left;
	__currentCondition__ = LPairLabel (vrai, faux);
	if (_if.info !is _if.test.info.type) {
	    if (_if.info.leftTreatment !is null )
		left = _if.info.leftTreatment (_if.info, _if.test, null);
	    else left = visitExpression (_if.test);
	    auto tlist = _if.info.lintInst (left);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	} else {
	    auto tlist = visitExpression (_if.test);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	}
	__currentCondition__ = LPairLabel (null, null);
	vrai.insts = visitBlock (end, retReg, _if.block);
	vrai.insts += new LGoto (fin);	
	if (_if.else_ !is null) {
	    faux.insts = visitElse (end, fin, retReg, _if.else_);
	} else faux.insts = new LInstList (new LGoto (fin));
	
	vrai.insts.clean ();
	faux.insts.clean ();
	insts += faux;
	insts += vrai;
	insts += fin;
	return insts;
    }

    private LInstList visitWhile (ref LLabel end, ref LReg retReg, While _while) {
	auto inst = new LInstList;
	inst += new LLocus (_while.token.locus);
	LLabel faux = new LLabel (), vrai = new LLabel, debut = new LLabel;
	this._endLabels [_while.block] = faux;
	LInstList left;
	inst += debut;
	__currentCondition__ = LPairLabel (vrai, faux) ;
	if (_while.info !is _while.test.info.type) {
	    if (_while.info.leftTreatment !is null)
		left = _while.info.leftTreatment (_while.info, _while.test, null);
	    else left = visitExpression (_while.test);
	    auto tlist = _while.info.lintInst (left);
	    inst += tlist;	    
	    inst += new LJump (tlist.getFirst (), vrai);
	    inst += new LGoto (faux);
	} else {
	    auto tlist = visitExpression (_while.test);
	    inst += tlist;
	    inst += new LJump (tlist.getFirst, vrai);
	    inst += new LGoto (faux);
	}
	__currentCondition__ = LPairLabel (null, null);
	vrai.insts = visitBlock (end, retReg, _while.block);
	vrai.insts += new LGoto (debut);
	vrai.insts.clean ();
	inst += vrai;
	inst += faux;
	this._endLabels.remove (_while.block);
	return inst;
    }

    private LInstList visitFor (ref LLabel _end, ref LReg retReg, For _for) {
	auto inst = new LInstList;
	inst += new LLocus (_for.token.locus);
	Array!Expression params;
	foreach (it ; _for.vars) {
	    params.insertBack (it);
	}
	
	_for.iter.info.type.lintInstS = _for.ret.lintInstS;
	auto left = _for.ret.leftTreatment (_for.ret, _for.iter,
					new ParamList (Word.eof, params));
	
	this._endLabels [_for.block] = cast (LLabel) left.back ();
	auto block = visitBlock (_end, retReg, _for.block);
	this._endLabels.remove (_for.block);
	inst = _for.ret.lintInst (left, block);
	
	foreach (it ; _for.dest) {
	    inst += it.destruct ();
	}

	return inst;
    }
    
    private LInstList visitElse (ref LLabel end, LLabel fin, ref LReg retReg, Else _else) {	
	if (cast(ElseIf) _else is null) {
	    auto inst =  visitBlock (end, retReg, _else.block);
	    if (fin !is null)
		inst += new LGoto (fin);
	    return inst;
	}
	auto elseif = cast(ElseIf)_else;
	auto insts = new LInstList;
	if (elseif.info.value) {
	    return visitElseIfWithValue (end, retReg, elseif);
	}
	insts += new LLocus (_else.token.locus);
	LLabel faux = new LLabel, vrai = new LLabel;
	LInstList left;
	__currentCondition__ = LPairLabel (vrai, faux);
	if (elseif.info !is elseif.test.info.type) {
	    if (elseif.info.leftTreatment !is null )
		left = elseif.info.leftTreatment (elseif.info, elseif.test, null);
	    else left = visitExpression (elseif.test);
	    auto tlist = elseif.info.lintInst (left);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	} else {
	    auto tlist = visitExpression (elseif.test);
	    insts += tlist;
	    insts += new LJump (tlist.getFirst (), vrai);
	}
	__currentCondition__ = LPairLabel (null, null);
	vrai.insts = visitBlock (end, retReg, elseif.block);
	vrai.insts += new LGoto (fin);
	if (elseif.else_ !is null) {
	    faux.insts = visitElse (end, fin, retReg, elseif.else_);
	} else faux.insts = new LInstList (new LGoto(fin));
	vrai.insts.clean ();
	faux.insts.clean ();
	insts += faux;
	insts += vrai;
	return insts;
    }
    
    private LInstList visitBreak (Break elem) {
	auto list = new LInstList;
	list += new LLocus (elem.token.locus);
	auto current = elem.father;
	ulong nb = 0;
	while (current !is null && nb < elem.nbBlock) {
	    foreach (it ; current.dest) {
		list += it.destruct ();
	    }
	    nb ++;
	    if (nb < elem.nbBlock)
		current = current.father;
	}
	elem.father.dest.clear ();
	auto endLabel = this._endLabels [current];
	list += new LGoto (endLabel);
	return list;
    }

    private LInstList visitAssert (Assert elem) {
	import utils.Options, std.format;
	Array!LExp exprs;
	Array!LInstList rights;
	LInstList list = new LInstList;
	auto it = (LVisitor.__AssertName__ in LFrame.preCompiled);
	if (it is null) LVisitor.createAssert ();	
	
	auto locMsg = "Program exited on assertion failure : ";
	if (Options.instance.isOn (OptionEnum.DEBUG)) {
	    locMsg ~= format ("%s(%d, %d) : ",
			      elem.token.locus.file,
			      elem.token.locus.line,
			      elem.token.locus.column);
	}

	LExp call;
	auto test = visitExpression (elem.expr);
	exprs.insertBack (test.getFirst ());
	auto str = visitStr (cast (String) (new String (elem.token, locMsg).expression));
	exprs.insertBack (str.getFirst ());
	list += test;
	list += str;
	if (elem.msg) {
	    auto msg = visitExpression (elem.msg);
	    exprs.insertBack (msg.getFirst ());
	    list += msg;
	} else {
	    exprs.insertBack (new LConstDecimal (0, LSize.LONG));
	}
	call = new LCall (LVisitor.__AssertName__, exprs, LSize.NONE);
	list += call;
	return list;
    }    
    
    private LInstList visitReturn (ref LLabel end, ref LReg retReg, Return ret) {
	LInstList list = new LInstList ();
	list += new LLocus (ret.token.locus);
	if (ret.elem !is null) {
	    LInstList rlist;
	    if (ret.instComp !is null) {
		if (ret.instComp.leftTreatment)
		    rlist = ret.instComp.leftTreatment (ret.elem.info.type, ret.elem, null);
		else rlist = visitExpression (ret.elem);
		list += ret.instComp.lintInst (rlist);
	    } else {
		rlist = visitExpression (ret.elem);
		list += rlist;
	    }
	    
	    if (!ret.instCast.type.isSame (ret.elem.info.type)) {		
		for (long nb = ret.instCast.type.lintInstS.length - 1; nb >= 0; nb --) {
		    list += ret.instCast.type.lintInst (list, nb);		
		}
	    }
	    list += (new LWrite (retReg,  list.getFirst ()));	    
	}
	
	foreach (it ; ret.father.dest) {
	    list += it.destruct ();
	}
	
	ret.father.dest.clear ();	
	list += new LGoto (end);
	return list;
    }

    static LInstList visitExpressionOutSide (Expression elem) {
	auto visitor = new LVisitor ();
	return visitor.visitExpression (elem);
    }
    
    private LInstList visitExpression (Expression elem) {
	if (auto bin = cast(Binary) elem) return visitBinary (bin);
	if (auto var = cast(Var)elem) return visitVar (var);
	if (auto _dec = cast(Decimal)elem) return visitDec (_dec);
	if (auto _float = cast(Float)elem) return visitFloat (_float);
	if (auto _char = cast(Char) elem) return visitChar (_char);
	if (auto _par = cast (Par) elem) return visitPar (_par);
	if (auto _cast = cast(Cast) elem) return visitCast (_cast);
	if (auto _str = cast(String) elem) return visitStr (_str);
	if (auto _access = cast (Access) elem) return visitAccess (_access);
	if (auto _dot = cast (Dot) elem) return visitDot (_dot);
	if (auto _bool = cast (Bool) elem) return visitBool (_bool);
	if (auto _unop = cast (BefUnary) elem) return visitBefUnary (_unop);
	if (auto _null = cast (Null) elem) return visitNull (_null);
	if (auto _carray = cast (ConstArray) elem) return visitConstArray (_carray);
	if (auto _crange = cast (ConstRange) elem) return visitConstRange (_crange);
	if (auto _fptr = cast (FuncPtr) elem) return visitFuncPtr (_fptr);
	if (auto _lambda = cast (LambdaFunc) elem) return visitLambda (_lambda);
	if (auto _tuple = cast (ConstTuple) elem) return visitConstTuple (_tuple);
	if (auto _exp = cast (Expand) elem) return visitExpand (_exp);
	if (auto _alloc = cast (ArrayAlloc) elem) return visitAlloc (_alloc);
	assert (false, "TODO, visitExpression ! " ~ elem.toString);
    }

    private LInstList visitConstTuple (ConstTuple _tuple) {
	Array!LExp exps;
	auto inst = new LInstList ();
	foreach (it; _tuple.params) {
	    inst += visitExpression (it);
	    exps.insertBack (inst.getFirst ());	    
	}

	string tupleName = Frame.mangle (_tuple.token.locus.file ~ _tuple.info.type.simpleTypeString ());
	
	auto it = (StructUtils.__CstName__ ~ tupleName in LFrame.preCompiled);
	if (it is null) {
	    StructUtils.createCstStruct (tupleName,
					 (cast (TupleInfo) _tuple.info.type).params);
	}

	it = (StructUtils.__DstName__ ~ tupleName in LFrame.preCompiled);
	if (it is null) {
	    StructUtils.createDstStruct (tupleName,
					 (cast (TupleInfo) _tuple.info.type).params);
	}
	
	if (_tuple.info.type.isDestructible) {
	    auto aux = new LReg (_tuple.info.id, _tuple.info.type.size);
	    inst += new LWrite (aux, new LCall (StructUtils.__CstName__ ~ tupleName,
						exps, LSize.LONG));
	    inst += aux;
	} else {
	    inst += new LCall (StructUtils.__CstName__ ~ tupleName, exps, LSize.LONG);
	}
	return inst;
    }
    
    private LInstList visitLambda (LambdaFunc _lmd) {
	auto inst = new LInstList;
	inst += new LConstFunc (_lmd.proto.name);
	return inst;
    }
    
    private LInstList visitFuncPtr (FuncPtr fptr) {
	auto inst = new LInstList;
	if (fptr.expr is null) {
	    inst += new LConstDecimal (0, LSize.LONG);
	} else {
	    auto ptr = cast (PtrFuncInfo) fptr.info.type;
	    inst += new LConstFunc (ptr.score.name);
	}
	return inst;
    }
    
    private LInstList visitAlloc (ArrayAlloc alloc) {
	auto type = cast (ArrayInfo) alloc.info.type;
	Array!LExp params;
	auto expInst = visitExpression (alloc.size);
	if (alloc.cster) {
	    for (long nb = alloc.cster.lintInstS.length - 1; nb >= 0; nb --) {
		expInst = alloc.cster.lintInst (expInst, nb);
	    }
	}
	
	auto exp = expInst.getFirst ();
	params.insertBack (new LBinop (new LConstDecimal (1, LSize.LONG, type.content.size),
				       exp,
				       Tokens.STAR));
	
	params.insertBack (new LConstDecimal (1, LSize.LONG, type.content.size));

	auto inst = new LInstList;	
	inst += expInst;
	
	auto aux = new LReg (alloc.info.id, type.size);
	if (!type.content.isDestructible) {
	    auto exist = (ArrayUtils.__CstName__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createCstArray ();
	    inst += new LWrite (aux, new LCall (ArrayUtils.__CstName__, params, LSize.LONG));
	} else {
	    auto exist = (ArrayUtils.__CstNameObj__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createCstArray (ArrayUtils.__DstArray__);
	    exist = (ArrayUtils.__DstArray__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createDstArray ();
	    inst += new LWrite (aux, new LCall (ArrayUtils.__CstNameObj__, params, LSize.LONG));
	}
	
	inst += aux;
	return inst;
    }

    private LInstList visitConstArray (ConstArray carray) {
	auto type = cast (ArrayInfo) carray.info.type;
	Array!LExp params;
	params.insertBack (new LConstDecimal (carray.params.length, LSize.LONG, type.content.size));
	params.insertBack (new LConstDecimal (1, LSize.LONG, type.content.size));
	
	auto inst = new LInstList;
	auto aux = new LReg (carray.info.id, type.size);
	if (!(cast (ArrayInfo)carray.info.type).content.isDestructible) {	    
	    auto exist = (ArrayUtils.__CstName__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createCstArray ();
	    inst += new LWrite (aux, new LCall (ArrayUtils.__CstName__, params, LSize.LONG));
	} else {
	    auto exist = (ArrayUtils.__CstNameObj__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createCstArray (ArrayUtils.__DstArray__);
	    exist = (ArrayUtils.__DstArray__ in LFrame.preCompiled);
	    if (exist is null) ArrayUtils.createDstArray ();
	    inst += new LWrite (aux, new LCall (ArrayUtils.__CstNameObj__, params, LSize.LONG));
	}
	
	foreach (it ; 0 .. carray.params.length) {
	    InfoType cster = carray.casters [it];
	    LInstList ret;
	    if (cster) {
		ret = visitExpression (carray.params [it]);
		for (long nb = cster.lintInstS.length - 1; nb >= 0; nb --) {		
		    ret = cster.lintInst (ret, nb);
		}
	    } else ret = visitExpression (carray.params [it]);
	    auto regRead = new LRegRead (aux,
					 new LBinop (new LConstDecimal (it, LSize.INT, type.content.size), new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS),
					 type.content.size);
	    
	    inst += cster.lintInst (new LInstList (regRead), ret);
	}
	inst += aux;
	return inst;
    }
    
    private LInstList visitConstRange (ConstRange crange) {
	auto type = cast (RangeInfo) crange.info.type;
	Array!LExp params;
	params.insertBack (new LConstDecimal  (1, LSize.LONG, crange.content.size));
	auto inst = new LInstList;
	auto aux = new LReg (crange.info.id, type.size);
	auto exist = (RangeUtils.__CstName__ in LFrame.preCompiled);
	if (exist is null) RangeUtils.createCstRange ();
	inst += new LWrite (aux, new LCall (RangeUtils.__CstName__, params, LSize.LONG));
	
	auto left = visitExpression (crange.left);
	auto right = visitExpression (crange.right);
	
	if (crange.lorr == 1) {
	    left = crange.caster.lintInst (left);
	} else if (crange.lorr == 2) {
	    right = crange.caster.lintInst (right);
	}
	
	auto regRead = new LRegRead (aux, new LConstDecimal (2, LSize.INT, LSize.LONG), type.content.size);
	inst += crange.content.lintInst (new LInstList (regRead), left);
	regRead = new LRegRead (aux, new LBinop (new LConstDecimal (2, LSize.INT, LSize.LONG),
						 new LConstDecimal (1, LSize.INT, type.content.size), Tokens.PLUS),
				type.content.size);
	
	inst += crange.content.lintInst (new LInstList (regRead), right);
	inst += aux;			      
	return inst;
    }
    

    private LInstList visitNull (Null _null) {
	return new LInstList (new LConstDecimal (0, LSize.LONG));
    }

    private LInstList visitBefUnary (BefUnary unary) {
	auto ret = visitExpression (unary.elem);
	for (long nb = unary.info.type.lintInstS.length - 1; nb >= 0; nb --) {
	    ret = unary.info.type.lintInst (ret, nb);
	}
	return ret;
    }
    
    private LInstList visitStr (String elem) {
	Array!LExp exps;
	exps.insertBack (new LConstDecimal (elem.content.length, LSize.LONG));
	exps.insertBack (new LConstString (elem.content));
	auto inst = new LInstList;
	auto it = (StringUtils.__CstName__ in LFrame.preCompiled);
	if (it is null) {
	    StringUtils.createCstString ();
	}
	if (elem.info.type.isDestructible) {
	    auto aux = new LReg (elem.info.id, elem.info.type.size);
	    inst += new LWrite (aux, new LCall (StringUtils.__CstName__, exps, LSize.LONG));
	    inst += aux;
	} else {
	    inst += new LCall (StringUtils.__CstName__, exps, LSize.LONG);
	}

	return inst;
    }
    
    private LInstList visitVar (Var elem) {
	return new LInstList (new LReg (elem.info.id, elem.info.type.size));
    }

    private LInstList visitBool (Bool elem) {
	if (elem.value) return new LInstList (new LConstDecimal (1, LSize.BYTE));
	else return new LInstList (new LConstDecimal (0, LSize.BYTE));
    }
    
    private LInstList visitChar (Char elem) {
	return new LInstList (new LConstDecimal (to!long (elem.code), LSize.BYTE));
    }

    private LInstList visitDec (Decimal _dec) {
	final switch (_dec.type.id) {
	case DecimalConst.BYTE.id : return new LInstList (new LConstDecimal (to!long (_dec.value), LSize.BYTE));
	case DecimalConst.UBYTE.id : return new LInstList (new LConstUDecimal (to!ulong (_dec.value), LSize.UBYTE));
	case DecimalConst.SHORT.id : return new LInstList (new LConstDecimal (to!long (_dec.value), LSize.SHORT));
	case DecimalConst.USHORT.id : return new LInstList (new LConstUDecimal (to!ulong (_dec.value), LSize.USHORT));
	case DecimalConst.INT.id : return new LInstList (new LConstDecimal (to!long (_dec.value), LSize.INT));
	case DecimalConst.UINT.id : return new LInstList (new LConstUDecimal (to!ulong (_dec.value), LSize.UINT));
	case DecimalConst.LONG.id: return new LInstList (new LConstDecimal (to!long (_dec.value), LSize.LONG));
	case DecimalConst.ULONG.id : return new LInstList (new LConstUDecimal (to!ulong (_dec.value), LSize.ULONG));
	}
    }
    
    private LInstList visitFloat (Float elem) {
	return new LInstList (new LConstDouble (to!double (elem.totale)));
    }

    private void visitParamListMult (ref Array!LExp exprs, ref Array!LInstList rights, Array!InfoType treat, ParamList params) {
	foreach (it ; 0 .. params.params.length) {
	    Expression exp = params.params [it];
	    LInstList elist = visitExpression (exp);
	    if (treat [it])
		for (long nb = treat [it].lintInstS.length - 1; nb >= 0; nb--) {
		    elist = treat [it].lintInst (elist, nb);
		}

	    rights.insertBack (elist);
	}
    }

    private LInstList visitExpand (Expand expand) {
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto inst = new LInstList;
	auto tupleInst = visitExpression (expand.expr);
	auto tuple = tupleInst.getFirst ();
	if (expand.index == 0) 
	    inst += tupleInst; // on ne construit le tuple que la premiere fois
	if (auto type = cast (TupleInfo) expand.expr.info.type) {	    	    
	    foreach (it ; 0 .. expand.index) {
		final switch (type.params [it].size.id) {
		case LSize.LONG.id: nbLong ++; break;
		case LSize.ULONG.id: nbUlong ++; break;
		case LSize.INT.id: nbInt ++; break;
		case LSize.UINT.id: nbUint ++; break;
		case LSize.SHORT.id: nbShort ++; break;
		case LSize.USHORT.id: nbUshort ++; break;
		case LSize.BYTE.id: nbByte ++; break;
		case LSize.UBYTE.id: nbUbyte ++; break;
		case LSize.FLOAT.id: nbFloat ++; break;
		case LSize.DOUBLE.id: nbDouble ++; break;
		}	    
	    }
	    
	    auto size = StructUtils.addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	    inst += new LRegRead (tuple, size, type.params[expand.index].size);
	    return inst;
	} else if (auto type = cast (StructInfo) expand.expr.info.type) {
	    foreach (it ; 0 .. expand.index) {
		final switch (type.params [it].size.id) {
		case LSize.LONG.id: nbLong ++; break;
		case LSize.ULONG.id: nbUlong ++; break;
		case LSize.INT.id: nbInt ++; break;
		case LSize.UINT.id: nbUint ++; break;
		case LSize.SHORT.id: nbShort ++; break;
		case LSize.USHORT.id: nbUshort ++; break;
		case LSize.BYTE.id: nbByte ++; break;
		case LSize.UBYTE.id: nbUbyte ++; break;
		case LSize.FLOAT.id: nbFloat ++; break;
		case LSize.DOUBLE.id: nbDouble ++; break;
		}	    
	    }
	    
	    auto size = StructUtils.addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	    inst += new LRegRead (tuple, size, type.params[expand.index].size);
	    return inst;
	} else assert (false, typeid (expand.expr).toString);
    }
           
    private LInstList visitParamList (ref Array!LExp exprs, Array!InfoType treat, ParamList params) {
	LInstList list = new LInstList;
	for (auto pit = 0, it = 0 ; pit < params.params.length ; it ++, pit ++) {
	    Expression exp = params.params [pit];
	    LInstList elist = visitExpression (exp);
	    if (treat [it]) {
		for (long nb = treat [it].lintInstS.length - 1; nb >= 0; nb --) {
		    elist = treat [it].lintInst (elist, nb);		    
		}
	    }	    
	    exprs.insertBack (elist.getFirst ());
	    list += elist;
	}	
	return list;
    }
    
    private LInstList visitPar (Par par) {
	Array!LExp exprs;
	Array!LInstList rights;
	LInstList list = new LInstList;
	LExp call;
	
	if (par.info.type.lintInstMult) {
	    visitParamListMult (exprs, rights, par.score.treat, par.paramList);
	    LInstList left;
	    if (par.info.type.leftTreatment)
		left = par.info.type.leftTreatment (par.info.type, par.left, par.paramList);
	    else left = visitExpression (par.left);
	    list = par.info.type.lintInst (left, rights);
	    call = list.getFirst ();
	} else {
	    list += visitParamList (exprs, par.score.treat, par.paramList);
	    if (par.score.dyn) {
		auto left = visitExpression (par.left);
		list += left;
		call = new LCall (left.getFirst (), exprs, par.score.ret.size, par.score.isVariadic);
	    } else {		
		call = new LCall (par.score.name, exprs, par.score.ret.size, par.score.isVariadic);
	    }
	}
	
	if (cast (VoidInfo) par.score.ret is null) {
	    auto reg = new LReg (par.info.id, par.score.ret.size);	    
	    list += new LWrite (reg, call);
	} else 	list += call;
	return list;	
    }

    private LInstList visitAccess (Access access) {
	Array!LInstList exprs;
	auto inst = new LInstList;
	foreach (it ; 0 .. access.params.length) {
	    exprs.insertBack (visitExpression (access.params [it]));
	}
	auto type = access.info.type;
	LInstList left;
	if (access.info.type.leftTreatment)
	    left = access.info.type.leftTreatment (access.info.type, access.left, null);
	else left = visitExpression (access.left);

	for (long nb = access.info.type.lintInstS.length - 1; nb >= 0; nb --) 
	    left = access.info.type.lintInst (left, nb); 
	
	inst += type.lintInst (left, exprs);
	return inst;
    }
    
    private LInstList visitDot (Dot dot) {
	LInstList left;
	if (dot.info.type.leftTreatment) {
	    left = dot.info.type.leftTreatment (dot.info.type, dot.left, null);
	} else left = visitExpression (dot.left);

	if (dot.info.type.lintInstS.length > 0) {
	    for (long nb = dot.info.type.lintInstS.length - 1; nb >= 0; nb --) {
		left = dot.info.type.lintInst (left, nb);
	    }
	}
	
	auto inst = dot.info.type.lintInst (LInstList.init, left);
	if (dot.info.isDestructible) {
	    auto sym = new LReg (dot.info.id, dot.info.type.size);
	    auto last = inst.getFirst ();
	    inst += new LWrite (sym, last);
	}
	return inst;
    }
    
    private LInstList visitCast (Cast elem) {
	auto left = elem.info.type;
	if (left is elem.expr.info.type) {
	    return visitExpression (elem.expr);
	} else {
	    return left.lintInst (visitExpression (elem.expr));
	}
    }
    
    private LInstList visitVarDecl (VarDecl elem) {
	LInstList inst = new LInstList;
	foreach (it ; elem.insts) {
	    inst += visitExpression (it);
	}
	return inst;
    }

    private LInstList visitBinary (Binary bin) {
	LInstList left, right;
	if (bin.info.type.value !is null) 
	    return bin.info.type.value.toLint(bin.info);
	
	if (bin.info.type.leftTreatment !is null) 
	    left = bin.info.type.leftTreatment (bin.info.type, bin.left, bin.right);
	else left = visitExpression (bin.left);

	for (long nb = bin.info.type.lintInstS.length - 1; nb >= 0; nb --) 
	    left = bin.info.type.lintInst (left, nb);
		
	if (bin.info.type.rightTreatment !is null)
	    right = bin.info.type.rightTreatment (bin.info.type, bin.left, bin.right);
	else right = visitExpression (bin.right);

	for (long nb = bin.info.type.lintInstSR.length - 1; nb >= 0; nb --)
	    right = bin.info.type.lintInstR (right, nb);
	
	auto ret = bin.info.type.lintInst (left, right);
	ret.back.locus = bin.token.locus;
	if (bin.info.isDestructible && bin.info.id != 0) {
	    auto last = ret.getFirst ();
	    auto reg = new LReg (bin.info.id, bin.info.type.size);
	    ret += new LWrite (reg, last);
	}
	auto inst = new LInstList (new LLocus (bin.token.locus));
	return inst + ret;
    }

}


