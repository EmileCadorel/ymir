module utils.exception;
public import utils.YmirException;
import syntax.Word, semantic.pack.Symbol, std.outbuffer;

class UninitVar : YmirException {
    
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s: Variable non initialisé '%s%s%s' :", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	
	super.addLine (buf, token.locus);
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
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'est pas un template :", Colors.RED.value, Colors.RESET.value, Colors.GREEN.value, token.str, Colors.RESET.value);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	super.addLine (buf, token.locus);
	msg = buf.toString();        

    }
    
}

class UndefinedType : YmirException {
    this (Word token) {
	OutBuffer buf = new OutBuffer();
	buf.writef ("%sErreur%s: Le type %s'%s'%s n'existe pas :", Colors.RED.value, Colors.RESET.value, Colors.GREEN.value, token.str, Colors.RESET.value);
	buf.writefln ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);

	super.addLine (buf, token.locus);
	msg = buf.toString();        
    }
}
