#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>


using namespace std;

void fill_ran_vec (unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d, int N){
	fstream in;
	in.open("nodi_passo_E6.dat",ios::in);
	unsigned int app1, app2, app3, app4; 
	int k=0;
	in >> app1 >> app2 >> app3 >> app4;
	for(int i=0; i<N; i++){
		a[i] = app1;
		b[i] = app2;
		c[i] = app3;
		d[i] = app4;
		in >> app1 >> app2 >> app3 >> app4;
	}
}


void fill_ran_vec2 (unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d, int N){
	for(int i=0; i<N; ++i){
		a[i]=i;
		b[i]=i;
		c[i]=i;
		d[i]=i;
	}

}






