* putdocx_report.do: the same report as report.md, but written with
* Stata commands instead of Markdown (Stata 15 or later)

sysuse auto, clear
twoway (scatter price mpg) (lfit price mpg),  ///
    ytitle("Price (USD)") xtitle("Mileage (mpg)")
graph export price_mpg.png, replace width(1600)
regress price mpg weight

putdocx clear
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("My First Stata Report")
putdocx paragraph
putdocx text ("Holding weight constant, one more mile per gallon changes the price by ")
putdocx text (_b[mpg]), nformat(%5.1f)
putdocx text (" dollars.")
putdocx table results = etable
putdocx paragraph, halign(center)
putdocx image price_mpg.png, width(6)
putdocx save putdocx_report.docx, replace
