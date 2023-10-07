some_packages <- c('DALEX','CASdatasets','insuranceData','randomForest',
                   'DALEXtra', 'lime', 'localModel', 'rms', 'tidyverse')

#load all packages at once
lapply(some_packages, library, character.only=TRUE)

data(AutoBi)

head(AutoBi)

#AUTO DATA: VARIABLE ATTRIBUTIONS APPROACH
#AVOID CONDITIONING ON CASE NUMBER AS IRRELEVANT

#CAN CONSIDER ONLY CASES WITHOUT ATTORNEY IF REQUIRED:
#AutoBi<-AutoBi[AutoBi$ATTORNEY==2,]

AutoBi <- AutoBi[,c("ATTORNEY", "CLMSEX", "MARITAL", "CLMINSUR",
                    "SEATBELT", "CLMAGE", "LOSS")]

#AutoBi$LOSS <- as.factor(AutoBi$LOSS)

#REMOVE MISSING DATA
AutoBi <- na.exclude(AutoBi)

#SPECIFY TASK

set.seed(2023)

#GENERATE RANDOM FORESTS

set.seed(1313)

auto_random_forest <- randomForest(LOSS ~ ATTORNEY + CLMSEX + MARITAL + 
                                     CLMINSUR + SEATBELT + CLMAGE,
                                   data = AutoBi)

#WRAP INTO ONE EXPLAINER

auto_model_forest <-  DALEX::explain(auto_random_forest,
                                     data = AutoBi[,-7],
                                     y = AutoBi$LOSS,
                                     label = "Forest")

predict(auto_model_forest, AutoBi) |> head()

breakdown_random_forest1 <- predict_parts(explainer = auto_model_forest,
                                          new_observation = AutoBi[1090,],
                                          type = "break_down")

breakdown_random_forest2 <- predict_parts(explainer = auto_model_forest,
                                          new_observation = AutoBi[1091,],
                                          type = "break_down")

breakdown_random_forest1
breakdown_random_forest2


plot(breakdown_random_forest1)
plot(breakdown_random_forest2)

#CHECK FOR INTERACTIONS

breakdown_random_forest_inter1 <- predict_parts(explainer = auto_model_forest,
                                                new_observation = AutoBi[1090,],
                                                type = "break_down_interactions")

breakdown_random_forest_inter2 <- predict_parts(explainer = auto_model_forest,
                                                new_observation = AutoBi[1091,],
                                                type = "break_down_interactions")

breakdown_random_forest_inter1
breakdown_random_forest_inter2


plot(breakdown_random_forest_inter1)
plot(breakdown_random_forest_inter2)

#AVERAGING TECHNIQUE

shap1 <- predict_parts(explainer = auto_model_forest,
                       new_observation = AutoBi[1090,], 
                       type = "shap",
                       B = 10)

shap2 <- predict_parts(explainer = auto_model_forest,
                       new_observation = AutoBi[1091,], 
                       type = "shap",
                       B = 10)
plot(shap1)
plot(shap2)


#LIME METHOD AUTO

auto_rf_exp <- DALEX::explain(model = auto_model_forest,
                              data = AutoBi[,-7],
                              y = AutoBi$LOSS,
                              label = "Random Forest")


model_type.dalex_explainer <- DALEXtra::model_type.dalex_explainer
predict_model.dalex_explainer <- DALEXtra::predict_model.dalex_explainer

lime_auto_1091 <- predict_surrogate(explainer = auto_rf_exp, 
                                    new_observation = AutoBi[1091,], 
                                    n_features = 6, 
                                    n_permutations = 1000,
                                    type = "lime")

as.data.frame(lime_auto_1091)
plot(lime_auto_1091)

#LOCAL MODEL LASSO REGRESSION OBJECT AUTO

locMod_auto <- predict_surrogate(explainer = auto_rf_exp, 
                                 new_observation = AutoBi[1091,], 
                                 size = 1000, 
                                 seed = 1,
                                 type = "localModel")

plot_interpretable_feature(locMod_auto, "CLMAGE")


#CP PROFILES

auto_lmr <- lm(LOSS ~ ATTORNEY + CLMSEX + MARITAL +
                  CLMINSUR + SEATBELT + CLMAGE, AutoBi)

set.seed(1313)

auto_rf <- randomForest(LOSS ~ CLMSEX + MARITAL +
                          CLMINSUR + SEATBELT + CLMAGE,
                        data = AutoBi)

#NOTE EXPLAIN ALONE DEFAULTS TO LIME

auto_explain_lmr <- DALEX::explain(model = auto_lmr, 
                                   data  = AutoBi[, -7],
                                   y     = AutoBi$LOSS,
                                   type = "regression",
                                   label = "Linear Regression")


auto_explain_rf <- DALEX::explain(model = auto_rf, 
                                  data  = AutoBi[, -7],
                                  y     = AutoBi$LOSS,
                                  label = "Random Forest")

cp_auto_rf <- predict_profile(explainer = auto_explain_rf, 
                              new_observation = AutoBi[1091,])
cp_auto_rf


plot(cp_auto_rf) +
  ggtitle("Ceteris-paribus profile", "")

plot(cp_auto_rf, variables = c("ATTORNEY")) +
  ggtitle("Ceteris-paribus profile", "")

cp_auto_rf2 <- predict_profile(explainer = auto_explain_rf, 
                               new_observation = rbind(AutoBi[1090,],
                                                       AutoBi[1091,]))

plot(cp_auto_rf2, color = "_ids_", variables = c("ATTORNEY")) + 
  scale_color_manual(name = "Observation:", 
                     values = c("red", "blue"), 
                     labels = c("Second Last" , "Last")) 

#COMPARE RANDOM FOREST AND LOGISTIC REGRESSION MODELS

cp_auto_rf <- predict_profile(auto_explain_rf, AutoBi[1091,])
cp_auto_lmr <- predict_profile(auto_explain_lmr, AutoBi[1091,])


plot(cp_auto_lmr, cp_auto_rf, color = "_label_",  
     variables = c("ATTORNEY", "MARITAL")) +
  ggtitle("Ceteris-paribus profiles for final obs.", "") 


#CP OSCILLATIONS

oscillations_uniform <- predict_parts(explainer = auto_explain_rf, 
                                      new_observation = AutoBi[1091,], 
                                      type = "oscillations_uni")
oscillations_uniform

oscillations_uniform$`_ids_` <- "Last Obs."
plot(oscillations_uniform) +
  ggtitle("Ceteris-paribus Oscillations", 
          "Expectation over uniform distribution (unique values)") 

#LOCAL DIAGNOSTIC PLOTS

auto_id_rf <- predict_diagnostics(explainer = auto_explain_rf,
                             new_observation = AutoBi[101,],
                             neighbours = 100)
auto_id_rf

plot(auto_id_rf)

id_rf_attorney_101 <- predict_diagnostics(explainer = auto_explain_rf,
                                 new_observation = AutoBi[101,],
                                 neighbours = 10,
                                 variables = "ATTORNEY")

plot(id_rf_attorney_101)

id_rf_attorney_1091 <- predict_diagnostics(explainer = auto_explain_rf,
                                      new_observation = AutoBi[1,],
                                      neighbours = 10,
                                      variables = "MARITAL")

plot(id_rf_attorney_1091)

AutoBi$CLMINSUR==2

#Positive and negative residuals = non biased.
#Close together = stable
#Residuals large but not huge implies relatively accurate.
