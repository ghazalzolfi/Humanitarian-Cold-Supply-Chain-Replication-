Sets
    i   'suppliers'                                            /pfizer, moderna, jj, astrazeneca/
    j   'distributors'                                         /dc_ger, dc_swi, dc_ned, dc_uk/
    k   'affected regions (ARs)'                               /uk, ger, ned, swi, swe, ita, spa, gre, pol, aus/
    t   'time periods'                                         /t0, t1*t6/;

Alias (k,kp);
Alias (t,tp);

Parameters
    D(k,t)                'demand of AR k in period t'
    Cv(i,j)               'transportation cost per unit from supplier to distributor'
    Cvprime(j,k)          'transportation cost per unit from distributor to AR'
    Cvk(i,k)              'transportation cost per unit from supplier to AR directly'
    cost_per_km_pound     'transportation cost per kilometer per pound of vaccine'
    shipping_box_weight   'Weight of each shipping box for supplier i (pounds)'
    Fv                    'fixed cost for using truck v'
    Fvp                   'fixed cost for using truck vp'
    Hj(j)                 'inventory holding cost at distributor j'
    Pk(k)                 'penalty cost for unmet demand at AR k'
    M                     'large number for constraints (used in big-M formulations)'
    PC(i,t)               'production capacity of supplier i (in boxes)'
    S(j)                  'storage capacity of distributor j (in boxes)'
    alpha                 'space consumption coefficient per vaccine box (cubic feet)'
    Capv                  'capacity of truck v (in boxes)'
    Capvp                 'capacity of truck vp (in boxes)'
    lambda                'equity tolerance'
    lambdap
    totalDemand(k)
    decayFactor /0.8/
    r_delay(t, tp)        'Weight for demand delay between t and tp';
    ;

Table disik(i, k) 'Distance between supplier i and affected region k (km)'
            uk   ger  ned   swi   swe   ita   spa   gre   pol   aus
pfizer      930  100  580   870   810   1180  1870  1800  520   550
moderna     750  870  630   100   1540  690   1150  1810  1150  680
jj          360  580  100   630   1130  1300  1480  2160  1090  930
astrazeneca 100  930  360   750   1430  1430  1270  2390  1450  1230;

Table disij(i, j) 'Distance between supplier i and distributor j (km)'
           dc_ger dc_swi dc_ned dc_uk
pfizer      0      870    580    930
moderna     870    0      630    750
jj          580    630    0      360
astrazeneca 930    750    360    0;

Table disjk(j, k) 'Distance between distributor j and affected region k (km)'
         uk   ger  ned   swi   swe   ita   spa   gre   pol   aus
dc_ger   930  100  580   870   810   1180  1870  1800  520   550
dc_swi   750  870  630   100   1540  690   1150  1810  1150  680
dc_ned   360  580  100   630   1130  1300  1480  2160  1090  930
dc_uk    100  930  360   750   1430  1430  1270  2390  1450  1230;

cost_per_km_pound = 1.6;

shipping_box_weight = 80;

* === TRANSPORTATION COST per box ===
Cv(i,j)       = 0.3 * disij(i,j) * cost_per_km_pound * shipping_box_weight;
Cvprime(j,k)  = 0.3 * disjk(j,k) * cost_per_km_pound * shipping_box_weight;
Cvk(i,k)      = 1 * disik(i,k) * cost_per_km_pound * shipping_box_weight;

* === PRODUCTION CAPACITY: randomly between 50,000 to 60,000 boxes ===
PC(i,t) = round(uniform(5600,5800));

* === STORAGE CAPACITY of distributors: 5,000 to 6,000 boxes ===
S(j) = round(uniform(5000,6000));

* === TRUCK CAPACITY (boxes per truck) ===
Capv = round(uniform(1650,1750));
Capvp = round(uniform(450,550));

* === INVENTORY HOLDING COST at each distributor ===
Hj(j) = uniform(0.7,1.3);

* === PENALTY COST for unmet demand at each AR ===
Pk(k) = round(uniform(30,35));

* === SPACE consumption per box (cubic foot) ===
alpha = 3.1;

* === FIXED COST for using each truck ===
Fv   = round(uniform(100,110));
Fvp  = round(uniform(50,60));

* === BIG-M constant for binary constraints ===
M = 100000;

lambda = 0.1;
lambdap = 0.01;

* assuming linear increase over time, e.g., t1=1, t2=2, ..., t6=6
r_delay(t, tp) = 3 * abs(ord(t) - ord(tp));

* === total DEMAND
totalDemand("uk")  = 27344;
totalDemand("ger") = 34060;
totalDemand("ned") = 7090;
totalDemand("swi") = 3506;
totalDemand("swe") = 4197;
totalDemand("ita") = 24764;
totalDemand("spa") = 19258;
totalDemand("gre") = 4398;
totalDemand("pol") = 7090;
totalDemand("aus") = 3635;



Set tpos(t) /t1*t6/;

Scalar sumDecay;

sumDecay = 1 + decayFactor + decayFactor**2 + decayFactor**3 + decayFactor**4 + decayFactor**5 ;

Loop(k,
    D(k, 't1') = round(totalDemand(k) / sumDecay);

    Loop(tpos$(ord(tpos) > 1),
        D(k, tpos) = round( D(k, tpos-1) * decayFactor);
    );
);


Variables
    TotalCost           'total cost of the system'
    deprivation_cost   'Deprivation cost due to unmet demand';

Positive Variables
    xikv(i,k,t)       'amount transported directly from i to k'
    xijv(i,j,t)       'amount boxs transported from i to j by v in t'
    xjkvp(j,k,t)      'amount transported from j to k by vp in t'
    Inv(j,t)            'inventory at distributor j in period t'
    Short(k,tp,t)
    N(k,tp,t);

Integer Variables
    Numv(i,t)         'number of trucks v from supplier i in t'
    Numvp(j,t)       'number of trucks vp from distributor j in t';

Equation
    obj
    inventory_balance(j,t)
    storage_constraint(j,t)
    production_capacity(i,t)
    shortage_balance1(k,tp,t)
    shortage_balance2(k,t)
    vehicle_capacity_from_supplier(i,t)
    vehicle_capacity_from_distributor(j,t)
    equity_constraint(k,kp,t)
    equity_constraint2(k,kp,t)
    initial_inventory(j)
    initial_shortage(k,tp,t)
    deprivation_cost_eq
    shortage_recovery(k,tp)
    ;

obj.. TotalCost =e=
      sum((i,j,t), Cv(i,j)*xijv(i,j,t)) + sum((i,t), Fv*Numv(i,t))
    + sum((j,k,t), Cvprime(j,k)*xjkvp(j,k,t)) + sum((j,t), Fvp*Numvp(j,t))
    + sum((i,k,t), Cvk(i,k)*xikv(i,k,t))
    + sum((k,t), Pk(k)*sum(tp$(ord(tp) = ord(t)), Short(k,tp,t)))
    + sum((j,t), Hj(j)*Inv(j,t))
    + deprivation_cost;

deprivation_cost_eq..
    deprivation_cost =e= sum((k,t,tp)$(ord(tp) <= ord(t)), r_delay(t, tp) * Short(k,tp,t));

initial_inventory(j).. Inv(j,"t0") =e= 0;

initial_shortage(k,tp,t)$(ord(tp) > ord(t))..
    Short(k,tp,t) =e= 0 ;

inventory_balance(j,t)$(ord(t) > 0)..
    sum((i), xijv(i,j,t)) + Inv(j,t-1) =e=
    sum((k), xjkvp(j,k,t)) + Inv(j,t);

storage_constraint(j,t)..
    Inv(j,t) =l= S(j);

production_capacity(i,t)..
    sum((j), xijv(i,j,t)) + sum((k), xikv(i,k,t)) =l= PC(i,t);

shortage_balance1(k,tp,t)$(ord(t) > 0 and ord(tp) < ord(t))..
    Short(k,tp,t) =e= Short(k,tp,t-1) - N(k,tp,t);

shortage_balance2(k,t)$(ord(t) > 0)..
    Short(k,t,t) =e= D(k,t) -
    (sum((i), xikv(i,k,t)) + sum((j), xjkvp(j,k,t)) - sum(tp,N(k,tp,t)));

shortage_recovery(k,tp)..
    Short(k,tp,"t6") =e= 0;

vehicle_capacity_from_supplier(i,t)..
    alpha * (
        sum(j, xijv(i,j,t)) + sum(k, xikv(i,k,t))
    ) =l= Numv(i,t) * Capv;

vehicle_capacity_from_distributor(j,t)..
    alpha * sum(k, xjkvp(j,k,t)) =l= Numvp(j,t) * Capvp;

equity_constraint(k,kp,t)$(ord(k) < ord(kp) and D(k,t) > 0 and D(kp,t) > 0)..
    abs(
        (sum((i), xikv(i,k,t)) + sum((j), xjkvp(j,k,t))) / D(k,t)
      - (sum((i), xikv(i,kp,t)) + sum((j), xjkvp(j,kp,t))) / D(kp,t)
    ) =l= lambda;

equity_constraint2(k,kp,t)$(ord(k) < ord(kp) and D(k,t) > 0 and D(kp,t) > 0)..
    abs(
        (sum(tp, Short(k,tp,t)) / totalDemand(k))
      - (sum(tp, Short(kp,tp,t)) /  totalDemand(kp))
    ) =l= lambdap;

Model ColdChainModel /all/;
option minlp = scip;
Solve ColdChainModel using minlp minimizing TotalCost;
display TotalCost.l, deprivation_cost.l;
display Numv.l, Numvp.l, xijv.l, xikv.l, xjkvp.l, Short.l, Inv.l;



