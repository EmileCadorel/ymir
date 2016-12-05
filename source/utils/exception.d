module utils.exception;
public import utils.YmirException;
import syntax.Word, semantic.pack.Symbol, std.outbuffer, ast.ParamList;
import ast.Var;

class UninitVar : YmirException {
    
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Variable non initialisé '%s%s%s' :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

}

class UndefinedAttribute : YmirException {

    this (Word token, Symbol left, Var right) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Attribut '%s%s%s' non définis pour le type '%s%s%s' :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, right.token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }    
    
}

class UndefinedEscapeChar : YmirException {

    this (Word token, ulong index, string elem) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Escape char '%s%s%s' inconnu :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, elem, Colors.RESET.value);
	
	//token.locus.column += index;
	super.addLine (buf, token.locus, index, elem.length);
	msg = buf.toString();        
    }
    
}


class UndefinedOp : YmirException {

    this (Word token, Symbol left, Symbol right) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Operateur '%s%s%s' non définis entre les types '%s%s%s' et '%s%s%s' :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value,
		      Colors.YELLOW.value, right.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    this (Word token, Symbol left) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Operateur '%s%s%s' non définis pour le type '%s%s%s' :",
		      Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    
    this (Word token, Symbol left, ParamList right) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writef ("%sErreur%s: Operateur '%s%s%s' non définis entre les types '%s%s%s' et (", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, left.typeString (), Colors.RESET.value);
	
	foreach (it ; right.params) {
	    buf.writef ("%s%s%s",
			Colors.YELLOW.value, it.info.type.typeString (), Colors.RESET.value);
	    if (it !is right.params [$ - 1]) buf.writef (", ");
	}
	
	buf.writefln ("):");	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    
}


class NotLValue : YmirException {

    this (Word token, Symbol type) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: L'element '%s%s%s' de type '%s%s%s' n'est pas une lvalue :", Colors.RED.value, Colors.RESET.value,
		      Colors.YELLOW.value, token.str, Colors.RESET.value,
		      Colors.YELLOW.value, type.typeString (), Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}


class UnreachableStmt : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer;
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s : L'instruction '%s%s%s' n'est pas atteignable ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }
}


class UndefinedVar : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Variable inconnu '%s%s%s' :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}

class UseAsType : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer;
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s : '%s%s%s' n'est pas un type ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
}


class ShadowingVar : YmirException {
    this (Word token, Word token2) {
	OutBuffer buf = new OutBuffer;
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s : '%s%s%s' est déjâ definis ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	super.addLine (buf, token.locus);
	
	buf.writef ("%s:(%d,%d): ", token2.locus.file, token2.locus.line, token2.locus.column);
	buf.writefln ("%sNote%s : Première définition : ", Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token2.locus);
	msg = buf.toString();        
    }
}


class NotATemplate : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'est pas un template :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }
    
}

class UndefinedType : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'existe pas :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);

	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }

    this (Word token, string elem) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s %s :", Colors.RED.value, Colors.RESET.value, Colors.GREEN.value, token.str, Colors.RESET.value, elem);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);

	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
    
}

class NoValueNonVoidFunction : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("%sErreur%s: La fonction ne retourne pas void :",
		    Colors.RED.value,
		    Colors.RESET.value);
	buf.writefln ("%s:(%d,%d): ",
		      token.locus.file, token.locus.line, token.locus.column);

	super.addLine (buf, token.locus);
	msg = buf.toString ();
    }

}

class TemplateSpecialisation : YmirException {

    this (Word first, Word second) {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("%s(%d,%d): ", first.locus.file, first.locus.line, first.locus.column);
	buf.writefln ("%sErreur%s : la specialisation de template fonctionne avec '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, first.str, Colors.RESET.value);

	super.addLine (buf, first.locus);
	buf.writef ("%s:(%d,%d): ", second.locus.file, second.locus.line, second.locus.column);
	buf.writefln ("%sErreur%s : et '%s%s%s'",
		      Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, second.str, Colors.RESET.value);
	super.addLine (buf, second.locus);
	msg = buf.toString ();
    }
    
}


class TemplateCreation : YmirException {

    this (Word token) {
	OutBuffer buf = new OutBuffer ();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sNote%s : Création de template : ", Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }

}

class TemplateInferType : YmirException {
    this (Word token, Word func) {
	auto buf = new OutBuffer ();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sError%s : Reference vers un type de retour deduis pour l'appel : ",
		   Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, token.locus);

	buf.writef ("%s:(%d,%d): ", func.locus.file, func.locus.line, func.locus.column);
	buf.writefln ("%sNote%s : type deduis de la fonction :",
		      Colors.BLUE.value, Colors.RESET.value);
	
	super.addLine (buf, func.locus);	
	msg = buf.toString ();
    }
}

class NeedAllType : YmirException {
    this (Word token) {
	auto buf = new OutBuffer ();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sError%s : Tous les types sont requis dans une prototype de fonction : ",
		      Colors.RED.value, Colors.RESET.value);
	super.addLine (buf, token.locus);
	
	msg = buf.toString ();
    }
}
