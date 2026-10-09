<<dd_version: 2>>

<style>pre, pre code { font-size: 9pt; }</style>

# My First Stata Dynamic Document

This document was written in **Markdown** and turned into a Word document
by Stata's `dyndoc` command. Every number below is computed by Stata
when the document is created. Nothing is typed by hand.

<<dd_do: quietly>>
sysuse auto, clear
summarize price
<</dd_do>>

## The data

We use the 1978 automobile data that ships with Stata. The data contain
<<dd_display: r(N)>> cars, and the average price is
<<dd_display: %9.0fc r(mean)>> dollars.

## A regression

~~~~
<<dd_do>>
regress price mpg weight
<</dd_do>>
~~~~

Holding weight constant, one more mile per gallon changes the price by
<<dd_display: %5.1f _b[mpg]>> dollars.

## A figure

<<dd_do: quietly>>
twoway (scatter price mpg) (lfit price mpg),  ///
    ytitle("Price (USD)") xtitle("Mileage (mpg)")
<</dd_do>>

<<dd_graph: saving(price_mpg.png) replace height(400)>>
