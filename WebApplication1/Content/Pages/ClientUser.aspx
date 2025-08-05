<%@ Page Language="VB" AutoEventWireup="false" CodeFile="ClientUser.aspx.vb" Inherits="ClientUser" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Client Users</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style type="text/css">
        body {
            background-color: #f8f9fa;
        }

        .container-centered {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .card-custom {
            width: 100%;
            max-width: 1000px;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            background-color: #fff;
        }

        .gridview-style {
            width: 100%;
            margin-top: 20px;
        }

        .gridview-style th,
        .gridview-style td {
            padding: 10px;
            text-align: left;
        }

        .gridview-style th {
            background-color: #215387;
            color: white;
        }

        .gridview-style tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        .gridview-style tr:hover {
            background-color: #e9ecef;
        }

        .search-bar {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .search-box {
            width: 250px;
        }

        .btn-search {
            background-color: #215387;
            color: white;
            border-radius: 25px;
            padding: 5px 15px;
            border: none;
            font-size: 14px;
        }

        .btn-search:hover {
            background-color: #183c64;
        }

        .btn-view {
            background-color: #198754;
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            border: none;
            font-size: 13px;
        }

        .btn-view:hover {
            background-color: #146c43;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-centered">
            <div class="card card-custom">
                <h3 class="text-center mb-4">Client Users</h3>

                <div class="mb-3 text-center">
                    <asp:DropDownList ID="ddlCompanyFilter" runat="server" AutoPostBack="true"
                        OnSelectedIndexChanged="ddlCompanyFilter_SelectedIndexChanged"
                        CssClass="form-select w-50 d-inline-block">
                    </asp:DropDownList>
                </div>

                <div class="search-bar">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-box" placeholder="Search company..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-search" OnClick="btnSearch_Click" />
                </div>

                <asp:GridView ID="gvUsers" runat="server" CssClass="table table-bordered gridview-style"
                    AutoGenerateColumns="False" GridLines="None" EmptyDataText="No users found.">
                    <Columns>
                        <asp:BoundField DataField="FullName" HeaderText="Full Name" />
                        <asp:BoundField DataField="EmailAddress" HeaderText="Email Address" />
                        <%-- View Details Button Column --%>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:Button ID="btnViewDetails" runat="server" Text="View Details" CommandName="ViewDetails" CssClass="btn btn-primary btn-sm" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
