Imports System.Data.SqlClient
Imports System.Data
Imports System.Configuration
Imports System.Web.Script.Serialization

Partial Class AuditTrail
    Inherits System.Web.UI.Page

    Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString

    Private Property orderBy As String
        Get
            Return If(ViewState("orderBy"), "DESC")
        End Get
        Set(value As String)
            ViewState("orderBy") = value
        End Set
    End Property

    Private Property searchQuery As String
        Get
            Return If(ViewState("searchQuery"), "")
        End Get
        Set(value As String)
            ViewState("searchQuery") = value
        End Set
    End Property

    Private Property dateFrom As String
        Get
            Return If(ViewState("dateFrom"), "")
        End Get
        Set(value As String)
            ViewState("dateFrom") = value
        End Set
    End Property

    Private Property dateTo As String
        Get
            Return If(ViewState("dateTo"), "")
        End Get
        Set(value As String)
            ViewState("dateTo") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            txtDateFrom.Attributes.Add("type", "date")
            txtDateTo.Attributes.Add("type", "date")
            BindAuditTrail()
            BindChartData()
        End If
    End Sub


    Private Sub BindAuditTrail()
        Dim query As String = "
        SELECT 
            FirstName + ' ' + MiddleName + ' ' + LastName AS FullName, 
            DateModified,
            IPAddress
        FROM tblCompany_User
        WHERE DateModified IS NOT NULL
            AND (FirstName + ' ' + MiddleName + ' ' + LastName LIKE @Search OR @Search = '')
            AND (@DateFrom IS NULL OR DateModified >= @DateFrom)
            AND (@DateTo IS NULL OR DateModified <= @DateTo)
        ORDER BY DateModified " & orderBy

        Using con As New SqlConnection(connStr)
            Using cmd As New SqlCommand(query, con)
                cmd.Parameters.AddWithValue("@Search", "%" & searchQuery & "%")

                If Not String.IsNullOrEmpty(dateFrom) Then
                    cmd.Parameters.AddWithValue("@DateFrom", Convert.ToDateTime(dateFrom))
                Else
                    cmd.Parameters.AddWithValue("@DateFrom", DBNull.Value)
                End If

                If Not String.IsNullOrEmpty(dateTo) Then
                    cmd.Parameters.AddWithValue("@DateTo", Convert.ToDateTime(dateTo).AddDays(1).AddSeconds(-1))
                Else
                    cmd.Parameters.AddWithValue("@DateTo", DBNull.Value)
                End If

                Dim da As New SqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                For Each row As DataRow In dt.Rows
                    If row("IPAddress").ToString() = "::1" Then
                        row("IPAddress") = "127.0.0.1"
                    End If
                Next

                gvAuditTrail.DataSource = dt
                gvAuditTrail.DataBind()
            End Using
        End Using
    End Sub

    Private Sub BindChartData()
        Dim rawData As New Dictionary(Of String, Integer)()

        Dim query As String = "
            SELECT FORMAT(DateModified, 'yyyy-MM') AS MonthKey, COUNT(*) AS Count
            FROM tblCompany_User
            WHERE DateModified IS NOT NULL
            GROUP BY FORMAT(DateModified, 'yyyy-MM')
            ORDER BY MIN(DateModified)"

        Dim minDate As DateTime = DateTime.Now
        Dim maxDate As DateTime = DateTime.Now

        Using con As New SqlConnection(connStr)
            Using cmd As New SqlCommand(query, con)
                con.Open()
                Using reader As SqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim key As String = reader("MonthKey").ToString()
                        rawData(key) = Convert.ToInt32(reader("Count"))
                    End While
                End Using
            End Using
        End Using

        If rawData.Count > 0 Then
            minDate = DateTime.ParseExact(rawData.Keys.First(), "yyyy-MM", Nothing)
            maxDate = DateTime.ParseExact(rawData.Keys.Last(), "yyyy-MM", Nothing)
        End If

        Dim labels As New List(Of String)()
        Dim values As New List(Of Integer)()

        Dim current As DateTime = minDate
        While current <= maxDate
            Dim key As String = current.ToString("yyyy-MM")
            labels.Add(current.ToString("MMMM yyyy"))
            values.Add(If(rawData.ContainsKey(key), rawData(key), 0))
            current = current.AddMonths(1)
        End While

        Dim chartData As New Dictionary(Of String, Object) From {
            {"labels", labels},
            {"values", values}
        }

        Dim json As String = New JavaScriptSerializer().Serialize(chartData)
        litChartData.Text = json
    End Sub

    Protected Sub gvAuditTrail_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvAuditTrail.PageIndex = e.NewPageIndex
        BindAuditTrail()
    End Sub

    Protected Sub ddlSort_SelectedIndexChanged(sender As Object, e As EventArgs)
        orderBy = ddlSort.SelectedValue
        BindAuditTrail()
    End Sub

    Protected Sub txtSearch_TextChanged(sender As Object, e As EventArgs)
        searchQuery = txtSearch.Text.Trim()
        BindAuditTrail()
    End Sub

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        lblError.Text = ""

        Dim fromDate As DateTime
        Dim toDate As DateTime
        Dim validFormat As Boolean = True

        ' Validate From Date
        If Not String.IsNullOrWhiteSpace(txtDateFrom.Text) Then
            If Not DateTime.TryParseExact(txtDateFrom.Text.Trim(), {"yyyy-MM-dd", "MM/dd/yyyy"},
            Globalization.CultureInfo.InvariantCulture, Globalization.DateTimeStyles.None, fromDate) Then
                lblError.Text = "Invalid format or value in 'From' date."
                validFormat = False
            ElseIf fromDate.Year < 1753 OrElse fromDate.Year > 9999 Then
                lblError.Text = "'From' date year must be between 1753 and 9999."
                validFormat = False
            End If
        End If

        ' Validate To Date
        If Not String.IsNullOrWhiteSpace(txtDateTo.Text) Then
            If Not DateTime.TryParseExact(txtDateTo.Text.Trim(), {"yyyy-MM-dd", "MM/dd/yyyy"},
            Globalization.CultureInfo.InvariantCulture, Globalization.DateTimeStyles.None, toDate) Then
                lblError.Text = "Invalid format or value in 'To' date."
                validFormat = False
            ElseIf toDate.Year < 1753 OrElse toDate.Year > 9999 Then
                lblError.Text = "'To' date year must be between 1753 and 9999."
                validFormat = False
            End If
        End If

        If Not validFormat Then
            Return
        End If

        dateFrom = txtDateFrom.Text.Trim()
        dateTo = txtDateTo.Text.Trim()

        BindAuditTrail()
    End Sub




    Protected Sub btnClearFilter_Click(sender As Object, e As EventArgs)
        txtDateFrom.Text = ""
        txtDateTo.Text = ""
        lblError.Text = ""
        dateFrom = ""
        dateTo = ""
        BindAuditTrail()
    End Sub
End Class
