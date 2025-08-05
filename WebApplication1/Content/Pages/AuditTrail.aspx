<%@ Page Language="vb" AutoEventWireup="true" CodeFile="AuditTrail.aspx.vb" Inherits="AuditTrail" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Audit Trail</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            background-color: #f4f6f9;
        }
        .audit-card {
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            background-color: white;
        }
        .audit-header {
            background-color: #215387;
            color: white;
            padding: 16px 24px;
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
        }
        .audit-header h4 {
            margin: 0;
            font-weight: bold;
        }
        .table thead {
            background-color: #ffc107;
            color: #000;
        }
        .table-hover tbody tr:hover {
            background-color: #f1f3f5;
        }
        .table-striped > tbody > tr:nth-of-type(odd) {
            background-color: #e9ecef;
        }
        .table td, .table th {
            vertical-align: middle;
            text-align: center;
        }
        .pagination {
            justify-content: center !important;
            display: flex;
            gap: 0.5rem;
            margin-top: 16px;
        }
        .pagination a, .pagination span {
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            border: 1px solid transparent;
            color: #215387;
        }
        .pagination a:hover {
            background-color: #e9ecef;
            border-color: #ced4da;
        }
        .pagination .aspNetDisabled {
            pointer-events: none;
            opacity: 0.5;
        }
        .pagination span {
            background-color: #215387;
            color: white;
            border-color: #215387;
        }
        .table-responsive {
            overflow-x: auto;
        }
        .center-content {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }
        #activityChart {
            max-width: 800px;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container py-5">
            <div class="card audit-card">
                <div class="audit-header">
                    <h4>Audit Trail</h4>
                </div>
                <div class="p-4">
                    <div class="row mb-3 justify-content-between">
                        <div class="col-md-4">
                            <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                                <asp:ListItem Text="Most Recent" Value="DESC" Selected="True" />
                                <asp:ListItem Text="Oldest First" Value="ASC" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search full name..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
                        </div>
                    </div>

                    <div class="row mb-3 justify-content-center text-center">
                        <div class="col-md-3">
                            <label for="txtDateFrom" class="form-label">Date From</label>
                            <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-3">
                            <label for="txtDateTo" class="form-label">Date To</label>
                            <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-3 d-flex align-items-end justify-content-start gap-2">
                            <asp:Button ID="btnFilter" runat="server" CssClass="btn btn-primary" Text="Filter" OnClick="btnFilter_Click" />
                            <asp:Button ID="btnClearFilter" runat="server" CssClass="btn btn-outline-secondary" Text="Clear Filter" OnClick="btnClearFilter_Click" />
                        </div>
                    </div>

                    <div class="row mb-3 justify-content-center text-danger fw-bold">
                        <div class="col-md-6 text-center">
                            <asp:Label ID="lblError" runat="server" ForeColor="Red" EnableViewState="false" />
                        </div>
                    </div>

                    <div class="table-responsive">
                        <asp:GridView ID="gvAuditTrail" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-bordered table-hover table-striped text-center"
                            AllowPaging="True" PageSize="10"
                            PagerSettings-Mode="Numeric"
                            PagerStyle-HorizontalAlign="Center"
                            PagerStyle-CssClass="pagination"
                            OnPageIndexChanging="gvAuditTrail_PageIndexChanging">
                            <Columns>
                                <asp:BoundField DataField="FullName" HeaderText="Full Name" />
                                <asp:BoundField DataField="DateModified" HeaderText="Date Modified" DataFormatString="{0:MM/dd/yyyy HH:mm}" />
                                <asp:BoundField DataField="IPAddress" HeaderText="IP Address" />
                                <asp:TemplateField HeaderText="Details">
                                    <ItemTemplate>
                                        <span class="text-muted fst-italic">No details available</span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="center-content">
                        <canvas id="activityChart"></canvas>
                        <asp:Literal ID="litChartData" runat="server" Visible="false" />
                    </div>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            window.onload = function () {
                var chartData = <%= litChartData.Text %>;
                if (chartData && chartData.labels && chartData.values) {
                    const ctx = document.getElementById('activityChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: chartData.labels,
                            datasets: [{
                                label: 'Modifications',
                                data: chartData.values,
                                borderColor: '#215387',
                                backgroundColor: 'rgba(33, 83, 135, 0.2)',
                                tension: 0.4,
                                fill: true,
                                pointRadius: 4,
                                pointHoverRadius: 6
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: { display: true, position: 'top' },
                                tooltip: { mode: 'index', intersect: false }
                            },
                            interaction: { mode: 'nearest', axis: 'x', intersect: false },
                            scales: {
                                x: { title: { display: true, text: 'Month' } },
                                y: { beginAtZero: true, title: { display: true, text: 'Number of Modifications' } }
                            }
                        }
                    });
                }
            };
        </script>
    </form>
</body>
</html>