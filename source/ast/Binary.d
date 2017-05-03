module ast.Binary;
import ast.Expression;
import syntax.Word, ast.Var, semantic.pack.Symbol;
import semantic.types.InfoType, semantic.types.UndefInfo, syntax.Tokens;
import utils.exception;
import std.stdio, std.string, std.outbuffer, std.algorithm;
import std.container;
import semantic.pack.Table;
import syntax.Keys;
import ast.Constante, ast.ParamList;
import semantic.types.VoidInfo;

/***
 * Une operation entre deux expression
 * Example:
 ---
 * a op b
 ---
*/
class Binary : Expression {

    /// L'élément gauche de l'operateur
    private Expression _left;

    /// L'élément droit de l'operateur
    private Expression _right;

    /// Est un operateur droit (renseigné à la sémantique)
    private bool _isRight = false;
    
    this (Word word, Expression left, Expression right) {
	super (word);
	this._left = left;
	if (this._left) this._left.inside = this;
	this._right = right;
	if (this._right) this._right.inside = this;
    }

    this (Word word) {
	super (word);
    }

    /**
     Returns: l'operateur est un operateur droit
     */
    bool isRight () {
	return this._isRight;
    }
    
    /**
     * Verification semantique        
     */
    override Expression expression () {
	if (this._token == Tokens.EQUAL)
	    return affect ();
	else if (find ([Tokens.DIV_AFF, Tokens.AND_AFF, Tokens.PIPE_EQUAL,
			Tokens.MINUS_AFF, Tokens.PLUS_AFF, Tokens.LEFTD_AFF,
			Tokens.RIGHTD_AFF, Tokens.STAR_EQUAL,
			Tokens.PERCENT_EQUAL, Tokens.XOR_EQUAL,
			Tokens.DXOR_EQUAL, Tokens.TILDE_EQUAL], this._token) != []) 
	    return reaff ();
	else return normal ();
    }    

    /**
     * Verification particuliere pour l'operateur d'affectation qui peut affecter un type a une variable
     Throws: UseAsVar, NotLValue, UndefinedOp, UninitVar
     */
    private Expression affect () {
	auto aux = new Binary (this._token, this._left.expression (), this._right.expression);
	
	if (cast(Type)aux._left !is null) throw new UseAsVar (aux._left.token, aux._left.info);
	if (cast(Type)aux._right !is null) throw new UseAsVar (aux._right.token, aux._right.info);
	if (aux._right.info is null) throw new UndefinedOp (this._token, aux._left.info, new VoidInfo ());
	if (aux._left.info is null) throw new UndefinedVar (aux._left.token, Table.instance.getAlike (aux._left.token.str));	
	if (aux._left.info.isConst) throw new NotLValue (aux._left.token, aux._left.info);
	if (cast(UndefInfo)(aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	
	auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	if (type is null) {
	    if (cast (UndefInfo) (aux._left.info.type)) {
		type = aux._right.info.type.BinaryOpRight (this._token, aux._left);
		if (type is null)
		    throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
		
		aux._left.info.type = type;
		aux._left.info.isConst = false;
		aux._isRight = true;		
	    } else 
		  throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	}	
	aux.info = new Symbol (false, aux._token, type);
	Table.instance.retInfo.changed = true;
	return aux;
    }

    /**
     Pour les operateur particulier (+=, *= ...)
     Throws: UninitVar, UndefinedVar, UndefinedOp
     */
    private Expression reaff () {
	auto aux = new Binary (this._token);
	aux._right = this._right.expression ();
	aux._left = this._left.expression ();
	if (cast(Type) aux._left !is null) throw new UseAsVar (aux._left.token, aux._left.info);
	if (cast(Type)aux._right !is null) throw new UseAsVar (aux._right.token, aux._right.info);
	if (aux._right.info is null) throw new UndefinedVar (aux._right.token, Table.instance.getAlike (aux._right.token.str));
	if (aux._left.info is null) throw new UndefinedVar (aux._left.token, Table.instance.getAlike (aux._left.token.str));	
	if (aux._left.info.isConst) throw new NotLValue (aux._left.token, aux._left.info);
	if (cast (UndefInfo) (aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	else if (cast(UndefInfo) (aux._left.info.type) !is null) throw new UninitVar (aux._left.token);

	auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	if (type is null) {
	    type = aux._right.info.type.BinaryOpRight (this._token, aux._left);
	    if (type is null) 
		throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	    aux._isRight = true;
	}
	
	aux.info = new Symbol (aux._token, type);
	Table.instance.retInfo.changed = true;
	return aux;	
    }
    
    /**
     * Operation normale ou les types des deux operande doivent etre connu
     Throws: UninitVar, UndefinedVar, UndefinedOp
     */
    private Expression normal () {
	auto aux = new Binary (this._token);
	if (this._info is null) {
	    aux._right = this._right.expression ();
	    aux._right.inside = aux;
	    aux._left = this._left.expression ();
	    aux._left.inside = aux;
	    if (cast(Type)aux._left !is null) throw new UseAsVar (aux._left.token, aux._left.info);
	    if (cast(Type)aux._right !is null) throw new UseAsVar (aux._right.token, aux._right.info);
	    if (aux._right.info is null) throw new UndefinedVar (aux._right.token, Table.instance.getAlike (aux._right.token.str));
	    if (cast(UndefInfo)(aux._right.info.type) !is null) throw new UninitVar (aux._right.token);
	    if (aux._left.info is null) throw new UndefinedVar (aux._left.token, Table.instance.getAlike (aux._left.token.str));
	    if (cast(UndefInfo)(aux._left.info.type) !is null) throw new UninitVar (aux._left.token);
	    auto type = aux._left.info.type.BinaryOp (this._token, aux._right);
	    if (type is null) {
		type = aux._right.info.type.BinaryOpRight (this._token, aux._left);
		if (type is null) {
		    auto call = findOpBinary (aux);
		    if (!call)
			throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
		    else {
			//call.garbage ();
			return call;
		    }
		}
		aux._isRight = true;
	    }
	
	    aux.info = new Symbol (aux._token, type);
	} else {
	    if (this._info.isDestructible)
		Table.instance.garbage (this._info);
	    aux.info = this._info;
	}
	
	if (aux.info.value) {
	    aux.removeGarbage ();
	} 
	return aux;	
    }

    override Expression templateExpReplace (Array!Expression names, Array!Expression values) {
	auto left = this._left.templateExpReplace (names, values);
	auto right = this._right.templateExpReplace (names, values);
	return new Binary (this._token, left, right);
    }

    auto findOpBinary (Binary aux) {	
	import ast.Par;
	if (isTest (this._token)) return findOpTest (aux);
	else if (isEq (this._token)) return findOpEqual (aux);
	aux.removeGarbage ();
	try {
	    auto word = Word (this._token.locus, Keys.OPBINARY.descr, true);
	    auto var = new Var (word, make!(Array!Expression) (new String (this._token, this._token.str)));
	    
	    auto params = new ParamList (this._token, make!(Array!Expression) (this._left, this._right));
	    auto call = new Par (this._token, this._token, var, params);
	    return call.expression;
	} catch (YmirException) {
	    try {
		auto word = Word (this._token.locus, Keys.OPBINARYR.descr, true);
		auto var = new Var (word, make!(Array!Expression) (new String (this._token, this._token.str)));
		
		auto params = new ParamList (this._token, make!(Array!Expression) (this._right, this._left));
		auto call = new Par (this._token, this._token, var, params);
		return call.expression;
	    } catch (YmirException) {
		return null;
	    }
	}	
    }

    auto findOpTest (Binary aux) {
	import ast.Par, semantic.types.BoolInfo, semantic.types.DecimalInfo;
	aux.removeGarbage ();
	try {
	    auto word = Word (this._token.locus, Keys.OPTEST.descr, true);
	    auto var = new Var (word, make!(Array!Expression) (new String (this._token, this._token.str)));
	    
	    auto params = new ParamList (this._token, make!(Array!Expression) (this._left, this._right));
	    auto call = new Par (this._token, this._token, var, params);
	    auto ret = call.expression;
	    if (cast (BoolInfo) ret.info.type) return ret;
	    else if (auto dec = cast (DecimalInfo) (ret.info.type)) {		
		auto bin = new Binary (this._token);
		bin._left = ret;
		auto cst = Word (this._token.locus, "0", true);
		bin._right = new Decimal (cst, dec.type).expression ();
		bin.info = new Symbol (aux._token, bin.left.info.type.BinaryOp (this._token, bin.right));
		return bin;
	    } else return null;
	} catch (YmirException) {
	    return null;
	}
    }

    auto findOpEqual (Binary aux) {
	import ast.Par, semantic.types.BoolInfo, semantic.types.DecimalInfo;
	import ast.Unary;
	aux.removeGarbage ();
	try {
	    auto word = Word (this._token.locus, Keys.OPEQUAL.descr, true);
	    auto var = new Var (word);
	    
	    auto params = new ParamList (this._token, make!(Array!Expression) (this._left, this._right));
	    auto call = new Par (this._token, this._token, var, params);
	    if (this._token == Tokens.NOT_EQUAL) {
		auto word2 = Word (this._token.locus, Tokens.NOT.descr, true);
		return new BefUnary (word2, call).expression ();
	    } else {
		return call.expression;
	    }
	} catch (YmirException) {
	    try {
		auto word = Word (this._token.locus, Keys.OPEQUAL.descr, true);
		auto var = new Var (word);
		
		auto params = new ParamList (this._token, make!(Array!Expression) (this._right, this._left));
		auto call = new Par (this._token, this._token, var, params);
		if (this._token == Tokens.NOT_EQUAL) {
		    auto word2 = Word (this._token.locus, Tokens.NOT.descr, true);
		    return new BefUnary (word2, call).expression ();
		} else return call.expression;
	    } catch (YmirException) {
		return null;
	    }
	}
    }
    

    private bool isTest (Word token) {
	return (token == Tokens.INF || token == Tokens.SUP ||
		token == Tokens.INF_EQUAL || token == Tokens.SUP_EQUAL ||
		token == Tokens.NOT_INF || token == Tokens.NOT_SUP ||
		token == Tokens.NOT_INF_EQUAL || token == Tokens.NOT_SUP_EQUAL);
    }

    private bool isEq (Word token) {
	return (token == Tokens.DEQUAL || token == Tokens.NOT_EQUAL);
    }
    

    override Expression clone () {
	Expression left, right;
	if (this._left) left = this._left.clone ();
	if (this._right) right = this._right.clone ();
	    
	auto aux = new Binary (this._token, left, right);
	aux.info = this._info;
	return aux;
    }

    override void removeGarbage () {
	super.removeGarbage ();
	if (this._left)
	    this._left.removeGarbage ();
	if (this._right)
	    this._right.removeGarbage ();
    }

    override void garbage () {
	super.garbage ();
	if (this._left)
	    this._left.garbage ();
	if (this._right)
	    this._right.garbage ();
    }
    
    /**
     Returns: l'élément gauche de l'operateur
     */
    ref Expression left () {
	return this._left;
    }

    /**
     Returns: l'élément droit de l'operateur
     */
    ref Expression right () {
	return this._right;
    }

    /**
     Affiche l'expression sous forme d'arbre
     Params:
     nb = L'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Binary> : %s(%d, %d) %s  ", rightJustify("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);	

	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }

    override string prettyPrint () {
	import std.format;
	return format ("(%s %s %s)",
		      this._left.prettyPrint,
		      this._token.str,
		      this._right.prettyPrint);
    }
    
    
}
