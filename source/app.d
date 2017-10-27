import std.stdio;
import ymir.compiler.Compiler;
import ymir.utils._;

void main (string [] args) {
    try {
	COMPILER.init (args);
	COMPILER.compile ();
    } catch (YmirException ymr) {
	ymr.print ();
	debug { throw ymr; }
    } catch (ErrorOccurs occurs) {
	occurs.print ();
	debug { throw occurs; }
    }
}
