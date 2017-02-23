# Importation.

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

## Import public

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

