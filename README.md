# MCStockSimulator

Author:  Dana McDaniel
Date:  03/03/19

This script accepts a stock ticker and some associated parameters as input and uses a log-normal model to estimate ticker price after a specified holding perior.

I was inspired by a recent HR policy change at my company.  Employees are now allowed to select from several mixes of SARs and RSUs.  Of course, the value of each bundle varies based on the future stock price.

So I did what any reasonable code monkey who attempted a bachelors in math and economics does after learning how to program: spent my Sunday making R scripts to model stock prices using monte carlo simulations from recent price behavior.   Basically I created a log-normal MC model with parameters from ROG.VX price behavior between when I started at GNE (about 2014-06-01) and today.  Modeling was performed by simulating daily price movement over a 4 year vesting period.   VOO is your "control stock" to give you a sense of how he S&P500 American Large Caps may perform in comparison.

The plots and tables are pretty compelling!  Reader beware:  This code does not constitute financial advice, or even sound strategy.  Please consult your fiduciary financial advisor before making important financial decisions.

## Example:  Holding ROG.VX for one year

|Performance percentile | $ROG.VX Price | Simple return (%) | $VOO simple return (%)|
-----|-----|-----|-----|
"10%" | 134.75 | -51.3 | 4.1
"25%" | 177.88 | -35.8 | 19.3
"33%" | 205.59 | -25.8 | 27.4
"50%" | 261.83 | -5.5 | 44.7
"66%" | 314.92 | 13.7 | 60.1
"75%" | 362.2 | 30.8 | 70.5
"90%" | 471.3 | 70.2 | 100.3

