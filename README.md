## Set-up

Clone the repository

```{bash}
git clone https://github.com/towlma/targets-pipeline-training.git
```

Restore required dependencies
```{r}
install.packages("renv")
renv::restore()
```

## Play with the code

Run the pipeline
```{r}
targets::tar_make()
```

Visualize the pipeline
```{r}
targets::tar_visnetwork()
```

Reset the pipeline
```{r}
targets::tar_destroy()
```

