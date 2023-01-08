clear all
import excel "C:\Users\drone\Desktop\PSU Fall 2022\Time Series\Final\Yields1_SARB-2.xlsx", sheet("Sheet1")
rename A Date
rename B TIME
rename C Yield3
rename D Yield10
rename E Eskom
rename F Risk310
rename G RiskEskom
rename H US_10_Year_Govt_Bond_Yields
rename I German_10_Govt_Bond_Yields
rename J SARiskvsUS
rename K SARiskvsGermany
rename L EskomvsUS
rename M EskomvsGermany
rename N CPI_TOT
rename O CPI_Services
rename P CPI_Goods
rename Q GovDef_Perc_GDP
gen Time=_n
tsset Time
gen Month = tm(1960m1) + Time - 1
format Month %tm
tsset Month
use "C:\Users\drone\Desktop\PSU Fall 2022\Time Series\yieldsFinal.dta"

destring Risk310, gen(risk310)
destring SARiskvsUS, gen(sarus10)
destring CPI_TOT, gen(cpi_tot)
destring GovDef_Perc_GDP, gen(govDef)
gen lncpi_tot = ln(cpi_tot)
gen ln_risk310 = ln(risk310)
gen ln_sarus10 = ln(sarus10)

tsline risk310, name(risk310)
tsline sarus10, name(sarus10)
tsline D.risk310, name(Drisk310)
tsline D.sarus10, name(Dsarus10)
tsline ln_risk310, name(lnrisk310)
tsline ln_sarus10, name(lnsarus10)
tsline D.ln_risk310, name(Dlnrisk310)
tsline D.ln_sarus10, name(Dlnsarus10)
gr combine risk310 sarus10 Drisk310 Dsarus10 lnrisk310 lnsarus10 Dlnrisk310 Dlnsarus10, col(2)

kpss risk310, auto
kpss D.risk310, auto
kpss sarus10, auto
kpss D.sarus10, auto
dfgls risk310
dfgls D.risk310
dfgls sarus10
dfgls D.sarus10

/* Ermini-Hendry - risk310 */
reg D.ln_risk310
predict Dlnrisk310, xb
predict r_ln_risk310, resid
sum r_ln_risk310
gen var_rln_risk310= 0.3260028^2
gen lambda= 0.1062778+(var_rln_risk310/2)
gen expLamT=exp(lambda*Time)
reg D.risk310 L(1/16).D.risk310 expLamT
estat bgo, l(16)
reg risk310 L(16).risk310
estat archlm, l(16)

/* Ermini-Hendry - sarus10 */
reg D.ln_sarus10
predict Dsarus10, xb
predict r_ln_sarus10, resid
sum r_ln_sarus10
gen var_rln_sarus10=0.2008962^2
gen lambda=0.0403593+(var_rln_sarus10/2)
gen expLamT=exp(lambda*Time)
reg D.sarus10 L(1/18).D.sarus10 
estat bgo, l(3)
estat archlm, l(18)

/* ARCH and ARCH-M estimations SA310 */
arch risk310 L(1/16).risk310, arch(1) garch(1)
predict risk310_ARCH1, xb
predict r_risk310, resid
tsline risk310_ARCH1
tsline r_risk310
gr combine risk310_ARCH1 r_risk310
test [ARCH]L.arch + [ARCH]L.garch  == 1

arch risk310 L(1/16).risk310, archm arch(1)
predict risk310_ARCHM1, xb
predict r_risk310M, resid
test [ARCHM]sigma2  == 1

/* ARCH and ARCH-M estimations SAUS10 */
ac sarus10, name(ACFsarus10)
pac sarus10, name(PACFsarus10)
ac D.sarus10, name(ACFDsarus10)
pac D.sarus10, name(PACFDsarus10)
gr combine ACFsarus10 PACFsarus10 ACFDsarus10 PACFDsarus10, col(2)
arch L(1/5).sarus10, arch(1/3) /* GARCH11*/
arch D.sarus10 L(1/18).D.sarus10, arch(1/2) /* ARCH11*/
predict sarus10_ARCH1, xb
predict r_sarus10, resid
tsline sarus10_ARCH1
tsline r_sarus10
gr combine sarus10_ARCH1 r_sarus10
test [ARCH]L.arch + [ARCH]L.garch  == 1

arch L(1/10).D.sarus10, earch(1/1)  egarch(1/1)


arch L(1/17).D.sarus10, archm arch(1) garch(1)
predict sarus10_ARCHM1, xb
predict r_sarus10M, resid
test [ARCHM]sigma2  == 1

/* Lag Structure Test */

arch risk310 L(1/16).risk310, arch(1/1) 
estat ic

arch risk310 L(1/2).risk310, arch(1/1) 
estat ic

arch risk310 L(1/3).risk310, arch(1/1)  /* 3 has the lowest AIC. Best lag structure */
estat ic

arch risk310 L(1/4).risk310, arch(1/1) 
estat ic

/* Estimation under GARCH(1,1) */
arch risk310 L3.risk310 L4.govDef, arch(1/1) garch(1/1)
predict risk310_GARCH11, xb
predict r_GARCH11, resid
tsline risk310 risk310_GARCH11
tsline r r_GARCH11
hist r_GARCH11, bin(40) name(hrGARCH11)
gr combine hr1 hrARCH hrARCH4 hrGARCH11, col(2)
test [ARCH]L.arch + [ARCH]L.garch == 1

/* Q2 */
clear all
import excel "C:\Users\drone\Desktop\PSU Fall 2022\Time Series\Final\GrowthRegimes_Final-1.xlsx", sheet("Sheet2")
rename A year
rename B rgdp
rename C population
rename D capitGov
rename E capPubcorp
rename F capPrivate
gen Time=_n
tsset Time
gen Year = tm(1960m1) + Time - 1
format Year %ty
tsset Year
use "C:\Users\drone\Desktop\PSU Fall 2022\Time Series\Final\growthregimes.dta"

destring rgdp, gen(Rgdp)
destring population, gen(Population)
destring capitGov, gen(capitgov)
destring capPubcorp, gen(cappubcorp)
destring capPrivate, gen(capPrivCorp)

gen lnrgdp = ln(Rgdp)
gen ln_capitgov = ln(capitgov)
gen ln_cappubcorp = ln(cappubcorp)
gen ln_capPrivCorp = ln(capPrivCorp)

tsline Rgdp, name(rgdp)
tsline cappubcorp
tsline Population, name(population)
tsline capitgov, name(capitGov)
tsline cappubcorp, name(CapPub)
tsline capPrivCorp, name(CapPriv)
tsline lnrgdp, name(lnRGDP)
tsline ln_capitgov, name(ln_capitGov)
tsline ln_cappubcorp, name(ln_CapPub)
tsline ln_capPrivCorp, name(ln_CapPriv)
gr combine rgdp population capitGov CapPub CapPriv lnRGDP ln_capitGov ln_CapPub ln_CapPriv, col(2)

reg D.Rgdp L(1/10).D.Rgdp
estat ic
reg D.lnrgdp L(1/10).D.lnrgdp
estat ic
reg D.capitgov L(1/10).D.capitgov
estat ic
reg D.ln_capitgov L(1/10).D.ln_capitgov
estat ic
reg D.cappubcorp L(1/10).D.cappubcorp
estat ic
reg D.ln_cappubcorp L(1/10).D.ln_cappubcorp
estat ic
reg D.capPrivCorp L(1/10).D.capPrivCorp
estat ic
reg D.ln_capPrivCorp L(1/10).D.ln_capPrivCorp
estat ic

reg Rgdp Population capitgov cappubcorp capPrivCorp
predict rgdp_fit, xb
predict r, resid
tsline Rgdp rgdp_fit
tsline r
clemao2 Rgdp,  graph
clemao2 D.Rgdp, graph
zandrews Rgdp , maxlag(3) graph

pperron Rgdp, l(6) noconstant regress
pperron Rgdp, l(6) regress
pperron Rgdp, l(6) trend regress
pperron capitgov, l(6) noconstant regress
pperron capitgov, l(6)  regress
pperron capitgov, l(6) trend regress
pperron cappubcorp, noconstant regress
pperron cappubcorp,  regress
pperron cappubcorp, trend regress
pperron capPrivCorp, noconstant regress
pperron capPrivCorp,  regress
pperron capPrivCorp, trend regress

kpss D.capPrivCorp, auto
dfgls D.capPrivCorp
kpss Rgdp, auto
dfgls Rgdp
kpss capitgov, auto
dfgls D.capitgov
kpss D.cappubcorp, auto
dfgls D.cappubcorp

reg D.Rgdp L8D.capitgov L11D.cappubcorp L11D.capPrivCorp
predict rgdp_fit, xb
predict r, resid

gen D37=0
replace D37=1 if Time>38
tsline D37
gen D63=0
replace D63=1 if Time>64
tsline D63

reg Rgdp capitgov cappubcorp capPrivCorp D37 D63
predict rgdp_fit, xb
predict r, resid
tsline Rgdp rgdp_fit
tsline r

reg D.Rgdp L8D.capitgov L11D.cappubcorp L11D.capPrivCorp D37 D63
predict rgdp_fit, xb
predict r, resid
tsline Rgdp rgdp_fit
tsline r