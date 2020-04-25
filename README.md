# MCStockSimulator

Author:  Dana McDaniel
Date:  04/25/20

Do I hold my stock, or do I sell it?  This is a common question that many of us face during times of economic uncertainty and prosperity, alike. This script accepts a stock ticker and some associated parameters as input and uses a log-normal model to estimate ticker price with markov-chain monte-carlo simulation.  Percentile performances for different time frames provide some clarity into financial risk, and can help us make informed financial decisions.

The plots and tables are pretty interesting!  Reader beware:  This code does not constitute financial advice, or even sound strategy.  Please consult a fiduciary financial advisor before making important financial decisions.

## Example:  Holding ROG.VX for one year, analysis kept from 2019

|Performance percentile | $ROG.VX Price | Simple return (%) | $VOO simple return (%)|
-----|-----|-----|-----|
"10%" | 134.75 | -51.3 | 4.1
"25%" | 177.88 | -35.8 | 19.3
"33%" | 205.59 | -25.8 | 27.4
"50%" | 261.83 | -5.5 | 44.7
"66%" | 314.92 | 13.7 | 60.1
"75%" | 362.2 | 30.8 | 70.5
"90%" | 471.3 | 70.2 | 100.3



![Randomwalk](https://github.com/danamcdaniel1/MCStockSimulator/blob/master/ROGVX_one_year_random_walk.png)

![Price](https://github.com/danamcdaniel1/MCStockSimulator/blob/master/ROGVX_one_year_price_dist.png)
