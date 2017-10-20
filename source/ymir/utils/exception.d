module ymir.utils.exception;
import ymir.utils._;
import ymir.syntax._;
import ymir.semantic._;
import ymir.ast._;

import std.outbuffer;
import std.container;
import std.format;

/**
 La variable est de type indéfinis mais est utilisé.
 */
class UninitVar : YmirException {

    /**
     Params:
     token = Le token de la variable
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Variable non initialisé '%s%s%s' :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

}

/**
 Le type x n'a pas d'attribut y
 */
class UndefinedAttribute : YmirException {

    /**
     Params:
     token = l'operateur '.'
     left = l'element de gauche
     right = l'element de droite
    */
    this (Word token, Symbol left, Var right) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Attribut '%s%s%s' non définis pour le type '%s%s%s' :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, right.token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	super.addLine (buf, right.token.locus);
	msg = buf.toString();        
    }    

    
    
}

/**
 La fonction se termine sans d'instruction 'return', mais ne retourne pas void
 */
class NoReturnStmt : YmirException {

    /**
     Params:
     token = l'identifiant de la fonction
     type = le type que la fonction doit retourner
     */
    this (Word token, Symbol type) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : La fonction '%s%s%s' ne retournant pas void se termine sans retourner '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, type.typeString, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }
}

class ReturnVoid : YmirException {

    this (Word token, Symbol type) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : Retour d'un élément de type '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, type.typeString, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }
}

/**
 Le char d'échappement x n'existe pas
 */
class UndefinedEscapeChar : YmirException {
    
    /**
     Params:
     token = emplacement de la chaine
     index = index dans la chaine
     elem = char qui n'existe pas
     */
    this (Word token, ulong index, string elem) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Escape char '%s%s%s' inconnu :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, elem, Colors.RESET.value);
	
	//token.locus.column += index;
	super.addLine (buf, token.locus, index, elem.length);
	msg = buf.toString();        
    }
    
}

/**
 L'operateur op n'existe pas entre les types x et y
 */
class UndefinedOp : YmirException {    
    /**
     Params:
     token = l'operateur
     left = l'element gauche
     right = l'element droit
     */
    this (Word token, Symbol left, Symbol right) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Operateur '%s%s%s' non définis entre les types '%s%s%s' et '%s%s%s' :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    /**
     Params:
     token = l'operateur
     left = l'element gauche
     right = l'element droit
     */
    this (Word token, Symbol left, InfoType right) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Operateur '%s%s%s' non définis entre les types '%s%s%s' et '%s%s%s' :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    /**
     Pour les operateurs unaire
     Params:
     token = l'operateur
     left = l'element
     */
    this (Word token, Symbol left) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Operateur '%s%s%s' non définis pour le type '%s%s%s' :",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    /**
     Pour les operateur multiple
     Params:
     token = l'operateur
     left = l'element de gauche
     right = l'element de droite
     */
    this (Word token, Symbol left, ParamList right) {
	
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Operateur '%s%s%s' non définis entre les types '%s%s%s' et (", Colors.RED.value, Colors.RESET.value,
		    Colors.YELLOW.value, token.str, Colors.RESET.value,
		    Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	
	foreach (it ; right.params) {
	    buf.writef ("%s%s%s",
			Colors.YELLOW.value, it.info.type.typeString (), Colors.RESET.value);
	    if (it !is right.params [$ - 1]) buf.writef (", ");
	}

	if (auto fun = cast(FunctionInfo) left.type) {
	    buf.writefln ("): ");
	    super.addLine (buf, token.locus);
	    foreach (key, value ; fun.candidates) {
		buf.writefln ("%sNote%s : %s", Colors.BLUE.value, Colors.RESET.value, value);
		super.addLine (buf, key.locus);
	    }
	} else {	
	    buf.writefln ("):");
	    super.addLine (buf, token.locus);
	}
	msg = buf.toString();        
    }

    /**
     Params:
     token = l'operateur
     token2 = la fin de l'operateur
     left = l'element de gauche
     right = l'element de droite
     */
    this (Word token, Word token2, Symbol left, ParamList right) {

	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Operateur '%s%s%s%s' non définis entre les types '%s%s%s' et (", Colors.RED.value, Colors.RESET.value,
		    Colors.YELLOW.value, token.str, token2.str, Colors.RESET.value,
		    Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	
	foreach (it ; right.params) {
	    buf.writef ("%s%s%s",
			Colors.YELLOW.value, it.info.type.typeString (), Colors.RESET.value);
	    if (it !is right.params [$ - 1]) buf.writef (", ");
	}
	
	if (auto fun = cast(FunctionInfo) left.type) {
	    buf.writefln ("): ");
	    super.addLine (buf, token.locus, token2.locus);
	    foreach (key, value ; fun.candidates) {
		buf.writefln ("%sNote%s : %s", Colors.BLUE.value, Colors.RESET.value, value);
		super.addLine (buf, key.locus);
	    }
	} else {	
	    buf.writefln ("):");
	    super.addLine (buf, token.locus);
	}

	msg = buf.toString();        
    }
    
    
}

/**
 Les types x et y ne sont pas compatible
 */
class IncompatibleTypes : YmirException {

    /**
     Params:
     left = le premier type
     right = le second type
     */
    this (Symbol left, Symbol right) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s: Les types '%s%s%s' et '%s%s%s' sont incompatible",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	super.addLine (buf, left.sym.locus);
	if (!right.sym.isEof) {
	    buf.writefln ("%sNote%s :", Colors.BLUE.value, Colors.RESET.value);
	    super.addLine (buf, right.sym.locus);
	}
	msg = buf.toString ();
    }    

    /**
     Params:
     left = le premier type
     right = le second type
     */
    this (Location locus, Symbol left, Symbol right) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s: Les types '%s%s%s' et '%s%s%s' sont incompatible",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	super.addLine (buf, left.sym.locus);
	if (!right.sym.isEof) {
	    buf.writefln ("%sNote%s :", Colors.BLUE.value, Colors.RESET.value);	    
	    super.addLine (buf, right.sym.locus);
	}
	buf.writefln ("%sNote%s : Pour l'instruction : ", Colors.BLUE.value, Colors.RESET.value);
	super.addLine (buf, locus);
	msg = buf.toString ();
    }    
   
    this (Symbol left, InfoType right) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s: Les types '%s%s%s' et '%s%s%s' sont incompatible",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	super.addLine (buf, left.sym.locus);
	msg = buf.toString ();	
    }
    

}

/**
 l'element x n'est pas une lvalue
 */
class NotLValue : YmirException {

    /**
     Params:
     token = l'identifiant de l'element
     type = le type de l'element
     */
    this (Word token, Symbol type) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: L'element '%s%s%s' de type '%s%s%s' n'est pas une lvalue :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, type.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}

/**
 L'instruction x n'est pas atteignable
 */
class UnreachableStmt : YmirException {

    /**
     Params:
     token = l'identifiant de l'instruction
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s : L'instruction '%s%s%s' n'est pas atteignable ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }
}

/**
 La variable x n'existe pas
 */
class UndefinedVar : YmirException {

    /**
     Params:
     token = l'identifiant de la variable
     */
    this (Word token, Symbol alike) {
	
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Variable inconnu '%s%s%s'", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	if (alike !is null) {
	    buf.writef (", peut être : '%s%s%s'", Colors.YELLOW.value, alike.sym.str, Colors.RESET.value);
	    if (cast (UndefInfo) alike.type is null)
		buf.writef (" du type '%s%s%s'", Colors.YELLOW.value, alike.typeString, Colors.RESET.value);
	}
	buf.writefln (" :");
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}

/**
 La variable x n'est pas un type
 */
class UseAsType : YmirException {

    /**
     Params:
     token = l'identifiant de la variable
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s : '%s%s%s' n'est pas un type ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
}

/**
 La variable x est un type
 */
class UseAsVar : YmirException {

    /**
     Params:
     token = l'identifiant de la variable
     info = le type de la variable
     */
    this (Word token, Symbol info) {
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s : '%s%s%s' est un type : '%s%s%s'", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, info.typeString, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }
    
}

class UseAsExp : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s : '%s%s%s' n'est pas une rvalue ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    
}


/**
 Utilisation d'une variable template comme type.
*/
class UseAsTemplateType : YmirException {

    this (Word token, Word token2) {
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s : '%s%s%s' est une variable template", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);

	buf.writefln ("%sNote%s : Définis ici : ", Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token2.locus);
	
	msg = buf.toString ();
    }
    
}



/**
 La variable x est déjà définis
 */
class ShadowingVar : YmirException {

    /**
     Params:
     token = l'identifiant de la variable
     token2 = l'identifiant de la première définition
     */
    this (Word token, Word token2) {
	OutBuffer buf = new OutBuffer;
	buf.writefln ("%sErreur%s : '%s%s%s' est déjâ definis ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);	
	buf.writefln ("%sNote%s : Première définition : ", Colors.BLUE.value, Colors.RESET.value);
	super.addLine (buf, token2.locus);
	msg = buf.toString();        
    }
}

/**
 L'identifiant de boucle x est déjà utilisé
 */
class MultipleLoopName : YmirException {

    /**
     Params:
     token = l'identifiant de boucle
     token2 = l'identifiant de la première définition
     */
    this (Word token, Word token2) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s : l'identifiant de boucle '%s%s%s' est déjâ definis ",
		      Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	
	buf.writefln ("%sNote%s : Première définition : ", Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token2.locus);
	msg = buf.toString();        
    }
}

/**
 Le type x n'est pas un template
 */
class NotATemplate : YmirException {

    /**
     Params:
     token = l'identifiant du type
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: L'élément %s'%s'%s n'est pas un template :", Colors.RED.value,
		      Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }   
    
    /**
     Params:
     token = l'identifiant du type
     */
    this (Word token, Array!Expression tmps) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Aucune spécialisation de template pour %s'%s'%s avec (", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	foreach (it ; tmps)
	    buf.writef ("%s%s%s%s", Colors.YELLOW.value,
			it.prettyPrint(),
			Colors.RESET.value, 
			it !is tmps [$ - 1] ? ", " : ") :\n");
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }   
}

/**
 Le type x n'existe pas
 */
class UndefinedType : YmirException {

    /**
     Params:
     token = l'identifiant du type
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Le type '%s%s%s' n'existe pas :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);

	super.addLine (buf, token.locus);
	this.msg = buf.toString();        
    }

    /**
     Params:
     token = l'identifiant du type
     msg = le message (exemple: 'prend 2 type en template')
     */
    this (Word token, string msg) {
	OutBuffer buf = new OutBuffer();
	buf.writefln ("%sErreur%s: Le type '%s%s%s' %s :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value, msg);

	super.addLine (buf, token.locus);
	this.msg = buf.toString();        
    }
    
}

/**
 La fonction ne retourne pas void mais on a trouvé 'return;'
 */
class NoValueNonVoidFunction : YmirException {

    /**
     Params:
     token = emplacement du retour
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer ();	
	buf.writefln ("%sErreur%s: La fonction ne retourne pas void :",
		    Colors.RED.value,
		    Colors.RESET.value);


	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }
}

/**
 Impossible de départager les définitions
 */
class TemplateSpecialisation : YmirException {

    /**
     Params:
     first = la première définition
     second = la seconde définition
     */
    this (Word first, Word second) {
	OutBuffer buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : la specialisation de template fonctionne avec '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, first.str, Colors.RESET.value);

	super.addLine (buf, first.locus);
	buf.writefln ("%sErreur%s : et '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, second.str, Colors.RESET.value);
	super.addLine (buf, second.locus);
	msg = buf.toString ();
    }
    
}

class NotImmutable : YmirException {

    /**
     Params:
     sym = le symbole dont on ne connait pas la valeur
     */
    this (Symbol sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : La valeur ne peut être connu à la compilation",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.sym.locus);
	msg = buf.toString ();
    }
    
}

class ImmutableWithoutValue : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : Déclaration d'une variable immutable sans valeur",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.locus);
	msg = buf.toString ();
    }
}


class ConstWithoutValue : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : Déclaration d'une variable constante sans valeur",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.locus);
	msg = buf.toString ();
    }
}


class StaticWithoutValue : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s : Déclaration d'une variable static sans valeur",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.locus);
	msg = buf.toString ();
    }
}


class StaticAssertFailure : YmirException {

    
    this (Word sym, string msg) {
	auto buf = new OutBuffer ();
	buf.writef ("%sErreur%s : Assertion Failure :",
		    Colors.RED.value, Colors.RESET.value);
	
	buf.writefln (" %s", msg);	
	super.addLine (buf, sym.locus);
	super.msg = buf.toString ();
    }
    
}


/**
 C'est une note.
 Les erreurs précédentes sont arrivées lors de la création de la fonction template x.
 */
class TemplateCreation : YmirException {

    /**
     Params:
     token = l'emplacement de l'appel
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer ();
	buf.writefln ("%sNote%s : Création de template : ", Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }

}

/**
 C'est une note.
 Les erreurs précédentes sont arrivées lors de la création du block mixin x.
 */
class MixinCreation : YmirException {

    /**
     Params:
     token = l'emplacement du mixin
     */
    this (Word token) {
	OutBuffer buf = new OutBuffer ();
	buf.writefln ("%sNote%s : Création de mixin : ", Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

}


/**
 La fonction utilise un type de retour qu'elle définis elle même.
 Example:
 ---
 def test (n) {
    return test (n - 1) + n;
 }
 ---
 */
class TemplateInferType : YmirException {

    /**
     Params:
     token = L'emplacement de l'appel
     func = La fonction impossible à déduire
     */
    this (Word token, Word func) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sError%s : Reference vers un type de retour deduis pour l'appel : ",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, token.locus);

	buf.writefln ("%sNote%s : type deduis de la fonction :",
		      Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, func.locus);	
	msg = buf.toString ();
    }
}

/**
 La définition de x nécessite la connaissance de tout les types.
 */
class NeedAllType : YmirException {

    /**
     Params:
     token = l'emplacement de la définition
     type = le type de définition
     */
    this (Word token, string type = "fonction") {
	auto buf = new OutBuffer ();
	buf.writefln ("%sError%s : Tous les types sont requis dans une prototype de %s : ",
		      Colors.RED.value, Colors.RESET.value, type);
	super.addLine (buf, token.locus);
	
	msg = buf.toString ();
    }
}

/**
 X doit être uniquement un type
 */
class OnlyTypeNeeded : YmirException {

    /**
     Params:
     token = l'emplacement de la définition
     */
    this (Word token) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sError%s : Pas d'indentifiant de variable requis dans une prototype de ptr!function : ",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, token.locus);
	
	msg = buf.toString ();
    }
}


/**
 on a trouvé un break en dehors d'un scope 'breakable'.
 */
class BreakOutSideBreakable : YmirException {

    /**
     Params:
     token = l'emplacement du break;
     */
    this (Word token) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sError%s : Break en dehors d'un scope breakable",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }
}

/**
 l'identifiant de boucle x n'existe pas.
*/
class BreakRefUndefined : YmirException {

    /**
     Params:
     token = l'emplacement du break;
     name = l'identifiant de boucle
     */
    this (Word token, string name) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sError%s : l'identifiant de boucle '%s%s%s' n'existe pas",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, name, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }
}

/**
 Division par zero.
*/
class FloatingPointException : YmirException {

    /**
     Params:
     locus = l'emplacement de la division
     */
    this (Location locus) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s Division par zero ", Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, locus);
	msg = buf.toString ();
    }
    

}

class ImportError : YmirException {

    /**
     Params: 
     locus = l'identifiant de l'import
     */
    this (Word locus) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s Fichier importe illisible '%s%s.yr%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, locus.str, Colors.RESET.value);
	
	super.addLine (buf, locus.locus);
	msg = buf.toString ();
    }
    
}


/**
 On tente d'étendre un type qui n'est pas un tuple. 
 */
class ExpandNonTuple : YmirException {

    /**
     Params:
     locus = l'identifiant du expand.
     type = le type que l'on tente d'étendre.
     */
    this (Word locus, Symbol type) {
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s: Impossible de développer un type '(%s%s%s)', le type doit être un tuple",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, type.typeString, Colors.RESET.value);

	super.addLine (buf, locus.locus);
	msg = buf.toString ();
    }
    
}


class OutOfRange : YmirException {

    this (Symbol sym, ulong id, ulong length) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Index %d en dehors du range [0 .. %d]",
		      Colors.RED.value, Colors.RESET.value,
		      id, length);
	super.addLine (buf, sym.sym.locus);
	msg = buf.toString ();
    }    
}

class CapacityOverflow : YmirException {

    this (Symbol sym, string val) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Dépassement de capacité du type '%s%s%s', '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, sym.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, val, Colors.RESET.value
	);
	super.addLine (buf, sym.sym.locus);
	msg = buf.toString ();
    }
    
}

class WrongTypeForMain : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: La fonction main doit être main ([string]) ou main ()",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.locus);
	msg = buf.toString ();
    }

    
}

class RecursiveExpansion : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Nombre d'expansion récursive statique atteinte",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.locus);
	msg = buf.toString ();	
    }

}


class NoValueMatch : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Le block n'est pas une expression ",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, sym.locus);
	msg = buf.toString;
    }

}

class NotDefaultMatch : YmirException {

    this (Word sym) {
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Pas de cas par défaut dans une expression %smatch%s ",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value
	);
	
	super.addLine (buf, sym.locus);
	msg = buf.toString;
    }       

}

class DestOfNonTuple : YmirException {

    this (Symbol sym) {
	auto loc = sym.sym.locus;
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Impossible de destructurer un élément de type %s%s%s, on a besoin d'un %stuple%s ",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, sym.type.typeString, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value
	);

	super.addLine (buf, loc);
	msg = buf.toString;
    }

    this (ulong len, ulong len2, Symbol sym) {	
	auto loc = sym.sym.locus;
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Impossible de destructurer, les tailles diffèrent %s%d%s, %s%d%s",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, len, Colors.RESET.value,
		      Colors.YELLOW.value, len2, Colors.RESET.value
	);

	super.addLine (buf, loc);
	msg = buf.toString;
    }

    

}

class CannotRefEnum : YmirException {

    this (Word token) {
	auto loc = token.locus;
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Impossible de prendre une réference vers un type %senum%s ",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value
	);

	super.addLine (buf, loc);
	msg = buf.toString;
    }
}

class RecursiveCreation : YmirException {
    this (Word token) {
	auto loc = token.locus;
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s: La construction de la structure '%s%s%s', dépend d'elle même",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);

	super.addLine (buf, loc);
	msg = buf.toString;
    }
    
}

class ImplementUnknown : YmirException {
    this (Word token, Symbol alike) {
	auto loc = token.locus;
	auto buf = new OutBuffer;
	buf.writef ("%sErreur%s: Implémentation d'un élément inconnu '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	if (alike !is null)
	    buf.writef (", peut être : '%s%s%s'", Colors.YELLOW.value, alike.sym.str, Colors.RESET.value);
	
	buf.writefln ("");		
	super.addLine (buf, loc);
	msg = buf.toString;
    }    
}

class ImplMethodNotPure : YmirException {
    this (Word token) {
	auto loc = token.locus;
	auto buf = new OutBuffer;
	buf.writefln ("%sErreur%s: Les méthodes d'une implémentation doivent être pure '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	
	super.addLine (buf, loc);
	msg = buf.toString;
    }    
}


class ImplementNotLocal : YmirException {
    this (Word token, Symbol sym) {
	auto loc = token.locus;
	auto buf = new OutBuffer ();
	buf.writefln ("%sErreur%s: Implémentation d'un élément d'un module externe '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	super.addLine (buf, loc);
	
	buf.writefln ("%sNote%s :", Colors.BLUE.value, Colors.RESET.value);
	super.addLine (buf, sym.sym.locus);
	msg = buf.toString;	
    }
}


class ImplementNotStruct : YmirException {
    this (Word token, Symbol sym) {
	auto buf = new OutBuffer;
	auto loc = sym.sym.locus;
	buf.writefln ("%sErreur%s: Implémentation d'un élément qui n'est pas une structure '%s%s%s'",
		    Colors.RED.value, Colors.RESET.value,
		    Colors.YELLOW.value, sym.sym.str, Colors.RESET.value
	);
	super.addLine (buf, loc);
	
	buf.writefln ("%sNote%s :", Colors.BLUE.value, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString;
    }
}

class InHeritError : YmirException {
    this (Word token) {
	auto buf = new OutBuffer;
	auto loc = token.locus;
	buf.writefln ("%sErreur%s: On ne peut hériter que d'%simpl%s ou de %strait%s pas de '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	
	super.addLine (buf, loc);	
	msg = buf.toString;
    }
}

class ImplicitOverride : YmirException {

    this (Word token, Word token2) {
	auto buf = new OutBuffer;
	auto loc = token.locus;
	buf.writefln ("%sErreur%s: Surcharge implicite de la méthode '%s%s%s', utilisez le mot clé '%sover%s' au lieu de '%sdef%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value,
		      Colors.YELLOW.value, Colors.RESET.value
	);
	super.addLine (buf, loc);	
	buf.writefln ("%sNote%s: ",
		      Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token2.locus);	
	msg = buf.toString;
    }    
}

class NoOverride : YmirException {
    
    this (Word token) {
	auto buf = new OutBuffer;
	auto loc = token.locus;
	buf.writefln ("%sErreur%s: La méthode '%s%s%s' ne surcharge personne",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	
	super.addLine (buf, loc);	
	msg = buf.toString;
    }

    this (Word token, InfoType info, Word tok2) {
	auto buf = new OutBuffer;
	auto loc = token.locus;
	buf.writefln ("%sErreur%s: La méthode '%s%s%s' ne surcharge personne",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	
	super.addLine (buf, loc);

	if (info !is null) {
	    buf.writefln ("%sNote%s: %s",
			  Colors.BLUE.value, Colors.RESET.value,
			  info.typeString);
	    super.addLine (buf, tok2.locus);
	}
	
	msg = buf.toString;
    }    
    
}

class OverrideNotPure : YmirException {
    this (Word token) {
	auto buf = new OutBuffer;
	auto loc = token.locus;
	buf.writefln ("%sErreur%s: Impossible de surcharger un méthode impure '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	
	super.addLine (buf, loc);	
	msg = buf.toString;
    }

    this (Word token, Word) {
	auto buf = new OutBuffer;
	auto loc = token.locus;
	buf.writefln ("%sErreur%s: Impossible de surcharger avec une méthode impure '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value
	);
	
	super.addLine (buf, loc);	
	msg = buf.toString;
    }    
    
}


class UnknownTarget : YmirException {
    this (string op) {
	msg = format ("%sErreur%s: %s n'est pas une cible valide",
		      Colors.RED.value, Colors.RESET.value,
		      op
	);	
    }   
}

class UnknownLint : YmirException {
    this (string op) {
	msg = format ("%sErreur%s: %s n'est pas un langage intermediaire valide",
		      Colors.RED.value, Colors.RESET.value,
		      op
	);	
    }   
}

class NamespaceConflict : YmirException {
    this (Namespace space) {
	msg = format ("%sErreur%s : Utilisation d'un fichier comme sous paquet : %s",
		      Colors.RED.value, Colors.RESET.value,
		      space
	);
    }    
}
