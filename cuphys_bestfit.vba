'Function CUPHYS_BestFit(xdata As Range, xerror As Range, ydata As Range, yerror As Range) As Variant
    'Call CUPHYS_BestFit_Plot(xdata, xerror, ydata, yerror)
    'CUPHYS_BestFit = LinearLeastChiSquaredFit(xdata, xerror, ydata, yerror)
'End Function

Function LinearLeastChiSquaredFit(xdata As Range, xerror As Range, ydata As Range, yerror As Range) As Variant
'Minimize Chi Squared to Find Slope and Intercept
    Dim x2s2 As Double
    Dim xs2 As Double
    Dim ys2 As Double
    Dim xys2 As Double
    Dim invs2 As Double
    x2s2 = 0
    xs2 = 0
    ys2 = 0
    xys2 = 0
    invs2 = 0

    Dim x As Double
    Dim y As Double
    Dim s2 As Double
    For i = 1 To xdata.Rows.Count
        x = xdata.Cells(i, 1)
        y = ydata.Cells(i, 1)
        s2 = yerror.Cells(i, 1) * yerror.Cells(i, 1)

        x2s2 = x2s2 + x * x / s2
        xs2 = xs2 + x / s2
        ys2 = ys2 + y / s2
        xys2 = xys2 + x * y / s2
        invs2 = invs2 + 1 / s2
    Next i

    Dim normalization As Double
    Dim bf_slope As Double
    Dim bf_error_slope As Double
    Dim bf_intercept As Double
    Dim bf_error_intercept As Double

    ' normalization equal to zero will cause #VALUE error
    normalization = invs2 * x2s2 - xs2 * xs2
    bf_slope = (invs2 * xys2 - xs2 * ys2) / normalization
    bf_error_slope = VBA.Sqr(invs2 / normalization) 'note VBA.Sqr
    bf_intercept = (x2s2 * ys2 - xs2 * xys2) / normalization
    bf_error_intercept = VBA.Sqr(x2s2 / normalization)

    'results stored in a 2x4 array
    Dim results(1 To 2, 1 To 4) As Variant
    results(1, 1) = "slope"
    results(2, 1) = bf_slope
    results(1, 2) = "error in slope"
    results(2, 2) = bf_error_slope
    results(1, 3) = "intercept"
    results(2, 3) = bf_intercept
    results(1, 4) = "error in intercept"
    results(2, 4) = bf_error_intercept

    'Array formulas must be entered with Ctrl + Shift + Enter rather than just the Enter key.
    LinearLeastChiSquaredFit = results
End Function

Function CUPHYS_BestFit_Plot(xdata As Range, xerror As Range, ydata As Range, yerror As Range)

    ActiveSheet.Shapes.AddChart2(240, xlXYScatter).Select
    ActiveChart.SetSourceData Source:=Union(xdata, ydata)
    ActiveChart.SetElement (msoElementPrimaryCategoryAxisTitleAdjacentToAxis)
    ActiveChart.SetElement (msoElementPrimaryValueAxisTitleAdjacentToAxis)
    ActiveChart.SetElement (msoElementPrimaryValueGridLinesMinorMajor)
    ActiveChart.SetElement (msoElementPrimaryCategoryGridLinesMinorMajor)
    'error bars
    ActiveChart.FullSeriesCollection(1).HasErrorBars = True
    ActiveChart.FullSeriesCollection(1).HasErrorBars = True
    ActiveChart.FullSeriesCollection(1).ErrorBar _
        Direction:=xlX, _
        Include:=xlBoth, _
        Type:=xlCustom, _
        Amount:=xerror, _
        MinusValues:=xerror
    ActiveChart.FullSeriesCollection(1).ErrorBar _
        Direction:=xlY, _
        Include:=xlBoth, _
        Type:=xlCustom, _
        Amount:=yerror, _
        MinusValues:=yerror
    'trendline
    ActiveChart.FullSeriesCollection(1).Trendlines.Add
    ActiveChart.FullSeriesCollection(1).Trendlines(1).Select
    Selection.DisplayEquation = True
    Selection.DisplayRSquared = True
    ActiveChart.FullSeriesCollection(1).Trendlines(1).DataLabel.Select
    Selection.Left = 246.817
    Selection.Top = 11.022
    'add equations with the correct slope and intercept
    Dim chi As Variant
    ' Cannot use Set chi = ... here
    chi = LinearLeastChiSquaredFit(xdata, xerror, ydata, yerror)
    Dim slope, intercept, rsq As Double
    slope = chi(2, 1) 'we don't use Set here because object is required. Doulbe is not an object
    intercept = chi(2, 3)
    ActiveChart.FullSeriesCollection(1).Trendlines(1).DataLabel.text = _
        "y = " + Format(slope, "#0.00#") + "x + " + Format(intercept, "#0.00#") _
        & Chr(13) & _
        "R² = " + Format(Application.WorksheetFunction.rsq(ydata, xdata), "#0.0000#")
    'axes
    ActiveChart.Axes(xlValue).HasTitle = True
    ActiveChart.Axes(xlCategory).AxisTitle.Select
    ActiveChart.Axes(xlValue, xlPrimary).AxisTitle.Text = "x ( unit )"
    Selection.Format.TextFrame2.TextRange.Characters.Text = "x ( unit )"
    With Selection.Format.TextFrame2.TextRange.Characters(1, 10).ParagraphFormat
        .TextDirection = msoTextDirectionLeftToRight
        .Alignment = msoAlignCenter
    End With
    With Selection.Format.TextFrame2.TextRange.Characters(1, 1).Font
        .BaselineOffset = 0
        .Bold = msoFalse
        .NameComplexScript = "+mn-cs"
        .NameFarEast = "+mn-ea"
        .Fill.Visible = msoTrue
        .Fill.ForeColor.RGB = RGB(89, 89, 89)
        .Fill.Transparency = 0
        .Fill.Solid
        .Size = 10
        .Italic = msoFalse
        .Kerning = 12
        .Name = "+mn-lt"
        .UnderlineStyle = msoNoUnderline
        .Strike = msoNoStrike
    End With
    With Selection.Format.TextFrame2.TextRange.Characters(2, 9).Font
        .BaselineOffset = 0
        .Bold = msoFalse
        .NameComplexScript = "+mn-cs"
        .NameFarEast = "+mn-ea"
        .Fill.Visible = msoTrue
        .Fill.ForeColor.RGB = RGB(89, 89, 89)
        .Fill.Transparency = 0
        .Fill.Solid
        .Size = 10
        .Italic = msoFalse
        .Kerning = 12
        .Name = "+mn-lt"
        .UnderlineStyle = msoNoUnderline
        .Strike = msoNoStrike
    End With
    ActiveChart.Axes(xlValue).AxisTitle.Select
    ActiveChart.Axes(xlValue, xlPrimary).AxisTitle.Text = "y ( unit ) "
    Selection.Format.TextFrame2.TextRange.Characters.Text = "y ( unit ) "
    With Selection.Format.TextFrame2.TextRange.Characters(1, 11).ParagraphFormat
        .TextDirection = msoTextDirectionLeftToRight
        .Alignment = msoAlignCenter
    End With
    With Selection.Format.TextFrame2.TextRange.Characters(1, 1).Font
        .BaselineOffset = 0
        .Bold = msoFalse
        .NameComplexScript = "+mn-cs"
        .NameFarEast = "+mn-ea"
        .Fill.Visible = msoTrue
        .Fill.ForeColor.RGB = RGB(89, 89, 89)
        .Fill.Transparency = 0
        .Fill.Solid
        .Size = 10
        .Italic = msoFalse
        .Kerning = 12
        .Name = "+mn-lt"
        .UnderlineStyle = msoNoUnderline
        .Strike = msoNoStrike
    End With
    With Selection.Format.TextFrame2.TextRange.Characters(2, 10).Font
        .BaselineOffset = 0
        .Bold = msoFalse
        .NameComplexScript = "+mn-cs"
        .NameFarEast = "+mn-ea"
        .Fill.Visible = msoTrue
        .Fill.ForeColor.RGB = RGB(89, 89, 89)
        .Fill.Transparency = 0
        .Fill.Solid
        .Size = 10
        .Italic = msoFalse
        .Kerning = 12
        .Name = "+mn-lt"
        .UnderlineStyle = msoNoUnderline
        .Strike = msoNoStrike
    End With
   
End Function
