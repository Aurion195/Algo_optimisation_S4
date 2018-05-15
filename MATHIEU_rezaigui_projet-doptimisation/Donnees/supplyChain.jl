using JuMP
using CPLEX

q = Model(solver = CplexSolver())
include("data.txt") 


T1 = 300
T2 = 30
r = 500

@variable(q, d[1:4,1:4])	#Djv
@variable(q, m[1:4,1:4])	#Mij
@variable(q, c1[1:4,1:4])	#C1sk
@variable(q, c2[1:4,1:4])	#C2ki
@variable(q, L[1:4])		#Lj
@variable(q, f[1:4,1:4])	#Fit
@variable(q, g[1:4])		#Gk
@variable(q, C[1:4,1:4])	#Ci
@variable(q, x1[1:4,1:4,1:2])	#X1skv
@variable(q, x2[1:4,1:4,1:2])	#X2kiv
@variable(q, x3[1:4,1:4,1:2])	#X3ijv
@variable(q, z[1:4], Bin) 		#Zk
@variable(q, y[1:4,1:4], Bin) 		#Yit			6 centres au maximum


@objective(q, Min, sum{sum{sum{ (x3[i,j,v]/L[j]) * (T1 + T2 * m[i,j])  , i=1:4} ,j=1:4 }, v=1:2  } 
	+ sum{sum{ c2[k:i] * sum{x2[k,i,v] ,v=1:4 } , k=1:4} , i=1:4} 
	+ sum{sum{ c1[s,k] * sum{x1[s,k,v] , v=1:4} , s=1:4 }, k=1:4}
	+ sum{sum{ f[i,t] * y[i,t] + sum{g[k]*z[k] , v=1:4} , k=1:4 } , i=1:4}
	)
for j = 1:4
	for v = 1:4
		@constraint(q, sum{x3[i,j,v] , i=1:4} == d[j,v])
	end
end
for i = 1:4
	for v = 1:4
		@constraint(q, sum{x2[k,i,v] , k=1:4} == sum{x3[i,j,v] , j=1:4 })
	end
end
for k = 1:4
	for v = 1:4
		@constraint(q, sum{x1[s,k,v] , s=1:4} == sum{x2[k,i,v] , i=1:4 })
	end
end
for i=1:4
	@constraint(c[i] * y[i,2] <= sum{sum{x3[i,j,v] , j=1:4, v=1:4}} )
	@constraint( sum{sum{x3[i,j,v] , j=1:4 } , v=1:4 } <= c[i] * y[i,2] 
	+ ( sum{sum{d[j,v] , j=1:4 } , v=1:4}  * y[i,2] ) ) 
end
for k = 1:4
		@constraint(q, sum{sum{x2[k,i,v] , i=1:4} , v=1:4} 
		<= (sum{sum{d[j,v] , v=1:4 } , v=1:4 } )* z[k]  )
end
for i = 1:4
	for j = 1:4
		if ((m[i,j]) / 300) < r							##########################"  ici r a définir  # erreur du sujet ou la division doit etre inférieur et non pas supérieur
			@constraint(q, sum{x3[i,j,v] , v=1:n} == 0 )
	end
end
@constraint(q, sum{sum{y[i,t] , i=1:n }, t=1:n} <= Y)
@constraint(q, sum{z[k] , i=1:4} <= Z)

for i=1:4
	@constraint(q, z[i] == sum{y[i,t], t:1:4})
end
for i=1:4
	@constraint(q, z[i] == sum{y[i,t] , t:1:4})
end


