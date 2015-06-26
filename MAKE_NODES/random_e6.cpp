#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <fstream>

#define END_SCALE       4294967296.0F

#define DIM     2                       //Primi vicini mezzi
#define L       4096                    //Dimensione del reticolo
#define BLOCKL  32                      //Threads per blocco
#define GRIDL   (L/BLOCKL)              //N. Blocchi lineari (per colonna?) 
#define BLOCKS  ((GRIDL*GRIDL)/2)       //N. Blocchi totali nel reticolo
#define THREADS ((BLOCKL*BLOCKL)/2)     //N. Threads per blocco
#define TOT_TH  (BLOCKS*THREADS)        //N. 

using namespace std;

int main(){
	fstream uscita;
	uscita.open("nodi_passo_E6.dat",ios::out);
	//uscita<<"x\t"<<"y\t"<<"z\t"<<"w\t"<<"t\t"<<endl;

	int passo=100000000;
	unsigned int x=1, y=2, z=3, w=4, t=5;
	for(int i=1;; i++){
		t = x^x<<11;
		x=y; 
		y=z; 
		z=w;
		w^=w>>19^t^t >> 8;
		if(i%passo==0)
			uscita<<x<<"\t"<<y<<"\t"<<z<<"\t"<<w<<endl;
	}


	return 0;

}



