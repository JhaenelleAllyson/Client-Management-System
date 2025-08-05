<%@ Page Language="VB" AutoEventWireup="true" CodeFile="login.aspx.vb" Inherits="login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login Page</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
    <style>
        body, html {
            height: 100%;
            margin: 0;
            background-color: #f0f2f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .login-wrapper {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 100%;
            max-width: 400px;
        }

        .login-card {
            border: none;
            border-radius: 12px;
            background-color: #ffffff;
            box-shadow: 0 6px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .login-header {
            background-color: #215387;
            color: #ffffff;
            padding: 20px;
            font-size: 1.5rem;
            font-weight: 600;
            text-align: center;
        }

        .login-body {
            padding: 25px;
        }

        .btn-login {
            background-color: #215387;
            border: none;
        }

        .btn-login:hover {
            background-color: #1a426e;
        }

        .form-label {
            margin-bottom: 0.25rem;
            font-weight: 500;
        }

        .text-danger {
            font-size: 0.9rem;
        }

        .input-group-text {
            background-color: #fff;
            border-left: 0;
            cursor: pointer;
        }

        .form-control:focus {
            box-shadow: none;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-wrapper">
            <div class="login-card">
                <div class="login-header">Login</div>
                <div class="login-body">
                    <div class="form-group">
                        <label for="txtEmail" class="form-label">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter Email" />
                    </div>
                    <div class="form-group">
                        <label for="txtPassword" class="form-label">Password</label>
                        <div class="input-group">
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter Password" />
                            <div class="input-group-append">
                                <span class="input-group-text" onclick="togglePassword()">
                                    <i class="fas fa-eye" id="toggleIcon"></i>
                                </span>
                            </div>
                        </div>
                    </div>
                    <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-login btn-block text-white mt-3" OnClick="btnLogin_Click" />
                    <asp:Label ID="lblMessage" runat="server" CssClass="text-center d-block mt-3 text-danger"></asp:Label>
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        function togglePassword() {
            var pwd = document.getElementById('<%= txtPassword.ClientID %>');
            var icon = document.getElementById('toggleIcon');
            if (pwd.type === "password") {
                pwd.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                pwd.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }
    </script>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>