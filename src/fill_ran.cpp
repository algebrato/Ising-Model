#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#define NODES 4194304


using namespace std;

void fill_ran_vec (unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d, int N){
	fstream in;
	in.open("MAKE_NODES/nodi_x_y_z_w.dat",ios::in);
	int STEP = NODES/N;
	//cout << STEP << endl;
	unsigned int app1, app2, app3, app4; 
	int k=0;
	for(int i=0; i<NODES; i++){
		if(i % STEP == 0){
			in >> a[k] >> b[k] >> c[k] >> d[k];
			i++;
			k++;
		}
		in >> app1 >> app2 >> app3 >> app4;
	}
}
