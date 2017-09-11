import std.stdio;
import ymir.compiler.Compiler;


void main (string [] args) {
    auto compiler = new Compiler (args);
    compiler.compile ();
}
