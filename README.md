This repo is my project for poker. In this project I will simulate a poker game of five card stud using python, Java, Fortran, C#, and C++. Below I will detail how to run the programs for each language.

**PYTHON**
To run my first python code you can use the command line and type the following command 

python3 /home/sanku_h/fivecardstud/python/poker.py

this will automatically run the program and create the random shuffled decks and then identify the hands and rank them. 

If you want to use it with a specific test file which contains the hands pre made then you can run the following commandline promt.

python3 /home/sanku_h/fivecardstud/python/poker.py /home/sanku_h/fivecardstud/handsets/test1.txt

be cautios these command line prompts could be different from person to person based on the file path. as a general rule of thumb to only run the python code you do python3 followed by the path of where you phython file is located, and if you want do use a file you do the same command prompt to run the python code followed by the file path of the specific poker hand file.

**JAVA**
To run the java program you do javac poker.java to compile, and then java poker. To run with the file for the hands you still compile the same with javac poker.java, but when running the class you can pass an argument with it so it would be java poker handset.

**Fortran**
To run the fortran program you would do gfortran poker.f90, and this would create the executable name a.out. and then to run the executable you would simply run ./a.out. However if you wanted to run the code with the argument in the command line it would be ./a.out handset.

**C++**
To run the c++ program you would do g++ poker.cpp, and this would create the executable name a.out. and then to run the executable you would simply run ./a.out. However if you wanted to run the code with the argument in the command line it would be ./a.out handset.

**C#**
to run c# you would do mcs poker.cs to compile the code and this would create a .exe file. Yould would then run this .exe file like so, mono poker.exe. This will create the output. To run with the command line argument you would just do mono poker.exe handset.

**go**
to run the go code file navigate to the go directory. once in the correct directory run the command "go run poker.go" and it shpuld run properly. to run with command line run "go run poker.go [path to test hand]"

**julia**
to run the julia code go to the julia directory and then run the command "julia poker.jl" and to run with the test hand run the command "julia poker.jl [path to test hand]"

**lip**
to run the lisp code go to the lisp directory and then run the command "sbcl --script poker.lisp" and to run with the test hand run the command"sbcl --script poker.lisp [path to test hand]"

**perl**
to run the perl code go to the perl directory and run the command "perl poker.pl" and to run with the test hand run the command "perl poker.pl [path to test hand].

**rust**
to run the rust code go to the rust directory then run the command "rustc poker.rs" this should compile the code and then run the command "./poker" to run the code, and to run with the test hand just run "./poker [path to test hand]".