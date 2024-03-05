
~~~text
 ▄████▄   █    ██ ▓█████ ▒██   ██▒ ▄▄▄       ███▄ ▄███▓ ██▓███   ██▓    ▓█████   ██████ 
▒██▀ ▀█   ██  ▓██▒▓█   ▀ ▒▒ █ █ ▒░▒████▄    ▓██▒▀█▀ ██▒▓██░  ██▒▓██▒    ▓█   ▀ ▒██    ▒ 
▒▓█    ▄ ▓██  ▒██░▒███   ░░  █   ░▒██  ▀█▄  ▓██    ▓██░▓██░ ██▓▒▒██░    ▒███   ░ ▓██▄   
▒▓▓▄ ▄██▒▓▓█  ░██░▒▓█  ▄  ░ █ █ ▒ ░██▄▄▄▄██ ▒██    ▒██ ▒██▄█▓▒ ▒▒██░    ▒▓█  ▄   ▒   ██▒
▒ ▓███▀ ░▒▒█████▓ ░▒████▒▒██▒ ▒██▒ ▓█   ▓██▒▒██▒   ░██▒▒██▒ ░  ░░██████▒░▒████▒▒██████▒▒
░ ░▒ ▒  ░░▒▓▒ ▒ ▒ ░░ ▒░ ░▒▒ ░ ░▓ ░ ▒▒   ▓▒█░░ ▒░   ░  ░▒▓▒░ ░  ░░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░
  ░  ▒   ░░▒░ ░ ░  ░ ░  ░░░   ░▒ ░  ▒   ▒▒ ░░  ░      ░░▒ ░     ░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░
░         ░░░ ░ ░    ░    ░    ░    ░   ▒   ░      ░   ░░         ░ ░      ░   ░  ░  ░  
░ ░         ░        ░  ░ ░    ░        ░  ░       ░                ░  ░   ░  ░      ░  
░                                                                                       
~~~



#### Snipsets of code that employ CUDA LIBRARIES integrated in Fortran + openACC

Main developer: A. Roccon 

Current examples:
* 3D FFT of an 3D array in one shot (easy to extend to 1D or 2D)
* Use of cuSolverDN to solve a linear system (Dense)
* Use of cuSolverSP to solve a linear system (work in progress, no interface present)

The bash files can be used to compile the different examples