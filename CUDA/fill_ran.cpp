#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#define END_SCALE 4294967296.0F

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
	srand(time(NULL));
	for(int i=0; i<N; ++i){
		a[i]=rand();
		b[i]=rand();
		c[i]=rand();
		d[i]=rand();
	}

}

void fill_ran_vec3(unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d, int N){
	for(int i=0; i<N; ++i){
		a[i]=((i-1) <<11)^((i-1)>>28);
		b[i]=((N*a[i]-1) <<11)^((N*a[i]-1)>>28);
		c[i]=(((N+1)*b[i]-1) <<11)^(((N+1)*b[i]-1)>>28);
		d[i]=(((N+2)*c[i]-1) <<11)^(((N+2)*c[i]-1)>>28);
	}
}


void fill_ran_vec4(unsigned int *a, unsigned int *b, unsigned int *c, unsigned int *d, int N){
	unsigned int x, y, z, w, t;

	//cout << N << endl;


        a[0]=2678936131;
        b[0]=1801065994;
        c[0]=3925136598;
        d[0]=285088606;

	x=a[0];
	y=b[0];
	z=c[0];
	w=d[0];

	for(int k=1; k<N; k++){
		for(int i=0; i<10000; ++i){//Mixing
			t=x^x<<11;x=y;y=z;z=w;w^=w>>19^t^t>>8;
		}
	a[k]=x;
	b[k]=y;
	c[k]=z;
	d[k]=w;
	}
	//printf("%i\t%i\t%i\t%i\n",a[0],b[0],c[0],d[0]);
	//printf("%i\t%i\t%i\t%i\n",a[1],b[1],c[1],d[1]);
}




