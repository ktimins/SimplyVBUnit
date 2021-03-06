VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PersistableConstraint"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'The MIT License (MIT)
'Copyright (c) 2012 Kelly Ethridge
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights to
'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
'the Software, and to permit persons to whom the Software is furnished to do so,
'subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
'PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
'FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
'OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
'DEALINGS IN THE SOFTWARE.
'
'
' Module: PersistableConstraint
'
Option Explicit
Implements IConstraint

Private Const ERR_CANNOTPERSISTARRAYS   As Long = 328
Private Const ERR_OBJECTNOTPERSISTABLE  As Long = 330


Private mActual As Variant


Public Function Matches(ByRef Actual As Variant) As Boolean
    Dim Result As Boolean
    If IsObject(Actual) Then
        On Error Resume Next
        Dim Bag As New PropertyBag
        Bag.WriteProperty "Item", Actual, Nothing
        
        If Err.Number = 0 Then
            Dim Item As Object
            Set Item = Bag.ReadProperty("Item", Nothing)
            Result = (Not Item Is Nothing)
        End If
    End If
    
    If Not Result Then
        VariantCopyInd mActual, Actual
        
        If Err.Number = ERR_CANNOTPERSISTARRAYS Or Err.Number = ERR_OBJECTNOTPERSISTABLE Then
            Err.Clear
        End If
    End If
    
    Matches = Result
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IConstraint Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function IConstraint_Matches(Actual As Variant) As Boolean
    IConstraint_Matches = Matches(Actual)
End Function

Private Sub IConstraint_WriteActualValueTo(ByVal Writer As TextMessageWriter)
    Writer.WriteText "<{0}>", TypeName(mActual)
End Sub

Private Sub IConstraint_WriteDescriptionTo(ByVal Writer As TextMessageWriter)
    Writer.WriteText "PropertyBag persistable"
End Sub

Private Sub IConstraint_WriteMessageTo(ByVal Writer As TextMessageWriter)
    Writer.DisplayConstraintDifferences Me
End Sub
