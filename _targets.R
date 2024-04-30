# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
    packages = c("tibble",
                 "broom",
                 "ggplot2",
                 "DT",
                 "dplyr") # Packages that your targets need for their tasks.
)

# Run the R scripts in the R/ folder with your custom functions:
load_games = function(file = 'data/processed/games_historical.csv') {
    
    readr::read_csv(file)
    
}

prepare_games = function(data) {
    
    data |>
        filter(!is.na(bayesaverage)) |>
        filter(!is.na(averageweight))
}

model_complexity = function(data) {
    
    lm(average ~ averageweight,
       data =data)
}

get_residuals = function(model,
                         data) {
    
    model |>
        augment(
            newdata = data
        ) |>
        select(game_id,
               name,
               yearpublished,
               bayesaverage,
               average,
               averageweight,
               usersrated,
               .fitted,
               .resid)
    
}

get_adjusted_ratings = function(residuals,
                                votes = 1900) {
    residuals |>
        mutate(adjusted = ((votes * 5.5) + (usersrated * (.resid + mean(average, na.rm = T)))) / (usersrated + votes))
    
}

table_ratings = function(data) {
    
    data |>
        arrange(desc(adjusted)) |>
        mutate(diff = adjusted -bayesaverage) |>
        select(
            ID = game_id,
            Published = yearpublished,
            Name = name,
            Complexity = averageweight,
            `Geek Rating` = bayesaverage,
            `Adjusted Rating` = adjusted,
            Adjustment = diff
        ) |>
        mutate_if(is.numeric, round, 2) |>
        DT::datatable(
            escape=F,
            rownames = F,
            filter = list(position = 'top'),
            class = list(stripe =F),
            options = list(pageLength = 25,
                           editable =T,
                           initComplete = htmlwidgets::JS(
                               "function(settings, json) {",
                               paste0("$(this.api().table().container()).css({'font-size': '", '10pt', "'});"),
                               "}"),
                           scrollX=F,
                           autowidth=T,
                           columnDefs = list(
                               list(className = 'dt-center',
                                    visible=T,
                                    targets=c("Published",
                                              "Complexity",
                                              "Geek Rating",
                                              "Adjusted Rating",
                                              "Adjustment")
                               ),
                               list(visible = F,
                                    targets=c("ID"))
                           )
            )
        )
}

add_color_rating= function(table,
                           low = 4,
                           high = 9,
                           by = 0.01,
                           low_color = "red",
                           high_color = "deepskyblue1") {
    
    ratingColorRamp = colorRampPalette(c(low_color, "white", high_color))
    
    table |>
        formatStyle(c("Adjusted Rating", "Geek Rating"),
                    backgroundColor = styleInterval(seq(low, high, by),
                                                    ratingColorRamp(length(seq(low, high, by))+1))
        )
    
}

add_color_complexity = function(table,
                                low = 1,
                                high = 6,
                                by = 0.01,
                                low_color = "white",
                                high_color = "red") {
    
    colorRamp = colorRampPalette(c(low_color, high_color))
    
    table |>
        formatStyle(c("Complexity"),
                    backgroundColor = styleInterval(seq(low, high, by),
                                                    colorRamp(length(seq(low, high, by))+1))
        )
}

add_color_adjustment = function(table,
                                low = -4,
                                high = 4,
                                by = 0.01,
                                high_color = "dodgerblue",
                                low_color = "orange") {
    
    colorRamp = colorRampPalette(c(low_color, "white", high_color))
    
    table |>
        formatStyle(c("Adjustment"),
                    backgroundColor = styleInterval(seq(low, high, by),
                                                    colorRamp(length(seq(low, high, by))+1))
        )
}


# Replace the target list below with your own:
list(
    tar_target(
        name = games_raw,
        command = 
            load_games()
    ),
    tar_target(
        name = games,
        command = 
            games_raw |>
            prepare_games()
    ),
    tar_target(
        name = plot_complexity,
        command =
            games |>
            ggplot(aes(x=averageweight,
                       y=average))+
            geom_point()+
            ggpubr::stat_cor()
    ),
    tar_target(
        name = model,
        command = 
            games |> 
            model_complexity()
    ),
    tar_target(
        name = glanced,
        command = 
            model |>
            glance()
    ),
    tar_target(
        name = residuals,
        command = 
            model |>
            get_residuals(data = games)
    ), 
    tar_target(
        name = plot_residuals,
        command = 
            residuals |>
            ggplot(aes(x=averageweight,
                       y=.resid))+
            geom_point()+
            ggpubr::stat_cor()
    ),
    tar_target(
        name = adjusted,
        command = 
            residuals |>
            get_adjusted_ratings()
    ),
    tar_target(
        name = table,
        command = 
            adjusted |>
            table_ratings() |>
            add_color_rating() |>
            add_color_complexity() |>
            add_color_adjustment()
    )
)
