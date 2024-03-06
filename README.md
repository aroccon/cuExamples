
~~~text
     _________________________/\/\/\/\/\/\______________________________________________________/\/\___________________________
    ___/\/\/\/\__/\/\__/\/\__/\____________/\/\__/\/\__/\/\/\______/\/\/\__/\/\____/\/\/\/\____/\/\______/\/\/\______/\/\/\/\_ 
   _/\/\________/\/\__/\/\__/\/\/\/\/\______/\/\/\________/\/\____/\/\/\/\/\/\/\__/\/\__/\/\__/\/\____/\/\/\/\/\__/\/\/\/\___  
  _/\/\________/\/\__/\/\__/\/\____________/\/\/\____/\/\/\/\____/\/\__/\__/\/\__/\/\/\/\____/\/\____/\/\______________/\/\_   
 ___/\/\/\/\____/\/\/\/\__/\/\/\/\/\/\__/\/\__/\/\__/\/\/\/\/\__/\/\______/\/\__/\/\________/\/\/\____/\/\/\/\__/\/\/\/\___    
_______________________________________________________________________________/\/\_______________________________________     
                                                                                    
~~~



#### Snipsets of code that employ CUDA LIBRARIES in Fortran using openACC

Main developer: A. Roccon 

Current examples:
* 3D FFT of an 3D array in one shot (easy to extend to 1D or 2D)
* Use of cuSolverDN to solve a linear system (Dense)
* Use of cuSolverSP to solve a linear system (work in progress)

The bash files can be used to compile the different examples

The doc folder contains useful tutorials.
See also the book "Parallel Programming with OpenACC" by Rob Farber.