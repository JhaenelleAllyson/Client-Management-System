Imports System.Data
Imports System.Data.SqlClient

Partial Class ClientUser
    Inherits System.Web.UI.Page

    Private ReadOnly connStr As String = "Server=LAPTOP-0UAHSB98;Database=Main;User Id=sa;Password=admin123;"

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            LoadCompanyFilter()
            LoadUsers()
        End If
    End Sub

    ' Populate dropdown with list of companies
    Private Sub LoadCompanyFilter()
        Using con As New SqlConnection(connStr)
            Dim query As String = "SELECT Company_Code, Company_Name FROM tblCompany_Information ORDER BY Company_Name"
            Dim cmd As New SqlCommand(query, con)
            Dim adapter As New SqlDataAdapter(cmd)
            Dim dt As New DataTable()
            adapter.Fill(dt)

            ddlCompanyFilter.DataSource = dt
            ddlCompanyFilter.DataTextField = "Company_Name"
            ddlCompanyFilter.DataValueField = "Company_Code"
            ddlCompanyFilter.DataBind()

            ddlCompanyFilter.Items.Insert(0, New ListItem("All Companies", "ALL"))
        End Using
    End Sub

    ' Load users into GridView based on selected company filter
    Private Sub LoadUsers(Optional searchText As String = "")
        Using con As New SqlConnection(connStr)
            Dim query As String = "SELECT u.RecordID, u.LastName + ',' + u.FirstName AS FullName, u.EmailAddress, c.Company_Name " &
                                  "FROM tblCompany_User u " &
                                  "JOIN tblCompany_Information c ON u.Company_Code = c.Company_Code WHERE 1 = 1"

            If ddlCompanyFilter.SelectedValue <> "ALL" Then
                query &= " AND u.Company_Code = @CompanyCode"
            End If

            If Not String.IsNullOrWhiteSpace(searchText) Then
                query &= " AND c.Company_Name LIKE @Search"
            End If

            Dim cmd As New SqlCommand(query, con)

            If ddlCompanyFilter.SelectedValue <> "ALL" Then
                cmd.Parameters.AddWithValue("@CompanyCode", ddlCompanyFilter.SelectedValue)
            End If

            If Not String.IsNullOrWhiteSpace(searchText) Then
                cmd.Parameters.AddWithValue("@Search", "%" & searchText & "%")
            End If

            Dim adapter As New SqlDataAdapter(cmd)
            Dim dt As New DataTable()
            adapter.Fill(dt)

            gvUsers.DataSource = dt
            gvUsers.DataBind()
        End Using
    End Sub

    ' Event: Dropdown filter changed
    Protected Sub ddlCompanyFilter_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadUsers(txtSearch.Text)
    End Sub

    ' Event: Search button clicked
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        LoadUsers(txtSearch.Text)
    End Sub

    ' Handle View Details button click
    Protected Sub gvUsers_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName = "ViewDetails" Then
            Dim rowIndex As Integer = Convert.ToInt32(e.CommandArgument)
            Dim userID As String = gvUsers.DataKeys(rowIndex).Value.ToString()
            Response.Redirect("UserDetails.aspx?UserID=" & userID)
        End If
    End Sub
End Class
