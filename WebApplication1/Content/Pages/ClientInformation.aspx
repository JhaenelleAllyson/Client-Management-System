<%@ Page Language="vb" AutoEventWireup="true" CodeFile="ClientInformation.aspx.vb" Inherits="ClientInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Client Information</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f4f6f9;
        }

        .modern-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            background-color: white;
        }

        .yellow-header {
            background-color: #215387;
            padding: 12px 24px;
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .yellow-header h5 {
            margin: 0;
            font-weight: bold;
            color: #fff;
        }

        .modern-btn {
            background-color: #215387;
            color: white;
            border-radius: 20px;
            padding: 6px 16px;
            font-size: 0.9rem;
            text-decoration: none !important;
            border: none;
        }

        .modern-btn:hover {
            background-color: #1a4169;
        }

        .summary-card {
            border-radius: 12px;
            padding: 12px;
            color: white;
            margin-bottom: 20px;
        }

        .bg-total { background-color: #215387; }
        .bg-active { background-color: #D96F32; }
        .bg-expired { background-color: #000000; }
        .bg-near { background-color: #5E936C; color: white; }

        .table thead {
            background-color: #ffc107;
            color: #000;
        }

        .table-striped > tbody > tr:nth-of-type(odd) {
            background-color: #215387;
            color: white;
        }

        .custom-pager a, .custom-pager span {
            margin: 0 6px;
            padding: 4px 10px;
            border-radius: 6px;
            background-color: #fff;
            color: #215387;
            border: 1px solid #ddd;
            text-decoration: none;
        }

        .custom-pager span {
            background-color: #215387;
            color: white;
            font-weight: bold;
        }

        .modal-content {
            border-radius: 12px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container py-5">

            <!-- Summary Stats -->
            <div class="row text-center mb-4">
                <div class="col-md-3">
                    <div class="summary-card bg-total">
                        <h5>Total Clients</h5>
                        <asp:Label ID="lblTotal" runat="server" Font-Size="Medium"></asp:Label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="summary-card bg-active">
                        <h5>Active</h5>
                        <asp:Label ID="lblActive" runat="server" Font-Size="Medium"></asp:Label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="summary-card bg-expired">
                        <h5>Expired</h5>
                        <asp:Label ID="lblExpired" runat="server" Font-Size="Medium"></asp:Label>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="summary-card bg-near">
                        <h5>Near Expiration</h5>
                        <asp:Label ID="lblNear" runat="server" Font-Size="Medium"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- Alerts -->
            <asp:Panel ID="pnlAlerts" runat="server" CssClass="alert" Visible="false" />


            <!-- Main Card -->
            <div class="card modern-card">
                <div class="yellow-header">
                    <h5>Client Information</h5>
                </div>

                <div class="p-4 pt-3">
                    <div class="row mb-3 gx-3 align-items-end justify-content-center">
                        <div class="col-md-6">
                            <label class="form-label">Search Company</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" Placeholder="Enter company name..."></asp:TextBox>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Rows to Display</label>
                            <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                <asp:ListItem Text="10" Value="10" Selected="True" />
                                <asp:ListItem Text="25" Value="25" />
                                <asp:ListItem Text="50" Value="50" />
                                <asp:ListItem Text="100" Value="100" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Subscription Status</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                                <asp:ListItem Text="All" Value="" />
                                <asp:ListItem Text="Active" Value="Active" />
                                <asp:ListItem Text="Expired" Value="Expired" />
                                <asp:ListItem Text="Near Expiration" Value="NearExpiration" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <asp:GridView ID="gvCompanies" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-bordered table-hover table-striped text-center"
                            DataKeyNames="Company_Code"
                            AllowPaging="True" PageSize="10"
                            PagerStyle-CssClass="custom-pager"
                            PagerStyle-HorizontalAlign="Center"
                            OnPageIndexChanging="gvCompanies_PageIndexChanging"
                            OnSelectedIndexChanged="gvCompanies_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="Company_Name" HeaderText="Company Name" />
                                <asp:BoundField DataField="Status" HeaderText="Status" />
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnView" runat="server" CommandName="Select" CssClass="modern-btn btn-sm">View</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal -->
        <div class="modal fade" id="detailsModal" tabindex="-1" aria-labelledby="detailsLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header text-white" style="background-color: #215387;">
                        <h5 class="modal-title" id="detailsLabel">Company Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <asp:Literal ID="litDetails" runat="server"></asp:Literal>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript">
            function showModal() {
                var modal = new bootstrap.Modal(document.getElementById('detailsModal'));
                modal.show();
            }
        </script>
    </form>
</body>
</html>
