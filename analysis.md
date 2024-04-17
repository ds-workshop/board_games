# Analysis


- [Data](#data)
- [Questions](#questions)
  - [What is the oldest game?](#what-is-the-oldest-game)
  - [What are the highest and lowest rated
    games?](#what-are-the-highest-and-lowest-rated-games)
  - [What is the relationship between **average** and
    **averageweight**?](#what-is-the-relationship-between-average-and-averageweight)

How have board games been rated by the BoardGameGeek (BGG) community
over time? This analysis looks at historical games and their ratings on
BGG.

# Data

The data comes from BoardGameGeek.com and contains 28020 games.

``` r
games |>
    sample_n(5)
```

    # A tibble: 5 × 26
      game_id name       yearpublished averageweight usersrated average bayesaverage
        <dbl> <chr>              <dbl>         <dbl>      <dbl>   <dbl>        <dbl>
    1  286135 Khartoum:…          2019          3            35    7.53         5.53
    2   34320 Shanghaien          2008          1.47       1349    6.52         5.90
    3  158899 Colt Expr…          2014          1.83      31758    7.09         6.96
    4  218580 Divinity …          2017          1.91        503    6.85         5.76
    5  368352 Satori              2023          3.37        245    7.73         5.72
    # ℹ 19 more variables: numweights <dbl>, minplayers <dbl>, maxplayers <dbl>,
    #   playingtime <dbl>, minplaytime <dbl>, maxplaytime <dbl>, minage <dbl>,
    #   description <chr>, thumbnail <chr>, image <chr>, categories <chr>,
    #   mechanics <chr>, publishers <chr>, designers <chr>, artists <chr>,
    #   families <chr>, mechanisms <chr>, components <chr>, themes <chr>

``` r
games |>
    filter(yearpublished > 1900) |>
    group_by(yearpublished) |>
    count() |>
    ggplot(aes(x=yearpublished, y=n))+
    geom_col()
```

![](analysis_files/figure-commonmark/plot-games-by-year-1.png)

The dataset contains games earlier than the 1900s, but the majority of
games in the dataset were published in the last 30 years.

BoardGameGeek aggregates ratings by thousands of users.

- **average**: average rating on a 0-10 scale by all users that have
  rated the game

- **usersrated**: the number of users that have rated the game

- **averageweight**: complexity of a game on a 1-5 scale, with 1 being
  simple and 5 being complex

- **bayesaverage**: also known as the Geek rating, a Bayesian average of
  the community’s average rating

# Questions

### What is the oldest game?

Find the oldest game in this dataset. Display its game_id, name,
yearpublished.

``` r
games |>
    arrange(yearpublished) |>
    slice_head(n = 1) |>
    select(game_id, name, yearpublished, description)
```

    # A tibble: 1 × 4
      game_id name  yearpublished description                                       
        <dbl> <chr>         <dbl> <chr>                                             
    1    2399 Senet         -3500 "Senet is an ancient Egyptian board game similar …

What is this game? Display its description.

### What are the highest and lowest rated games?

Find the top 5 highest/lowest rated games based on *bayesaverage*.
Display their game_id, name, yearpublished, bayesaverage, and
averageweight.

``` r
games |>
    arrange(bayesaverage) |>
    slice_head(n = 5) |>
    select(game_id, name, yearpublished, bayesaverage, averageweight)
```

    # A tibble: 5 × 5
      game_id name               yearpublished bayesaverage averageweight
        <dbl> <chr>                      <dbl>        <dbl>         <dbl>
    1   11901 Tic-Tac-Toe                -1300         3.64          1.28
    2    5432 Chutes and Ladders          -200         3.66          1.03
    3    5048 Candy Land                  1949         3.84          1.12
    4    7316 Bingo                       1530         4.05          1.04
    5    1406 Monopoly                    1935         4.29          1.62

``` r
games |>
    arrange(bayesaverage) |>
    slice_tail(n = 5) |>
    select(game_id, name, yearpublished, bayesaverage, averageweight)
```

    # A tibble: 5 × 5
      game_id name                          yearpublished bayesaverage averageweight
        <dbl> <chr>                                 <dbl>        <dbl>         <dbl>
    1  402220 Disney The Muppet Christmas …          2023           NA           1  
    2  402261 Graffiti                               2023           NA           2  
    3  402527 Luminis                                2023           NA           1.5
    4  402668 Donde las papas queman                 2022           NA           1  
    5  403122 Along History                          2023           NA           3  

### What is the relationship between **average** and **averageweight**?

Find the correlation between the BGG average rating (*average*) and
**averageweight**.

Display this relationship visually by making a scatter plot with
*averageweight* on the x axis and and average on the y axis. (It might
help to jitter the x axis slightly for visibility).
