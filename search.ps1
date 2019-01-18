$excel = new-object -ComObject Excel.Application
#$excel.visible = $false
$WorkBook = $excel.Workbooks.Open('C:\excelpath\workbook.csv')
$WorkSheet = $WorkBook.Sheets.Item(1)
$WorkSheet.Name
$Found = $WorkSheet.Cells.Find('Install')
$BeginAddress = $Found.Address(0,0,1,1)
$BeginAddress
[pscustomobject]@{
    WorkSheet = $WorkSheet.Name
    Column = $Found.Column
    Row = $Found.Row
    Text = $Found.Text
    Address = $BeginAddress
}
Do {
    $Found = $WorkSheet.Cells.FindNext($Found)
    $Address = $Found.Address(0,0,1,1)
    If ($Address -eq $BeginAddress){
        Break
    }
    [pscustomobject]@{
    WorkSheet = $WorkSheet.Name
    Column = $Found.Column
    Row = $Found.Row
    Text = $Found.Text
    Address = $BeginAddress
    }
} Until ($False)
