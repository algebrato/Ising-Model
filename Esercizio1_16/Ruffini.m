(** ::Ruffini:: **)

RUF[x_, y_, t_] := Module[
	{coefx, coefy, MUL, n1, rest},

	coefx = Reverse[CoefficientList[x, t]]; 
	coefy = CoefficientList[y, t];

	n1 = -1*coefy[[1]];
   
	For[
		i = 2, i <= Length[coefx], i++,
		coefx[[i]] = coefx[[i]] + (coefx[[i - 1]]*n1)
	];
   
	rest = Last[coefx];
   	monomi={};
	For[
		i=0,i<Length[coefx]-1,i++,
		monomi=Append[monomi,t^i]
	];

	coefx=Delete[coefx,Length[coefx]];
	polyres=Reverse[coefx].monomi;
   
	Print["R(x)=",polyres];
	Print["Resto=",rest];
	
	]

RUF[x^4 + 7 x + 6, x + 1, x]

