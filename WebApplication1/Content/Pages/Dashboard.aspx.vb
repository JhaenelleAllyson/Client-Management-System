Imports System.Configuration
Imports System.Data
Imports System.Data.SqlClient
Imports System.Web.Script.Serialization
Imports Newtonsoft.Json

Public Class dashboard
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ViewState("StatusFilter") = ""
            LoadAlertsSummary()
            LoadTotalClients()
            LoadRecentLogins()
            LoadSubscriptionStatus()
            LoadNearingExpiration()
            LoadSubscriptionChartData()
        End If

        LoadLoginTrends()
        LoadExpiringClientsChartData()
    End Sub
    Private Sub LoadTotalClients()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As String = "SELECT COUNT(*) FROM tblCompany_Information"

        Try
            Using conn As New SqlConnection(connStr),
              cmd As New SqlCommand(query, conn)
                conn.Open()
                lblTotalClients.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString()
            End Using
        Catch ex As Exception
            lblTotalClients.Text = "Error loading clients: " & ex.Message
        End Try
    End Sub

    Private Sub LoadAlertsSummary()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString

        Try
            Using conn As New SqlConnection(connStr)
                conn.Open()

                Dim nearing7DaysQuery As String = "
                SELECT COUNT(*) 
                FROM tblCompany_User 
                WHERE DateExpiration IS NOT NULL 
                  AND DateExpiration > CAST(GETDATE() AS DATE)
                  AND DateExpiration <= DATEADD(DAY, 7, CAST(GETDATE() AS DATE))"

                Dim expiredTodayQuery As String = "
                SELECT COUNT(*) 
                FROM tblCompany_User 
                WHERE DateExpiration = CAST(GETDATE() AS DATE)"

                Dim nearing7DaysCount As Integer
                Dim expiredTodayCount As Integer

                Using cmd1 As New SqlCommand(nearing7DaysQuery, conn)
                    nearing7DaysCount = Convert.ToInt32(cmd1.ExecuteScalar())
                End Using
                Using cmd2 As New SqlCommand(expiredTodayQuery, conn)
                    expiredTodayCount = Convert.ToInt32(cmd2.ExecuteScalar())
                End Using

                lblExpiredToday.Text = $"{expiredTodayCount} client(s) have subscriptions that expired today."
                lblNearing7Days.Text = $"{nearing7DaysCount} client(s) have subscriptions expiring within the next 7 days."
            End Using

        Catch ex As Exception
            lblExpiredToday.Text = "Error: " & ex.Message
            lblNearing7Days.Text = "Error: " & ex.Message
        End Try
    End Sub

    Private Sub LoadRecentLogins()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As String = "
        SELECT TOP 10 
            (LastName + ', ' + FirstName + ' ' + MiddleName) AS ClientName, 
            DateLastLogin AS LoginDate
        FROM tblCompany_User
        WHERE DateLastLogin IS NOT NULL
        ORDER BY DateLastLogin DESC"

        Try
            Using conn As New SqlConnection(connStr)
                Using cmd As New SqlCommand(query.Trim(), conn)
                    conn.Open()
                    Dim reader As SqlDataReader = cmd.ExecuteReader()
                    Dim dt As New DataTable()
                    dt.Load(reader)
                    dt.Columns.Add("LoginTime", GetType(String))
                    For Each row As DataRow In dt.Rows
                        row("LoginTime") = "--:--"
                    Next

                    gvRecentLogins.DataSource = dt
                    gvRecentLogins.DataBind()
                End Using
            End Using
        Catch ex As Exception
            gvRecentLogins.EmptyDataText = "Error loading recent logins: " & ex.Message
        End Try
    End Sub

    Protected Sub btnViewAll_Click(sender As Object, e As EventArgs)
        LoadAllLogins(txtLoginSearch.Text.Trim()) ' <-- Ensure search term is passed
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "Pop", "$('#modalAllLogins').modal('show');", True)
    End Sub

    Private Sub LoadAllLogins(Optional searchTerm As String = "")
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As String = "
        SELECT 
            ci.Company_Name,
            (cu.LastName + ', ' + cu.FirstName + ' ' + cu.MiddleName) AS ClientName,
            cu.FirstName,
            cu.LastName,
            cu.MiddleName,
            cu.DateLastLogin AS LoginDate,
            cu.IPAddress
        FROM tblCompany_User cu
        INNER JOIN tblCompany_Information ci ON cu.Company_Code = ci.Company_Code
        WHERE cu.DateLastLogin IS NOT NULL
        ORDER BY cu.DateLastLogin DESC"

        Try
            Using conn As New SqlConnection(connStr)
                Using cmd As New SqlCommand(query.Trim(), conn)
                    conn.Open()
                    Dim reader As SqlDataReader = cmd.ExecuteReader()
                    Dim dt As New DataTable()
                    dt.Load(reader)

                    If Not String.IsNullOrWhiteSpace(searchTerm) Then
                        searchTerm = searchTerm.Trim().ToLower()
                        Dim searchWords = searchTerm.Split(New Char() {" "c}, StringSplitOptions.RemoveEmptyEntries)

                        Dim filtered = dt.AsEnumerable().Where(Function(row)
                                                                   Return searchWords.All(Function(word)
                                                                                              Return row("FirstName").ToString().ToLower().Contains(word) OrElse
                                                                                                 row("LastName").ToString().ToLower().Contains(word) OrElse
                                                                                                 row("MiddleName").ToString().ToLower().Contains(word) OrElse
                                                                                                 row("Company_Name").ToString().ToLower().Contains(word) OrElse
                                                                                                 row("ClientName").ToString().ToLower().Contains(word)
                                                                                          End Function)
                                                               End Function)

                        If filtered.Any() Then
                            dt = filtered.CopyToDataTable()
                            lblNoLoginResults.Visible = False
                        Else
                            dt.Clear()
                            lblNoLoginResults.Visible = True
                        End If
                    Else
                        lblNoLoginResults.Visible = False
                    End If

                    If Not dt.Columns.Contains("LoginTime") Then
                        dt.Columns.Add("LoginTime", GetType(String))
                    End If

                    For Each row As DataRow In dt.Rows
                        row("LoginTime") = "--:--"
                    Next

                    gvAllLogins.DataSource = dt
                    gvAllLogins.DataBind()
                End Using
            End Using
        Catch ex As Exception
            gvAllLogins.EmptyDataText = "Error loading all logins: " & ex.Message
        End Try
    End Sub

    Protected Sub btnLoginSearch_Click(sender As Object, e As EventArgs)
        LoadAllLogins(txtLoginSearch.Text.Trim())
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "Pop", "$('#modalAllLogins').modal('show');", True)
    End Sub

    Protected Sub btnClearLoginSearch_Click(sender As Object, e As EventArgs)
        txtLoginSearch.Text = ""
        LoadAllLogins() ' Reload with no filter
    End Sub

    Private Sub LoadLoginTrends()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As String = "
        SELECT 
            CAST(DateLastLogin AS DATE) AS LoginDate, 
            COUNT(*) AS LoginCount
        FROM tblCompany_User
        WHERE DateLastLogin >= CAST(DATEADD(DAY, -6, GETDATE()) AS DATE)
        GROUP BY CAST(DateLastLogin AS DATE)
        ORDER BY LoginDate"

        Dim loginCounts As New Dictionary(Of String, Integer)
        For i As Integer = 6 To 0 Step -1
            Dim day As Date = Date.Today.AddDays(-i)
            loginCounts(day.ToString("MMM dd")) = 0
        Next

        Try
            Using conn As New SqlConnection(connStr)
                Using cmd As New SqlCommand(query.Trim(), conn)
                    conn.Open()
                    Using reader As SqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            Dim dateVal As Date = reader.GetDateTime(0)
                            Dim count As Integer = reader.GetInt32(1)
                            loginCounts(dateVal.ToString("MMM dd")) = count
                        End While
                    End Using
                End Using
            End Using

            Dim dates As List(Of String) = loginCounts.Keys.ToList()
            Dim counts As List(Of Integer) = loginCounts.Values.ToList()

            Dim jsonDates As String = JsonConvert.SerializeObject(dates)
            Dim jsonCounts As String = JsonConvert.SerializeObject(counts)

            Dim script As String = $"renderLoginChart({jsonDates}, {jsonCounts});"
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "RenderLoginChart", script, True)

        Catch ex As Exception
            ' Display error
        End Try
    End Sub

    Private Sub LoadNearingExpiration(Optional searchTerm As String = "")
        Dim filterValue As String = ddlExpirationFilter.SelectedValue
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As New StringBuilder()

        query.AppendLine("
        SELECT 
            (LastName + ', ' + FirstName + ' ' + MiddleName) AS ClientName,
            LastName,
            FirstName,
            MiddleName,
            DateExpiration,
            DATEDIFF(DAY, GETDATE(), DateExpiration) AS DaysRemaining
        FROM tblCompany_User
        WHERE DateExpiration IS NOT NULL
        AND DateExpiration >= CAST(GETDATE() AS DATE)")

        If filterValue = "Today" Then
            query.AppendLine("AND CAST(DateExpiration AS DATE) = CAST(GETDATE() AS DATE)")
        ElseIf IsNumeric(filterValue) AndAlso Convert.ToInt32(filterValue) > 0 Then
            query.AppendLine("AND DATEDIFF(DAY, GETDATE(), DateExpiration) <= @Days")
        End If

        query.AppendLine("ORDER BY DateExpiration ASC, (LastName + ', ' + FirstName) ASC")

        Try
            Using conn As New SqlConnection(connStr)
                Using cmd As New SqlCommand(query.ToString(), conn)
                    If IsNumeric(filterValue) AndAlso Convert.ToInt32(filterValue) > 0 Then
                        cmd.Parameters.AddWithValue("@Days", Convert.ToInt32(filterValue))
                    End If

                    Using sda As New SqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        sda.Fill(dt)

                        If Not String.IsNullOrWhiteSpace(searchTerm) Then
                            searchTerm = searchTerm.Trim().ToLower()
                            Dim searchWords = searchTerm.Split(New Char() {" "c}, StringSplitOptions.RemoveEmptyEntries)

                            Dim filtered = dt.AsEnumerable().Where(Function(row)
                                                                       Return searchWords.All(Function(word)
                                                                                                  Return (row("FirstName").ToString().ToLower().Contains(word) OrElse
                                                                                                      row("LastName").ToString().ToLower().Contains(word) OrElse
                                                                                                      row("MiddleName").ToString().ToLower().Contains(word) OrElse
                                                                                                      row("ClientName").ToString().ToLower().Contains(word))
                                                                                              End Function)
                                                                   End Function)

                            If filtered.Any() Then
                                dt = filtered.CopyToDataTable()
                                lblNoExpiringResults.Visible = False
                            Else
                                dt.Clear()
                                lblNoExpiringResults.Visible = True
                            End If
                        Else
                            lblNoExpiringResults.Visible = False
                        End If

                        gvNearingExpiration.DataSource = dt
                        gvNearingExpiration.DataBind()
                    End Using
                End Using
            End Using
        Catch ex As Exception
            gvNearingExpiration.EmptyDataText = "Error: " & ex.Message
        End Try
    End Sub

    Protected Sub btnSearchExpiring_Click(sender As Object, e As EventArgs)
        LoadNearingExpiration(txtSearchExpiring.Text)
    End Sub

    Protected Sub btnClearExpiringSearch_Click(sender As Object, e As EventArgs) Handles btnClearExpiringSearch.Click
        txtSearchExpiring.Text = ""
        lblNoExpiringResults.Visible = False
        LoadNearingExpiration()
    End Sub

    Protected Sub ddlExpirationFilter_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadNearingExpiration(txtSearchExpiring.Text)
    End Sub

    Private Sub LoadExpiringClientsChartData()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As String = "
        SELECT 
            CAST(DateExpiration AS DATE) AS ExpiryDate,
            COUNT(*) AS ClientCount
        FROM tblCompany_User
        WHERE 
            DateExpiration IS NOT NULL AND
            DateExpiration >= CAST(GETDATE() AS DATE) AND
            DateExpiration <= DATEADD(DAY, 6, CAST(GETDATE() AS DATE))
        GROUP BY CAST(DateExpiration AS DATE)
        ORDER BY ExpiryDate
    "

        Dim labels As New List(Of String)()
        Dim data As New List(Of Integer)()

        Try
            Using conn As New SqlConnection(connStr)
                Using cmd As New SqlCommand(query, conn)
                    conn.Open()
                    Dim reader As SqlDataReader = cmd.ExecuteReader()

                    Dim dateCounts As New Dictionary(Of String, Integer)()
                    For i As Integer = 0 To 6
                        Dim dateKey As String = DateTime.Now.AddDays(i).ToString("MMM dd")
                        dateCounts(dateKey) = 0
                    Next

                    While reader.Read()
                        Dim dateKey As String = Convert.ToDateTime(reader("ExpiryDate")).ToString("MMM dd")
                        dateCounts(dateKey) = Convert.ToInt32(reader("ClientCount"))
                    End While

                    For Each kvp In dateCounts
                        labels.Add(kvp.Key)
                        data.Add(kvp.Value)
                    Next
                End Using
            End Using
        Catch ex As Exception
            labels.Clear()
            data.Clear()
            labels.Add("Error")
            data.Add(0)
        End Try

        Dim labelsJson = New JavaScriptSerializer().Serialize(labels)
        Dim dataJson = New JavaScriptSerializer().Serialize(data)

        Dim script As String = $"renderExpiringChart({labelsJson}, {dataJson});"
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "RenderExpiringChart", script, True)
    End Sub

    Private Sub LoadSubscriptionStatus(Optional statusFilter As String = "", Optional searchTerm As String = "")
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As New StringBuilder()

        query.AppendLine("
        SELECT 
            (LastName + ', ' + FirstName + ' ' + MiddleName) AS ClientName,
            LastName,
            FirstName,
            MiddleName,
            DateExpiration,
            CASE 
                WHEN DateExpiration >= CAST(GETDATE() AS DATE) THEN 'Active'
                ELSE 'Expired'
            END AS Status
        FROM tblCompany_User
        WHERE DateExpiration IS NOT NULL")

        If statusFilter = "Active" Then
            query.AppendLine("AND DateExpiration >= CAST(GETDATE() AS DATE)")
        ElseIf statusFilter = "Expired" Then
            query.AppendLine("AND DateExpiration < CAST(GETDATE() AS DATE)")
        End If

        query.AppendLine("ORDER BY ClientName ASC")

        Try
            Using conn As New SqlConnection(connStr)
                Using cmd As New SqlCommand(query.ToString(), conn)
                    Using sda As New SqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        sda.Fill(dt)

                        If Not String.IsNullOrWhiteSpace(searchTerm) Then
                            searchTerm = searchTerm.Trim().ToLower()
                            Dim searchWords = searchTerm.Split(New Char() {" "c}, StringSplitOptions.RemoveEmptyEntries)

                            Dim filtered = dt.AsEnumerable().Where(Function(row)
                                                                       Return searchWords.All(Function(word)
                                                                                                  Return (row("FirstName").ToString().ToLower().Contains(word) OrElse
                                                                                                      row("LastName").ToString().ToLower().Contains(word) OrElse
                                                                                                      row("MiddleName").ToString().ToLower().Contains(word) OrElse
                                                                                                      row("ClientName").ToString().ToLower().Contains(word))
                                                                                              End Function)
                                                                   End Function)

                            If filtered.Any() Then
                                dt = filtered.CopyToDataTable()
                                lblNoSubscriptionResults.Visible = False
                            Else
                                dt.Clear()
                                lblNoSubscriptionResults.Visible = True
                            End If
                        Else
                            lblNoSubscriptionResults.Visible = False
                        End If

                        gvSubscriptions.DataSource = dt
                        gvSubscriptions.DataBind()
                    End Using
                End Using
            End Using
        Catch ex As Exception
            gvSubscriptions.EmptyDataText = "Error loading data: " & ex.Message
        End Try
    End Sub

    Protected Sub btnSearchSubscription_Click(sender As Object, e As EventArgs)
        Dim selectedStatus As String = ddlSubscriptionFilter.SelectedValue
        Dim searchTerm As String = txtSearchSubscription.Text
        LoadSubscriptionStatus(selectedStatus, searchTerm)
    End Sub

    Protected Sub ddlSubscriptionFilter_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim selectedStatus As String = ddlSubscriptionFilter.SelectedValue
        Dim searchTerm As String = txtSearchSubscription.Text
        ViewState("StatusFilter") = selectedStatus
        LoadSubscriptionStatus(selectedStatus, searchTerm)
    End Sub

    Protected Sub btnClearSubscriptionSearch_Click(sender As Object, e As EventArgs) Handles btnClearSubscriptionSearch.Click
        txtSearchSubscription.Text = ""
        lblNoSubscriptionResults.Visible = False
        LoadSubscriptionStatus()
    End Sub

    Protected Sub LoadSubscriptionChartData()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim activeCount As Integer = 0
        Dim expiredCount As Integer = 0
        Dim totalClients As Integer = 0

        Try
            Using conn As New SqlConnection(connStr)
                conn.Open()

                Dim activeQuery As String = "SELECT COUNT(*) FROM tblCompany_User WHERE DateExpiration IS NOT NULL AND DateExpiration >= CAST(GETDATE() AS DATE)"
                Dim expiredQuery As String = "SELECT COUNT(*) FROM tblCompany_User WHERE DateExpiration IS NOT NULL AND DateExpiration < CAST(GETDATE() AS DATE)"

                Using cmd1 As New SqlCommand(activeQuery, conn)
                    activeCount = Convert.ToInt32(cmd1.ExecuteScalar())
                End Using

                Using cmd2 As New SqlCommand(expiredQuery, conn)
                    expiredCount = Convert.ToInt32(cmd2.ExecuteScalar())
                End Using
            End Using

            totalClients = activeCount + expiredCount

            hiddenActive.Value = activeCount.ToString()
            hiddenExpired.Value = expiredCount.ToString()
            hiddenTotalClients.Value = totalClients.ToString()

        Catch ex As Exception
            ' Display error
        End Try
    End Sub

End Class