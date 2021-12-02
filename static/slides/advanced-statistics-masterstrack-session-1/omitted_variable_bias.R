library(broom)
library(purrr)
library(tidymodels)
library(readr)
library(ggstatsplot)

df_boston <- read_csv("instructor-session-1/HousingData.csv") %>%
  janitor::clean_names()

ggcorrmat(
  data = df_boston %>% na.omit() %>% select(medv, rm, age),
  colors = c("#800000", "#ffbd25", "#FFFFFF"),
  title = "Correlalogram Bostom Housing"
)

ggsave("correlation_bostom_matrix.png", dpi = 300)

set.seed(27)
boots <- bootstraps(df_boston, times = 200, apparent = TRUE)
boots

fit_lm_omit <- function(split) {
  lm(medv ~ age, data = analysis(split))
}

fit_lm_full <- function(split) {
  lm(medv ~ age + rm, data = analysis(split))
}

boot_models <- boots %>%
  mutate(
    model_omit = map(splits, fit_lm_omit),
    model_full = map(splits, fit_lm_full),
    coef_info_omit = map(model_omit, tidy),
    coef_info_full = map(model_full, tidy)
  )


boot_models %>%
  select(coef_info_omit) %>%
  unnest(cols = c(coef_info_omit)) %>%
  filter(term == "age") %>%
  mutate(model = "ommitted") %>%
  bind_rows(boot_models %>%
              select(coef_info_full) %>%
              unnest(cols = c(coef_info_full)) %>%
              filter(term == "age") %>%
              mutate(model = "full")) %>%
  ggplot(aes(estimate, fill = model)) +
  geom_density(alpha = .75, color = "#d9d9d9") +
  scale_fill_manual(name = "Model: ", label = c("Full", "Omitted"), values = c("#4d4d4f", "#800000")) +
  ggthemes::theme_tufte() +
  theme(legend.position = "bottom") +
  labs(x = "Beta Estimate", y = "Density")

ggsave("ommitted_variable.png", dpi = 300)


tribble(
  ~variable, ~description,
"CRIM", "per capita crime rate by town",
"ZN", "proportion of residential land zoned for lots over 25,000 sq.ft.",
"INDUS", "proportion of non-retail business acres per town.",
"CHAS", "Charles River dummy variable (1 if tract bounds river; 0 otherwise)",
"NO", "nitric oxides concentration (parts per 10 million)",
"RM", "average number of rooms per dwelling",
"AGE", "proportion of owner-occupied units built prior to 1940",
"DIS", "weighted distances to five Boston employment centres",
"RAD", "index of accessibility to radial highways",
"TAX", "full value property tax rate per $10,000",
"PTRATIO", "pupil teacher ratio by town",
"B", "1000(Bk 0.63)^2 where Bk is the proportion of blacks by town",
"LSTAT", "% lower status of the population",
"MEDV", "Median value of owner-occupied homes in $1000's"
)
