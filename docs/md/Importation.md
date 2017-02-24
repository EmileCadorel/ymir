# Importation de modules
<hr>

Ymir propose un système de module. Chaque fichier correspond à un module importable.
L'importation de module se fait avec la syntaxe.

```D
// Les chemins des fichiers sont relatif à l'emplacement de la compilation.  
import path.to.file, path.to.second.file; 

// importation du fichier $PWD/path/to/file.yr
// et importation du fichier $PWD/path/to/second/file.yr

```

Les import de fichiers  ne sont pas récursif.

 - test2.yr:

 ```D
 def test () {
     println ("Hello World!!");
 }
 ```
 - test.yr:

 ```D
 import test2;
 ```
 - main.yr:

 ```D
 import test;

 def main () {
     test (); // erreur, la fonction test n'existe pas.
 }
 ```

<br>
## Import public
-----------------

les import dis public, sont des import récursif.


 - test2.yr:

 ```D
 def test () {
     println ("Hello World!!");
 }
 ```
 - test.yr:

 ```D
 public import test2;
 ```
 - main.yr:

 ```D
 import test;

 def main () {
     test (); // Ok, 'Hello World!!'
 }
 ```

<br>
## Block privée et public
-------------------------

Les modules peuvent déclarer des blocks privés, ces blocks ne sont pas accéssible depuis les modules exterieurs.

- module1.yr

```D
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


```D
import module1;

foo (); // Erreur, foo n'existe pas
test (); // Ok, 'Foo'
    ```

 <br>
Les fonctions externes et les imports sont privés par défaut, contrairement au fonctions (pure ou impure) et au structure.
