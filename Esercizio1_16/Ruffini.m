(** Ruffini **)

RUF[x_, y_, t_] := Module[
	  {coefx, coefy, MUL, n1, a},
  coefx = CoefficientList[x, t]; 
  coefy = CoefficientList[y, t];
  n1 = -1*coefy[[1]];
  For[
	   i = 2, i < Length[coefx], ++i,
   coefx[[i]] = coefx[[i]] + (coefx[[i - 1]]*n1)];
  coefx
  ]

(**C'e` qualcosa che non funziona**)

RUF[x^4 + 7 x + 6, x - 1, x]
