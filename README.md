# DALEX-Exploration-and-Explanation-of-Insurance-Data
In depth analysis of the applicability of the DALEX package to insurance data sets in R, with specific focus on Shapley Values and Ceteris-paribus profiles and oscillations.

The data is from the Insurance Research Council (IRC) and contains information on demographic information about the claimant, attorney involvement and the
economic loss (LOSS, in thousands), among other variables. The format is as follows:

A data frame with 1340 observations on the following 8 variables.
CASENUM Case number to identify the claim, a numeric vector
ATTORNEY Whether the claimant is represented by an attorney (=1 if yes and =2 if no), a numeric
vector
CLMSEX Claimant’s gender (=1 if male and =2 if female), a numeric vector
MARITAL claimant’s marital status (=1 if married, =2 if single, =3 if widowed, and =4 if divorced/separated),
a numeric vector
CLMINSUR Whether or not the driver of the claimant’s vehicle was uninsured (=1 if yes, =2 if no,
and =3 if not applicable), a numeric vector
SEATBELT Whether or not the claimant was wearing a seatbelt/child restraint (=1 if yes, =2 if no,
and =3 if not applicable), a numeric vector
CLMAGE Claimant’s age, a numeric vector
LOSS The claimant’s total economic loss (in thousands), a numeric vector

The investigation begins with break-down plots for additive attributions, before widening to account for interactions among variables within the data. 
All of this is based on predictions obtained using a random forest model. 
Also investigated are further methods of accounting for interactions among data, with particular focus on Shapley Additive Explanations. The use of Shapley values
enables a remodelling of predictions for the data and summary of the distributions of the attributions for each explanatory variable, across the different orderings,
with a simultaneous presentation of the Shapley values in breakdown plots. 

The investigation ends with visual examination of Ceteris-paribus profiles and analysis of the corresponding profile oscillations. 
This is vital in identifying and ranking the importance and influence of the explanatory variables, and provides great insight into the data
