# Importation de modules
<hr>

Ymir propose un système de module. Chaque fichier correspond à un module importable.
L'importation de module se fait avec la syntaxe.

```Rust
// Les chemins des fichiers sont relatif à l'emplacement de la compilation.  
import path.to.file, path.to.second.file; 

// importation du fichier $PWD/path/to/file.yr
// et importation du fichier $PWD/path/to/second/file.yr

```

Les imports de fichiers  ne sont pas récursifs.

 - test2.yr:

```Rust
def test () {
    println ("Hello World!!");
}
```
 - test.yr:

```Rust
import test2;
```
 - main.yr:

```Rust
import test;
 
def main () {
    test (); // erreur, la fonction test n'existe pas.
}
```


## Import public
-----------------

les imports dit publics, sont des imports récursifs.

 - test2.yr:

```Rust
def test () {
    println ("Hello World!!");
}
```
 - test.yr:

```Rust
public import test2;
```
 - main.yr:

```Rust
import test;

def main () {
    test (); // Ok, 'Hello World!!'
}
```


## Block privé et public
-------------------------

Les modules peuvent déclarer des blocks privés, ces blocks ne sont pas accessibles depuis les modules extérieurs.

- module1.yr

```Rust
private {

	def foo () {
		println ("Foo");
    }
     
}

def test () {
   foo ();
}
```

- module2.yr


```Rust
import module1;

foo (); // Erreur, foo n'existe pas
test (); // Ok, 'Foo'
```

 
Les fonctions externes et les imports sont privés par défaut, contrairement aux fonctions (pures ou impures) et aux structures.
