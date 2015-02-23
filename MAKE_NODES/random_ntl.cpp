#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <gmpxx.h>
#include <NTL/ZZ.h>
#include <NTL/RR.h>
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
using namespace NTL;

int main(){

        fstream uscita;
        uscita.open("nodi.dat",ios::out);
        uscita<<"x\t"<<"y\t"<<"z\t"<<"w\t"<<"t\t"<<endl;
        ZZ a,b,step,passo,c;
        conv(c,1);
        conv(c,100000000);
        conv(b,1);
        conv(b, "340282366920938463463374607431768211455");
        a=2;
        step=0;



        for(int i=1; i<128; i++){
                a*=2; 
        }
        passo = a / TOT_TH;

        cout<<"Passo:"<< passo <<endl;
        cout<<"Nodi :"<< TOT_TH<<endl;

        unsigned int x, y, z, w, t;
        while(true){
                t = x^x<<11;
                x=y; 
                y=z; 
                z=w;
                w^=w>>19^t^t >> 8;
                step++;
                if(step%c==0){
                        uscita<<x<<"\t"<<y<<"\t"<<z<<"\t"<<w<<"\t"<<t<<endl;
                }
                if(step==b) break;

        }

        return 0;
}




