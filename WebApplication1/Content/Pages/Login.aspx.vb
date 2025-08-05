Imports System.Data.SqlClient
Public Class login
    Inherits System.Web.UI.Page

    Protected Sub btnLogin_Click(sender As Object, e As EventArgs)
        Dim email As String = txtEmail.Text.Trim()
        Dim password As String = txtPassword.Text.Trim()

        Dim connStr As String = ConfigurationManager.ConnectionStrings("MainDB").ConnectionString
        Dim query As String = "SELECT COUNT(*) FROM tblCompany_User WHERE EmailAddress = @EmailAddress AND password = @Password"

        Using conn As New SqlConnection(connStr)
            Using cmd As New SqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@EmailAddress", email)
                cmd.Parameters.AddWithValue("@Password", password)

                Try
                    conn.Open()
                    Dim count As Integer = Convert.ToInt32(cmd.ExecuteScalar())

                    If count = 1 Then
                        Response.Redirect("dashboard.aspx")
                    Else
                        lblMessage.ForeColor = Drawing.Color.Red
                        lblMessage.Text = "Invalid email or password."
                    End If

                Catch ex As Exception
                    lblMessage.ForeColor = Drawing.Color.Red
                    lblMessage.Text = "Database error: " & ex.Message
                End Try
            End Using
        End Using
    End Sub
End Class