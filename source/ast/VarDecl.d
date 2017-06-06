module ast.VarDecl;
import ast.Instruction, ast.Var, ast.Expression;
import std.container, syntax.Word, utils.YmirException;
import semantic.pack.Table, semantic.pack.Symbol;
import std.stdio, std.string, std.outbuffer;
import semantic.types.UndefInfo, utils.exception;
import ast.Binary;

/**
 Cette classe est généré à la syntaxe par
 Example:
 ---
 'let' var ('=' expression)? (',' var ('=' expression)?)* ';'
 ---
 */
class VarDecl : Instruction {

    /// Les variables déclaré par l'instruction
    private Array!Var _decls;

    /// Les expressions à droite des variables déclarées.
    private Array!Expression _insts;

    /// Les décorateurs des variables
    private Array!Word _decos;
    
    this (Word word, Array!Word decos, Array!Var decls, Array!Expression insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
	this._decos = decos;
    }

    this (Word word) {
	super (word);
    }

    /**
     Vérification sémantique.
     Pour être correct, l'instruction ne doit déclarer que des variables qui n'existe pas.
     De plus les expressions droite doivent être correct et posséder un operateur d'affectation droite. (BinaryOpRight ('='));
     Throws: ErrorOccurs, si il y a eu des erreurs lors de l'analyse.
     */
    override Instruction instruction () {
	import syntax.Keys;
	auto auxDecl = new VarDecl (this._token);
	auto error = 0;
	ulong id = 0;
	foreach (it ; this._decls) {
	    try {
		auto aux = new Var (it.token);
		auto info = Table.instance.get (it.token.str);		
		if (info !is null && Table.instance.sameFrame (info)) throw new ShadowingVar (it.token, info.sym);
		
		if (this._decos [id] == Keys.IMMUTABLE) {
		    if (auto bin = cast (Binary) this._insts [id]) {
			auto type = bin.right.expression ();
			aux.info = new Symbol (aux.token, type.info.type.clone (), true);
			aux.info.value = type.info.type.value;
			if (!aux.info.isImmutable) throw new NotImmutable (this._insts [id].info);
			Table.instance.insert (aux.info);
			auxDecl._decls.insertBack (aux);
			this._insts [id] = null;
		    } else 
			throw new ImmutableWithoutValue (it.token);		    
		} else if (this._decos [id] == Keys.CONST) {
		    aux.info = new Symbol (aux.token, new UndefInfo (), false);		    
		    Table.instance.insert (aux.info);
		    auxDecl._decls.insertBack (aux);
		    if (auto bin = cast (Binary) this._insts [id]) {
			auxDecl._insts.insertBack (bin.expression ());
			auto var = aux.expression ();
			var.info.isConst = true;
		    } else 
			throw new ConstWithoutValue (it.token);		    
		} else if (this._decos [id] == Keys.STATIC) {
		    if (auto bin = cast (Binary) this._insts [id]) {
			auto type = bin.right.expression ();
			aux.info = new Symbol (aux.token, type.info.type.cloneForParam (), false);
			aux.info.staticValue = type.info.type.value;
			if (!aux.info.isStatic)
			    throw new NotImmutable (this._insts [id].info);

			Table.instance.insert (aux.info);
			auxDecl._decls.insertBack (aux);
			this._insts [id] = null;
		    } else throw new StaticWithoutValue (it.token);
		} else {
		    aux.info = new Symbol (aux.token, new UndefInfo (), false);
		    Table.instance.insert (aux.info);
		    auxDecl._decls.insertBack (aux);
		    if (this._insts [id])
			auxDecl._insts.insertBack (this._insts [id].expression ());
		    else
			auxDecl._insts.insertBack (null);
		}
		
		id ++;
	    } catch (RecursiveExpansion exp) {
		throw exp;
	    } catch (YmirException exp) {
		exp.print ();
		error ++;
		debug { throw exp; }
	    } catch (ErrorOccurs err) {
		error += err.nbError;		
	    }
	}

	if (error > 0) throw new ErrorOccurs (error);	
	return auxDecl;
    }

    override VarDecl templateReplace (Expression [string] values) {
	Array!Expression insts;
	auto decls = this._decls.dup ();
	foreach (it ; this._insts) {	    
	    insts.insertBack (it.templateExpReplace (values));
	}
	
	return new VarDecl (this._token, this._decos.dup(), decls, insts);
    }
    
    /**
     Returns: les expressions droites 
     */
    Array!Expression insts () {
	return this._insts;
    }

    Array!Var decls () {
	return this._decls;
    }
    
    /**
     Affiche l'instruction sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<VarDecl> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	
	foreach (it; this._decls) {
	    it.print (nb + 4);
	}

	foreach (it ; this._insts) {
	    it.print (nb + 4);
	}
    }
    
}
