# Fonctions
<hr>

Les fonctions peuvent être déclarées sous trois formes.
<br>
- **Les fonctions pure :**

 Les fonctions pures sont des fonctions qui vont être compilées même si elles ne sont jamais appelées.
 Les types des variables ne sont pas inférés, mais sont écris explicitement.
 
 ```D
    def foo (a : int, b : int) {
     // ...
    }

    def foo2 () : int {
     // ...
    }
  ```

  Le type de retour des fonctions pures est optionnel, il sera déduit lors de la compilation.

<br>
- **Les fonctions impures :**

 Les fonctions impures se différencient des fonctions pures au niveau de leurs paramètres.
 Leurs types vont être inféré au moment de leurs appels.
 
  ```D
   def foo (a, b : int, c) { // a et c n'ont pas de type
     // ...
   } 

   // ...
   foo (10, 2, "salut"); // OK, avec a : int et c : string
   foo (10, 'salut', 1); // Erreur, b doit etre de type int
   ```
   Comme pour les fonctions pures, il n'est pas obligatoire de mettre le type de retour qui va être déduit.
 
   Les fonctions impures peuvent être utilisées pour des appels au nombre de paramètres variable (variadics).
   Un tuple est créé pour le dernier type, si il est non typé.

   ```D
   def test (a : int, b) {
       println (b.typeid);
   }

   def test (a, b : int) {
      println (a.typeid);
   }

   // ...
   test (1, 'r', 'salut'); // Ok, '(char, string)'.
   test (1); // Erreur, pas de surcharge de test applicable.
   test ('salut', 2, 3); // Erreur, On n'utilise pas la deuxieme surcharge 'b' est typé.
   ```

<br>
- **Les fonctions externes :**

 Les fonctions externes sont des fonctions qui n'ont pas de code, leur code doit être fourni au moment de l'édition des liens.
 Ces fonctions doivent être déclarées avec leurs types, ainsi que leur type de retour qui ne peut être déduit.

  ```D
   extern foo (a : int) : double;
   extern (C) putchar (c : char); // le type de retour n'est pas donné, _void_ par défaut.
    // ...
   let b = foo (10);
   putchar ('Y'); 
   ```

   Elles peuvent également être déclarées comme variadic.

    ```D
    extern (C) printf (a : ptr!char, ...)
    
    // ...
    printf (('salut %s, comment va tu ?').ptr, nom.ptr);```

   Les fonctions externes ne sont pas importées par défaut. Pour les importer il faut les déclarer comme publiques.

    ```D    
    public extern (C) putchar (c : char);
     ```

<br>
## Cas particuliers
--------------------
 - **Récursivité**

 Pour les fonctions récursives, il est obligatoire de mettre le type de retour de la fonction, s'il n'est pas déduit avant son appel.

 ``` D
  def fibo (n : int) {
     if (n < 2) return n; // n est de type _int_, le type de la fonction est _int_
     else return fibo (n - 1) + fibo (n - 2); // pas de problème le type de fibo a été déduit
  }

  def facto (n : int) {
    if (n >= 1) return facto (n - 1) * n; // Erreur, on ne connaît pas le type de facto
    else return 1;
  }
 ```

<br>
 - **Importation**

 Les fonctions pures importées qui ne contiennent pas de type de retour, seront considérées comme des fonctions externes void.

<br>
## Surcharge
-------------

Les fonctions peuvent être surchargées qu'elle soit pure ou non.
```D
def foo (a : int, b) {
// ...
}

def foo (a, b : int) {
// ...
}

//...
foo (10, 'salut'); // la première fonction est appelé
foo ('salut', 10); // la deuxième fonction est appelé
foo (10, 10); // Erreur, la surcharge fonctionne autant avec les deux prototypes.
```

<br>
## Fonctions internes
--------------------

Il est possible de déclarer une fonction dans un bloc. Celle-ci est alors privée à ce bloc.

```D

def foo () {
    {
       def test () {
            println ("Ici");
       }

       test (); // Ok, 'Ici'
     }

     test (); // Erreur, symbole inconnu test
}

def main () {
    test (); // Ok, 'La' (toutes les déclarations se font avant d'entrer dans le bloc)

    def test () { // Ok, cette fonction n'appartient pas au même bloc, elle peut être redéfinie
         println ("La");
    }
}

```

<br>
La surcharge fonctionne de la même manière avec les fonctions privées. Elles sont en concurrence avec les fonctions de scope plus large.
<br>

```D
def foo () {
}

def main () {
    def foo () {}

    foo (); // Erreur, impossible de déduire quelle fonction appelée.
}

```


<br>
## Pointeurs et fonction lambda
--------------------------------

Il est possible de récupérer l'adresse d'une fonction pour pouvoir l'utiliser comme une variable.
Pour cela il faut déclarer un pointeur sur fonction qui va spécialiser les paramètre de la fonction.

```D

def foo (a) {
    return a;
}


// ...
let a = function (int) : int (foo); // On créée un instance de foo qui prend un int en argument
let b = function (int) : int; // on affecte un pointeur null à b
if (b is null) { 
    b = a; 
}

a = foo; // Ok, on utilise l'instance de foo déjà créée
println (b (12)); // Ok, '12'

```

<br>
On peut spécialiser les fonctions afin qu'elles prennent un pointeur sur fonction en paramètre.

```D

def foo (ptr : function (int) : int) {
    return ptr (897);
}

def square (a : int) : int {
    return a * a;
}

// ...
foo (function (int) : int (square));

```

<br>
On peut également créer des fonctions anonymes (lambda).

```D
import std.string;

def foo (ptr : function (string) : string) {
    println (ptr ('Hello World'));
}

// ...
foo (function (str : string) : string {
	return str.substr (0u, 6u) + "Bob";
}); // Ok, 'Hello Bob'

```

<br>
## Appel par l'operateur '.'
-----------------------------


Les types non primitifs peuvent être utilisé comme premier paramètre en utilisant l'operateur '.'.

```D

def foo (str : string) {
    println (str);
}

def foo (str, fst) {
    println (str, fst);
}

//...
('salut').foo (); // Ok, 'salut'
('salut').foo (12); // Ok, 'salut12'

(2334).foo (12); // Erreur 2334 est de type primitif int.


```
<br>
# Fonction à nombre de paramètres arbitraire 
------------------------------

Ymir proposent un système d'appel de fonction à nombre de paramètre arbitraire. Cette solution est appelé Variadics. Cette solution est fortement lié au tuples. 

Pour le moment il n'existe aucune syntaxe particulière pour spécifié que le fonction est variadics. On déclare une fonction impure dont le dernier arguments n'a pas de type. Lors de l'appel la liste de paramètre va être généré en fonction des paramètres passé à la fonction.

```D
def foo (a) {
 // ...
}

//...
foo (1, 'i', "salut"); (on appel foo avec le type (tuple!(int, char, string)).

```
<br>
Le type 'tuple' n'est pas un type itérable, mais on peut récupérer ses attributs de manière récursive.
Le mot clé 'expand' va nous permettre de passer les attributs d'un tuple comme des paramètres de fonctions.

```D
def foo (count, a) {
    print (a.typeid, '(', a, ':', count, ') ');
}

def foo (count : int, a, b) {
    print (a.typeid, '(', a, ':',  count, ') ');
    foo (count + 1, expand (b)); // on transforme b en paramètre 
}

//...
foo (0, 1, 'r', "salut"); // Ok, 'int(1:0) char(r:1) string(salut:2)';

``` 



