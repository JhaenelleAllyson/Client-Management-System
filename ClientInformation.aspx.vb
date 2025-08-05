Imports System.Data
Imports System.Data.SqlClient

Partial Class ClientInformation
    Inherits System.Web.UI.Page

    Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            LoadCompanies()
            LoadSummaryStats()
            LoadAlerts()
        End If
    End Sub

    Private Sub LoadCompanies()
        Using conn As New SqlConnection(connStr)
            Dim query As String = "SELECT Company_Code, Company_Name, Status, DateTo FROM tblCompany_Information"
            Dim cmd As New SqlCommand(query, conn)
            Dim da As New SqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            Dim searchTerm As String = txtSearch.Text.Trim().ToLower()
            Dim statusFilter As String = ddlStatusFilter.SelectedValue

            If Not String.IsNullOrEmpty(searchTerm) Then
                Dim matchedRows = dt.Select("Company_Name LIKE '%" & searchTerm.Replace("'", "''") & "%'")
                If matchedRows.Any() Then
                    dt = matchedRows.CopyToDataTable()
                Else
                    dt.Clear()
                End If
            End If


            If Not String.IsNullOrEmpty(statusFilter) Then
                Dim filteredRows = dt.AsEnumerable().Where(Function(row)
                                                               Dim dateTo = If(IsDBNull(row("DateTo")), Date.MinValue, Convert.ToDateTime(row("DateTo")))
                                                               Select Case statusFilter
                                                                   Case "Active"
                                                                       Return dateTo >= Date.Now
                                                                   Case "Expired"
                                                                       Return dateTo < Date.Now
                                                                   Case "NearExpiration"
                                                                       Return dateTo >= Date.Now.AddDays(7) AndAlso dateTo <= Date.Now.AddMonths(1)
                                                                   Case Else
                                                                       Return True
                                                               End Select
                                                           End Function)
                If filteredRows.Any() Then
                    dt = filteredRows.CopyToDataTable()
                Else
                    dt.Clear()
                End If
            End If

            gvCompanies.DataSource = dt
            gvCompanies.DataBind()
        End Using
    End Sub

    Protected Sub gvCompanies_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim selectedCode As String = gvCompanies.SelectedDataKey.Value.ToString()

        Using conn As New SqlConnection(connStr)
            Dim query As String = "SELECT * FROM tblCompany_Information WHERE Company_Code = @Company_Code"
            Dim cmd As New SqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@Company_Code", selectedCode)
            Dim dt As New DataTable()
            Using da As New SqlDataAdapter(cmd)
                da.Fill(dt)
            End Using

            If dt.Rows.Count > 0 Then
                Dim r = dt.Rows(0)
                Dim subscriptionStatus As String = "Expired"
                If Not Convert.IsDBNull(r("DateTo")) AndAlso Convert.ToDateTime(r("DateTo")) >= DateTime.Now Then
                    subscriptionStatus = "Active"
                End If

                Dim info As String =
                    $"<dl class='row'>" &
                    $"<dt class='col-sm-4'>Status</dt><dd class='col-sm-8'>{r("Status")}</dd>" &
                    $"<dt class='col-sm-4'>Subscription</dt><dd class='col-sm-8'>{subscriptionStatus}</dd>" &
                    $"<dt class='col-sm-4'>Company Database</dt><dd class='col-sm-8'>{r("Company_Database")}</dd>" &
                    $"<dt class='col-sm-4'>Company Code</dt><dd class='col-sm-8'>{r("Company_Code")}</dd>" &
                    $"<dt class='col-sm-4'>Subscription End</dt><dd class='col-sm-8'>{Convert.ToDateTime(r("DateTo")).ToString("yyyy-MM-dd")}</dd>" &
                    $"</dl>"

                litDetails.Text = info

                LoadAlerts()

                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "showModal", "showModal();", True)
            End If
        End Using
    End Sub

    Protected Sub txtSearch_TextChanged(sender As Object, e As EventArgs)
        LoadCompanies()
        LoadAlerts()
    End Sub

    Protected Sub ddlPageSize_SelectedIndexChanged(sender As Object, e As EventArgs)
        gvCompanies.PageSize = Integer.Parse(ddlPageSize.SelectedValue)
        LoadCompanies()
        LoadAlerts()
    End Sub

    Protected Sub gvCompanies_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvCompanies.PageIndex = e.NewPageIndex
        LoadCompanies()
        LoadAlerts()
    End Sub

    Protected Sub ddlStatusFilter_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadCompanies()
        LoadAlerts()
    End Sub
    Protected Sub btnClear_Click(sender As Object, e As EventArgs)
        txtSearch.Text = ""
        ddlStatusFilter.SelectedIndex = 0
        ddlPageSize.SelectedValue = "10"
        LoadCompanies()
        LoadAlerts()

    End Sub
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        LoadCompanies()
        LoadAlerts()
    End Sub




    Private Sub LoadSummaryStats()
        Using conn As New SqlConnection(connStr)
            Dim cmd As New SqlCommand("
                SELECT 
                    COUNT(*) AS TotalClients,
                    COUNT(CASE WHEN DateTo >= GETDATE() THEN 1 END) AS ActiveClients,
                    COUNT(CASE WHEN DateTo < GETDATE() THEN 1 END) AS ExpiredClients,
                    COUNT(CASE 
                        WHEN DateTo BETWEEN DATEADD(DAY, 7, GETDATE()) AND DATEADD(MONTH, 1, GETDATE()) 
                        THEN 1 END) AS NearExpiration
                FROM tblCompany_Information
            ", conn)
            conn.Open()
            Dim reader = cmd.ExecuteReader()
            If reader.Read() Then
                lblTotal.Text = reader("TotalClients").ToString()
                lblActive.Text = reader("ActiveClients").ToString()
                lblExpired.Text = reader("ExpiredClients").ToString()
                lblNear.Text = reader("NearExpiration").ToString()
            End If
        End Using
    End Sub

    Private Sub LoadAlerts()
        Using conn As New SqlConnection(connStr)
            Dim cmd As New SqlCommand("
            SELECT COUNT(*) AS ExpiredToday
            FROM tblCompany_Information
            WHERE CAST(DateTo AS DATE) = CAST(GETDATE() AS DATE)
        ", conn)

            conn.Open()
            Dim expiredToday = Convert.ToInt32(cmd.ExecuteScalar())

            pnlAlerts.Controls.Clear()
            pnlAlerts.Visible = True

            If expiredToday > 0 Then
                pnlAlerts.CssClass = "alert alert-warning"
                pnlAlerts.Controls.Add(New Literal With {
                .Text = $"⚠ <strong>{expiredToday}</strong> subscription(s) expired today."
            })
            Else
                pnlAlerts.CssClass = "alert alert-success"
                pnlAlerts.Controls.Add(New Literal With {
                .Text = "✔ No subscriptions expired today."
            })
            End If
        End Using
    End Sub

End Class
