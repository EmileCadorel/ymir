module ast.LambdaFunc;
import ast.Expression, std.container;
import ast.Var, syntax.Word;
import semantic.types.InfoType, semantic.pack.Symbol;
import syntax.Tokens, syntax.Keys, utils.exception;
import ast.Block;
import semantic.pack.Frame;
import semantic.pack.Table, ast.Var;
import semantic.types.UndefInfo;
import semantic.types.VoidInfo;
import semantic.pack.FrameTable;
import semantic.pack.FrameProto;
import semantic.pack.FinalFrame;
import ast.Declaration, ast.Instruction, ast.Return;
import std.conv;

/**
 Classe genere par la syntaxe:
 Example:
 ---
 'function' '('type*')' ':' type block
 // ou
 '$' '(' type* ')' ':' type block
 ---
*/
class LambdaFunc : Expression {

    /** Les paramètres du lambda */
    private Array!Var _params;

    /** Le type de retour du lambda */
    private Var _ret;

    /** Le contenu du lambda */
    private Block _block;

    /***/
    private FrameProto _proto;

    /++ L'expression dans le cas de '=>' +/
    private Expression _expr;
    
    /** */
    private static ulong __last__;
    
    this (Word begin, Array!Var params, Var type, Block block) {
	super (begin);
	this._params = params;
	this._ret = type;
	this._block = block;	
    }

    this (Word begin, Array!Var params, Expression ret) {
	super (begin);
	this._params = params;
	this._expr = ret;
	this._expr.inside = this;
    }
   
    this (Word begin, Array!Var params, Block ret) {
	super (begin);
	this._params = params;
	this._block = ret;	
    }
        
    /** 
     Returns: le contenu de la lambda expression.
    */
    Block block () {
	return this._block;
    }

    /**
     Returns: le prototype du lambda
     */
    FrameProto proto () {
	return this._proto;
    }
    
    override Expression expression () {
	if (this._expr) return expressionWithExpr ();

	auto token = Word (this._token.locus, "lambda_" ~ to!string (getLast ()),false);
	
	auto space = Table.instance.namespace;
	Table.instance.enterFrame (space, token.str, this._params.length, true);
	Table.instance.enterBlock ();
	
	Expression [] temp;
	temp.length = this._params.length + 1;
	if (this._ret !is null)
	    temp [0] = this._ret.asType ();
	else temp [0] = null;
	
	foreach (it ; 0 .. this._params.length) {	    
	    if (auto t = cast(TypedVar) this._params [it])
		temp [it + 1] = new Type (t.type.token, t.getType ().clone ());
	    else throw new NeedAllType (this._params[it].token, "lambda");
	}
	
	Symbol retInfo = this._ret !is null ? this._ret.asType ().info : null;	
	auto finalParams = Frame.computeParams (this._params);
	this._proto = Frame.validate (token, space, space, retInfo, finalParams, this._block, make!(Array!Expression));
	
	if (temp [0] is null) {
	    temp [0] = new Type (token, this._proto.type.type.cloneForParam);
	}

	auto word = Word (this._token.locus, Keys.FUNCTION.descr, true);
	auto t_info = InfoType.factory (word, temp);

	auto ret = new LambdaFunc (this._token, finalParams, this._ret, block);
	ret._info = new Symbol (this._token, t_info, true);
	
	ret._proto = this._proto;
	return ret;
    }

    private Expression expressionWithExpr () {
	auto token = Word (this._token.locus, "lambda_" ~ to!string (getLast ()),false);
	
	auto space = Table.instance.namespace;
	Table.instance.enterFrame (space, token.str, this._params.length, true);
	Table.instance.enterBlock ();
	
	Expression [] temp;
	temp.length = this._params.length + 1;
	if (this._ret !is null)
	    temp [0] = this._ret.asType ();
	else temp [0] = null;
	
	foreach (it ; 0 .. this._params.length) {	    
	    if (auto t = cast(TypedVar) this._params [it])
		temp [it + 1] = new Type (t.type.token, t.getType ().clone ());
	    else throw new NeedAllType (this._params[it].token, "lambda");
	}
	
	Symbol retInfo = this._ret !is null ? this._ret.asType ().info : null;	
	auto finalParams = Frame.computeParams (this._params);
	auto inst = this._expr.expression;	
	if (cast (VoidInfo) inst.info.type is null) {
	    this._block = new Block (this._expr.token, make!(Array!Declaration),
				     make!(Array!Instruction) (new Return (this._expr.token, this._expr)));
	} else {
	    this._block = new Block (this._expr.token, make!(Array!Declaration),
				     make!(Array!Instruction) (this._expr));
	}
	
	this._proto = Frame.validate (token, space, space, retInfo, finalParams, this._block, make!(Array!Expression));
	
	if (temp [0] is null) {
	    temp [0] = new Type (token, this._proto.type.type.cloneForParam);
	}

	auto word = Word (this._token.locus, Keys.FUNCTION.descr, true);
	auto t_info = InfoType.factory (word, temp);

	auto ret = new LambdaFunc (this._token, finalParams, this._ret, block);
	ret._info = new Symbol (this._token, t_info, true);
	
	ret._proto = this._proto;
	return ret;
    }
        
    override Expression templateExpReplace (Expression [string] values) {
	Array!Var var;
	foreach (it ; this._params)
	    var.insertBack (cast (Var) it.templateExpReplace (values));
	
	auto ret = cast (Var) this._ret.templateExpReplace (values);
	auto block = this._block.templateReplace (values);
	return new LambdaFunc (this._token, var, ret, block);
    }

    override Expression clone () {
	Array!Var var;
	var.length = this._params.length;
	foreach (it ; 0 .. var.length)
	    var [it] = cast (Var) this._params [it].clone ();
	
	auto ret = cast (Var) this._ret.clone ();
	auto block = this._block;
	return new LambdaFunc (this._token, var, ret, block);
    }

    private ulong getLast () {
	__last__ ++;
	return __last__;
    }
    
    override string prettyPrint () {
	import std.outbuffer, semantic.types.PtrFuncInfo;
	auto buf = new OutBuffer ();
	buf.writef ("lambda (");
	foreach (it ; this._params)
	    buf.writef ("%s%s", it.prettyPrint, it !is this._params [$ - 1] ? ", " : ")");
	if (this._ret) 
	    buf.writef (" -> %s", this._ret.prettyPrint);
	else if (this._expr)
	    buf.writef (" => %s", this._expr.prettyPrint);
	else buf.writef (" -> %s", (cast (PtrFuncInfo) this._info.type).ret.typeString);

	return buf.toString ();
    }
    
}

