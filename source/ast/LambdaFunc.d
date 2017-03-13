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

    /** */
    private static ulong __last__;
    
    this (Word begin, Array!Var params, Var type, Block block) {
	super (begin);
	this._params = params;
	this._ret = type;
	this._block = block;
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
	string name = "_YP" ~ Table.instance.namespace () ~ "lambda";
		
	Table.instance.enterFrame (name, this._params.length);
	Table.instance.enterBlock ();
	
	Expression [] temp;
	temp.length = this._params.length + 1;
	temp [0] = this._ret.asType ();
	foreach (it ; 0 .. this._params.length) {	    
	    if (auto t = cast(TypedVar) this._params [it])
		temp [it + 1] = t.type ().asType ();
	    else throw new NeedAllType (this._params[it].token, "lambda");
	}
	
	auto t_info = InfoType.factory (this._token, temp);

	Array!Var finalParams;
	foreach (it ; 0 .. this._params.length) {
	    auto info = this._params [it].expression;
	    finalParams.insertBack (info);
	    finalParams.back.info.id = it + 1;
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    name ~= Frame.mangle (t);
	}

	auto ret = new LambdaFunc (this._token, finalParams, this._ret, this._block);
	ret._info = new Symbol (this._token, t_info, true);
	name ~= to!string (__last__++);
	
	
	Table.instance.setCurrentSpace (name);
	if (this._ret is null) {
	    Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	} else {
	    Table.instance.retInfo.info = this._ret.asType ().info;
	}
	
	this._proto = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	Table.instance.retInfo.currentBlock = "true";

	auto block = this._block.block ();

	if (cast (UndefInfo) (Table.instance.retInfo.info.type) !is null) {
	    Table.instance.retInfo.info.type = new VoidInfo ();
	}

	auto finFrame = new FinalFrame (Table.instance.retInfo.info,
					 name,
					 finalParams, block);

	this._proto.type = Table.instance.retInfo.info;
	FrameTable.instance.insert (finFrame);
	FrameTable.instance.insert (this._proto);

	finFrame.file = this._token.locus.file;
	finFrame.dest = Table.instance.quitBlock ();
	Frame.verifyReturn (this._token, this._proto.type, Table.instance.retInfo);
	finFrame.last = Table.instance.quitFrame ();



	ret._proto = this._proto;
	return ret;
    }
    
    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	Array!Var var;
	var.length = this._params.length;
	foreach (it ; 0 .. var.length)
	    var [it] = cast (Var) this._params [it].templateExpReplace (names, values);
	
	auto ret = cast (Var) this._ret.templateExpReplace (names, values);
	auto block = this._block.templateReplace (names, values);
	return new LambdaFunc (this._token, var, ret, block);
    }
    
}

