## Fonctions

Les fonctions peuvent être déclarées sous trois formes.
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
    printf (('salut %s, comment va tu ?').ptr, nom.ptr);
    ```


 Les fonctions externes ne sont pas importées par défaut. Pour les importer il faut les déclarer comme publiques.

 ```D
 public extern (C) putchar (c : char);
 ```

## Cas particuliers.

 - Récursivité.

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
 - Import

 Les fonctions pures importées qui ne contiennent pas de type de retour, seront considérées comme des fonctions externes void.


## Surcharge

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

## Fonctions internes

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

La surcharge fonctionne de la même manière avec les fonctions privées. Elles sont en concurrence avec les fonctions de scope plus large.

```D
def foo () {
}

def main () {
    def foo () {}

    foo (); // Erreur, impossible de déduire quelle fonction appelée.
}

```

