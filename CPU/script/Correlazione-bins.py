import matplotlib.pylab as plt
import numpy as np 
import sys
import os
import string
%matplotlib inline 

def load_file(nome_file):
    try:
        dati = np.loadtxt(open(nome_file,"rb"),delimiter="\t")
    except IOError as e:
        exit(e.errno)
        
    x,y,z= dati[:,0], dati[:,1], dati[:,2]
    return x,y,z

x,y,rand=load_file("/home/stefanomandelli/Ising-Model/CPU/script/test.dat")

plt.figure(1,figsize=(16, 6), dpi=80)
plt.subplot(131)
plt.title("Posizioni X")
plt.hist(x, bins=128)[2]
    
plt.subplot(132)
plt.title("Posizioni Y")
plt.hist(y, bins=128)[2]
 
plt.subplot(133)
plt.title("RND")
plt.hist(rand, bins=128)[2]

xx=np.histogram(x,bins=128)
correlationx=[]
for i in range(1,64):
    x1=xx[0][i:]
    x2=xx[0][:(len(xx[0])-i)]
    correlationx.append(np.corrcoef(x1,x2)[0][1])


yy=np.histogram(y,bins=128)
correlationy=[]
for i in range(1,64):
    y1=yy[0][i:]
    y2=yy[0][:(len(xx[0])-i)]
    correlationy.append(np.corrcoef(y1,y2)[0][1])


rr=np.histogram(rand,bins=128)
correlationrr=[]
for i in range(1,64):
    rr1=rr[0][i:]
    rr2=rr[0][:(len(xx[0])-i)]
    correlationrr.append(np.corrcoef(rr1,rr2)[0][1])

plt.figure(2,figsize=(16, 6), dpi=80)
plt.subplot(311)
plt.plot(correlationy,'-')
plt.subplot(312)
plt.plot(correlationx,'-')
plt.subplot(313)
plt.plot(correlationy,'-')xx=np.histogram(x,bins=128)
correlationx=[]
for i in range(1,64):
    x1=xx[0][i:]
    x2=xx[0][:(len(xx[0])-i)]
    correlationx.append(np.corrcoef(x1,x2)[0][1])


yy=np.histogram(y,bins=128)
correlationy=[]
for i in range(1,64):
    y1=yy[0][i:]
    y2=yy[0][:(len(xx[0])-i)]
    correlationy.append(np.corrcoef(y1,y2)[0][1])


rr=np.histogram(rand,bins=128)
correlationrr=[]
for i in range(1,64):
    rr1=rr[0][i:]
    rr2=rr[0][:(len(xx[0])-i)]
    correlationrr.append(np.corrcoef(rr1,rr2)[0][1])

plt.figure(2,figsize=(16, 6), dpi=80)
plt.subplot(311)
plt.plot(correlationy,'-')
plt.subplot(312)
plt.plot(correlationx,'-')
plt.subplot(313)
plt.plot(correlationy,'-')

plt.figure(4,figsize=(12, 12), dpi=80)
plt.plot(x[1:16384],y[1:16384],'p')

plt.figure(4, figsize=(12,12), dpi=80)
plt.plot(rand[1:10000],'p')

correlationXpos=[]
lunghezza=12000
for i in range(1,lunghezza):
    x1=x[i:(2*lunghezza)]
    x2=x[:((2*lunghezza)-i)]
    correlationXpos.append(np.corrcoef(x1,x2)[0][1])
    
correlationYpos=[]
for i in range(1,lunghezza):
    y1=y[i:(2*lunghezza)]
    y2=y[:((2*lunghezza)-i)]
    correlationYpos.append(np.corrcoef(y1,y2)[0][1])
    
correlationRND=[]
for i in range(1,lunghezza):
    RND1=rand[i:(2*lunghezza)]
    RND2=rand[:((2*lunghezza)-i)]
    correlationRND.append(np.corrcoef(RND1,RND2)[0][1])

plt.figure(5, figsize=(16,10), dpi=80)
plt.subplot(311)
plt.plot(correlationXpos,'k')
plt.subplot(312)
plt.plot(correlationYpos,'k')
plt.subplot(313)
plt.plot(correlationRND,'k')correlationXpos=[]
lunghezza=12000
for i in range(1,lunghezza):
    x1=x[i:(2*lunghezza)]
    x2=x[:((2*lunghezza)-i)]
    correlationXpos.append(np.corrcoef(x1,x2)[0][1])
    
correlationYpos=[]
for i in range(1,lunghezza):
    y1=y[i:(2*lunghezza)]
    y2=y[:((2*lunghezza)-i)]
    correlationYpos.append(np.corrcoef(y1,y2)[0][1])
    
correlationRND=[]
for i in range(1,lunghezza):
    RND1=rand[i:(2*lunghezza)]
    RND2=rand[:((2*lunghezza)-i)]
    correlationRND.append(np.corrcoef(RND1,RND2)[0][1])

plt.figure(5, figsize=(16,10), dpi=80)
plt.subplot(311)
plt.plot(correlationXpos,'k')
plt.subplot(312)
plt.plot(correlationYpos,'k')
plt.subplot(313)
plt.plot(correlationRND,'k')

plt.figure(6,figsize=(18,10), dpi=80)
plt.hist((x+127*y), bins=16256, )[2]

crossCorr=[]
tot=x+127*y
lunghezza=16256
for i in range(1,lunghezza):
    rand1=rand[i:(2*lunghezza)]
    x1=tot[:((2*lunghezza)-i)]
    crossCorr.append(np.corrcoef(rand1,x1)[0][1])

plt.figure(6, figsize=(16,10), dpi=80)
plt.plot(crossCorr,'k')
