Sub MacroSub(oSheetToFill As Object, numRows As Integer, numCols As Integer)
  Dim i As Integer, j As Integer
  Dim sMsg As String
  For i = 1 To numRows
    For j = 1 To numCols
      sMsg = "Cell(" & Format(i) & "," & Format(j) & ")"
      oSheetToFill.Cells(i, j).Value = sMsg
    Next j
  Next i
End Sub

Function MacroFun(oSheetToFill As Object, numRows As Integer, numCols As Integer)
  Dim i As Integer, j As Integer
  Dim sMsg As String
  For i = 1 To numRows
    For j = 1 To numCols
      sMsg = "Cell(" & Format(i) & "," & Format(j) & ")"
      oSheetToFill.Cells(i, j).Value = sMsg
    Next j
  Next i
  MacroFun = numRows * numCols
End Function
