* putpdf_report.do: the same, as a PDF (Stata 15 or later)

sysuse auto, clear
twoway (scatter price mpg) (lfit price mpg),  ///
    ytitle("Price (USD)") xtitle("Mileage (mpg)")
graph export price_mpg.png, replace width(1600)
regress price mpg weight

putpdf clear
putpdf begin
putpdf paragraph, halign(center)
putpdf text ("My First Stata Report"), bold
putpdf paragraph
putpdf text ("Holding weight constant, one more mile per gallon changes the price by ")
putpdf text (_b[mpg]), nformat(%5.1f)
putpdf text (" dollars.")
putpdf table results = etable
putpdf paragraph, halign(center)
putpdf image price_mpg.png, width(6)
putpdf save putpdf_report.pdf, replace
