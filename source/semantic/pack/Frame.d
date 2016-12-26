module semantic.pack.Frame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;


class Frame {

    protected Function _function;
    protected string _namespace;
    
    static long SAME = 10;
    static long AFF = 5;
    static long CHANGE = 7;
    
    this (string namespace, Function func) {
	this._function = func;
	this._namespace = namespace;
    }

    FrameProto validate () {
	assert (false);
    }

    FrameProto validate (ParamList params) {
	assert (false);
    }

    FrameProto validate (Array!InfoType params) {
	assert (false);
    }
    
    string namespace () {
	return this._namespace;
    }

    void verifyReturn (Word token, Symbol ret, FrameReturnInfo infos) {
	if (!(cast (VoidInfo) ret.type) && !(cast(UndefInfo) ret.type)) {
	    if (!infos.retract) {
		throw new NoReturnStmt (token, ret);
	    }
	}
    }
    
    ApplicationScore isApplicable (Array!InfoType params) {
	auto score = new ApplicationScore (this._function.ident);
	if (params.length == 0 && this._function.params.length == 0) {
	    score.score = AFF; return score;
	} else if (params.length == this._function.params.length) {
	    foreach (it ; 0 .. params.length) {
		auto param = this._function.params [it];
		InfoType info = null;
		if (cast (TypedVar) param !is null) {
		    info = (cast(TypedVar)param).getType ().clone ();
		    auto type = params [it].CompOp (info);
		    if (type && type.isSame (info)) {
			score.score += SAME;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);
		    } else return null;

		} else {
		    score.score += CHANGE;
		    score.treat.insertBack (null);
		}
	    }
	    return score;
	}
	return null;		
    }

    ApplicationScore isApplicable (ParamList params) {
	auto score = new ApplicationScore (this._function.ident);
	if (params.params.length == 0 && this._function.params.length == 0) {
	    score.score = 10; return score;
	} else if (params.params.length == this._function.params.length) {
	    foreach (it ; 0 .. params.params.length) {
		auto param = this._function.params [it];
		InfoType info = null;
		if (cast (TypedVar) param !is null) {
		    info = (cast(TypedVar)param).getType ().clone ();
		    auto type = params.params [it].info.type.CompOp (info);
		    if (type && type.isSame (info)) {
			score.score += SAME;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);
		    } else return null;

		} else {
		    score.score += CHANGE;
		    score.treat.insertBack (null);
		}
	    }
	    return score;
	}
	return null;
    }

    string mangle (string name) {
	string s = "";
	foreach (it ; name) {
	    if ((it < 'a' || it > 'z') && (it < 'A' || it > 'Z')) {
		s ~= to!string(to!short (it));
	    } else s ~= it;
	}
	return s;
    }

    Function func () {
	return this._function;
    }
    
}

class PureFrame : Frame {

    private string _name;
    private string _namespace;
    private FrameProto _fr;
    private bool valid = false;
    
    this (string namespace, Function func) {
	super (namespace, func);
	this._name = func.ident.str;
    }

    override FrameProto validate (ParamList) {
	return this.validate ();
    }

    override FrameProto validate (Array!InfoType) {
	return this.validate ();
    }
    
    override FrameProto validate () {
	if (!valid) {
	    valid = true;
	    string name = this._name;
	    if (this._name != "main") {
		name = this._namespace ~ to!string (this._name.length) ~ this._name;
		name = "_YN" ~ to!string (name.length) ~ name;
	    }
	    
	    Table.instance.enterFrame (name, this._function.params.length);
	    Table.instance.enterBlock ();
	    
	    Array!Var finalParams;
	    foreach (it ; 0 .. this._function.params.length) {
		auto info = this._function.params [it].expression;
		finalParams.insertBack (info);
		finalParams.back ().info.id = it + 1;
		auto t = finalParams.back ().info.type.typeString ();
		if (name != "main")
		    name ~= super.mangle (t) ~ to!string (to!short (' '));
	    }
	    	    
	    Table.instance.setCurrentSpace (name);
	
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    
	    this._fr = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	    Table.instance.retInfo.currentBlock = "true";
	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    auto finFrame =  new FinalFrame (Table.instance.retInfo.info,
				       name,
				       finalParams, block);
	    
	    this._fr.type = Table.instance.retInfo.info;
	    
	    FrameTable.instance.insert (finFrame);	
	    FrameTable.instance.insert (this._fr);

	    finFrame.file = this._function.ident.locus.file;
	    finFrame.dest = Table.instance.quitBlock ();
	    super.verifyReturn (this._function.ident,
				this._fr.type,
				Table.instance.retInfo);
	    
	    finFrame.last = Table.instance.quitFrame ();
	    return this._fr;
	}
	return this._fr;
    }    
    
}

class FinalFrame {

    private Symbol _type;
    private string _file;
    private string _name;
    private Array!Var _vars;
    private Array!Symbol _dest;
    private Block _block;
    private ulong _last;
    
    this (Symbol type, string name, Array!Var vars, Block block) {
	this._type = type;
	this._vars = vars;
	this._block = block;
	this._name = name;
	this._last = last;
    }
    
    string name () {
	return this._name;
    }

    ref string file () {
	return this._file;
    }
    
    Symbol type () {
	return this._type;
    }

    ref ulong last () {
	return this._last;
    }
    
    ref Array!Symbol dest () {
	return this._dest;
    }
    
    Array!Var vars () {
	return this._vars;
    }

    Block block () {
	return this._block;
    }
}


class FrameProto {
    private string _name;
    private Symbol _type;
    private Array!Var _vars;

    this (string name, Symbol type, Array!Var params) {
	this._name = name;
	this._type = type;
	this._vars = params;
    }

    ref string name () {
	return this._name;	
    }

    ref Symbol type () {
	return this._type;
    }

    ref Array!Var vars () {
	return this._vars;
    }       
}

