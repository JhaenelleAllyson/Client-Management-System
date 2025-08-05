<%@ Page Language="VB" MaintainScrollPositionOnPostback="true" AutoEventWireup="true" CodeFile="dashboard.aspx.vb" Inherits="dashboard" %>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script> 

    <style>
        body {
            overflow-x: hidden;
            background-color: #f4f6f9;
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            width: 240px;
            background-color: #fff;
            color: #215387;
            padding: 20px 0;
            box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
            align-items: center;
            border-right: 1px solid #e0e0e0;
        }

        .sidebar .logo {
            width: 170px;
            margin-bottom: 16px;
        }

        .sidebar-divider {
            width: 100%;
            border-top: 1px solid #e0e0e0;
            margin: 16px 0;
        }

        .sidebar-nav {
            width: 100%;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            align-items: stretch;
        }

        .sidebar-nav a,
        .sidebar-signout a {
            display: flex;
            align-items: center;
            padding: 12px 24px;
            color: #215387;
            font-size: 16px;
            font-weight: 500;
            text-decoration: none;
            transition: background 0.2s, color 0.2s;
        }

        .sidebar-nav a i,
        .sidebar-signout a i {
            width: 20px;
            font-size: 16px;
            margin-right: 12px;
            color: #215387;
        }

        .sidebar-nav a span {
            flex-grow: 1;
        }

        .sidebar-nav a:hover,
        .sidebar-nav a:focus,
        .sidebar-signout a:hover,
        .sidebar-signout a:focus {
            background-color: #f0f8ff;
            color: #215387;
        }

        .sidebar-signout {
            width: 100%;
            margin-top: auto;
            border-top: 1px solid #eaeaea;
            padding-top: 16px;
            margin-bottom: 20px;
        }

        .content {
            margin-left: 240px;
            padding: 30px 20px;
        }

        .bg-custom {
            background-color: #215387;
            color: white;
        }

        .custom-dropdown {
            min-width: 160px;
            border-radius: 6px;
            border: 1px solid #ced4da;
            padding: 4px 10px;
            font-size: 0.9rem;
        }

        .card-body-scroll {
            max-height: 350px;
            overflow-y: auto;
        }

        .alert-style {
            background-color: #fff3cd;
            border-left: 5px solid #ffc107;
            padding: 15px;
            border-radius: 6px;
            color: #856404;
            margin-bottom: 10px;
        }

        .alert-style.danger {
            background-color: #f8d7da;
            border-color: #dc3545;
            color: #721c24;
        }

        .btn-custom {
            background-color: #215387;
            color: white;
            border: none;
        }

        .btn-custom:hover {
            background-color: #1b4670;
        }

        .btn-search {
            background-color: #215387 !important;
            border-color: #215387 !important;
            color: white !important;
        }

        .btn-search:hover {
            background-color: #1a436a !important;
            border-color: #1a436a !important;
        }

        .h-100 {
            height: 100%;
        }

        .fixed-table {
            table-layout: fixed;
            width: 100%;
        }

        .fixed-table th,
        .fixed-table td {
            white-space: nowrap;
            padding: 8px;
        }

        .scroll-container {
            max-height: 491px;
            overflow-y: auto;
            border: 1px solid #ccc;
        }

        .scroll-container table {
            border-collapse: separate;
            border-spacing: 0;
        }

        .sticky-header th {
            position: sticky;
            top: 0;
            background-color: #f9f9f9;
            z-index: 10;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
            <!-- Sidebar -->
            <div class="sidebar">
                <!-- Logo -->
                <img src="images/integr8-logo.png" alt="Company Logo" class="logo" />

                <!-- Divider -->
                <div class="sidebar-divider"></div>

                <!-- Navigation -->
                <div class="sidebar-nav">
                    <a href="dashboard.aspx"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
                    <a href="clientinformation.aspx"><i class="fas fa-address-book"></i><span>Client Info</span></a>
                    <a href="clientuser.aspx"><i class="fas fa-users-cog"></i><span>Client Users</span></a>
                    <a href="audittrail.aspx"><i class="fas fa-history"></i><span>Audit Trail</span></a>
                </div>

                <!-- Sign Out -->
                <div class="sidebar-signout">
                    <a href="login.aspx"><i class="fas fa-sign-out-alt"></i><span>Sign Out</span></a>
                </div>
            </div>

            <!-- Content -->
            <div class="content">
                <div class="container-fluid">

                    <!-- Total Clients + Alerts -->
                    <div class="row mb-4">
                        <!-- Total Clients -->
                        <div class="col-md-4 mb-2">
                            <div class="card shadow-sm border-0 h-100" style="border-radius: 1rem;">
                                <div class="card-body text-center d-flex flex-column justify-content-center text-white" 
                                     style="min-height: 180px; background: linear-gradient(135deg, #215387, #1f3e5a); border-radius: 1rem;">
                                    <h5 class="mb-2 fw-semibold">Total Number of Clients</h5>
                                    <asp:Label ID="lblTotalClients" runat="server" Font-Size="36px" CssClass="fw-bold d-block" />
                                </div>
                            </div>
                        </div>

                        <!-- Alerts -->
                        <div class="col-md-8 mb-2">
                            <div class="card shadow-sm border-0 h-100" style="border-radius: 1rem; background-color: #f8f9fb; min-height: 180px;">
                                <div class="card-body d-flex flex-column justify-content-between h-100">
                                    <h5 class="mb-3 fw-semibold" style="color: #215387;">
                                        <span class="me-2">🔔</span> Subscription Alerts
                                    </h5>
                                    <div class="alert-style danger mb-2">
                                        <asp:Label ID="lblExpiredToday" runat="server" CssClass="d-block" />
                                    </div>
                                    <div class="alert-style">
                                        <asp:Label ID="lblNearing7Days" runat="server" CssClass="d-block" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Logins + Nearing Expiration -->
                    <div class="row mb-4">
                        <!-- Recent Logins -->
                        <div class="col-md-6 mb-4">
                            <div class="card shadow h-100">
                                <div class="card-header bg-custom d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Recent Logins</h5>
                                    <asp:Button ID="btnViewAll" runat="server" Text="View All" CssClass="btn btn-sm btn-custom" OnClick="btnViewAll_Click" />
                                </div>
                                <div class="card-body p-2">
                                    <asp:GridView ID="gvRecentLogins" runat="server"
                                        CssClass="table table-sm table-hover table-bordered sticky-table"
                                        AutoGenerateColumns="False"
                                        GridLines="None"
                                        ShowHeaderWhenEmpty="True"
                                        EmptyDataText="No recent logins found.">
                                        <HeaderStyle CssClass="sticky-header" />
                                        <Columns>
                                            <asp:BoundField DataField="ClientName" HeaderText="Client Name" />
                                            <asp:BoundField DataField="LoginDate" HeaderText="Login Date" DataFormatString="{0:MM/dd/yyyy}" />
                                            <asp:BoundField DataField="LoginTime" HeaderText="Login Time" />
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>

                        <!-- All Logins Modal -->
                        <div class="modal fade" id="modalAllLogins" tabindex="-1" role="dialog" aria-labelledby="modalAllLoginsLabel" aria-hidden="true">
                            <div class="modal-dialog modal-xl" role="document">
                                <div class="modal-content shadow">
                                    <div class="modal-header bg-custom text-white">
                                        <h5 class="modal-title" id="modalAllLoginsLabel">All Login Sessions</h5>
                                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>

                                    <div class="modal-body p-3">
                                        <asp:UpdatePanel ID="upAllLogins" runat="server">
                                            <ContentTemplate>
                                                <!-- Search Bar -->
                                                <asp:Panel ID="pnlLoginSearch" runat="server" DefaultButton="btnLoginSearch">
                                                    <div class="form-group mb-3">
                                                        <div class="d-flex">
                                                            <!-- Search TextBox with Clear 'X' inside -->
                                                            <div class="position-relative flex-grow-1">
                                                                <asp:TextBox ID="txtLoginSearch" runat="server"
                                                                    CssClass="form-control pr-4"
                                                                    placeholder="Search by name or company..." />

                                                                <!-- Clear 'X' inside textbox -->
                                                                <asp:LinkButton ID="btnClearLoginSearch" runat="server"
                                                                    OnClick="btnClearLoginSearch_Click"
                                                                    ToolTip="Clear Search"
                                                                    Style="position: absolute; top: 50%; right: 10px; transform: translateY(-50%); z-index: 2;">
                                                                    <i class="fas fa-times text-muted"></i>
                                                                </asp:LinkButton>
                                                            </div>

                                                            <!-- Search Button next to textbox -->
                                                            <asp:Button ID="btnLoginSearch" runat="server"
                                                                Text="Search"
                                                                CssClass="btn btn-search ml-2"
                                                                OnClick="btnLoginSearch_Click" />
                                                        </div>

                                                        <!-- No results label -->
                                                        <asp:Label ID="lblNoLoginResults" runat="server"
                                                            CssClass="text-danger font-italic mt-1 d-block"
                                                            Visible="false" />
                                                    </div>
                                                </asp:Panel>

                                                <!-- All Logins GridView -->
                                                <asp:GridView ID="gvAllLogins" runat="server"
                                                    CssClass="table table-sm table-hover table-bordered"
                                                    AutoGenerateColumns="False"
                                                    GridLines="None"
                                                    ShowHeaderWhenEmpty="True"
                                                    EmptyDataText="No login activity found.">
                                                    <HeaderStyle CssClass="sticky-header" />
                                                    <Columns>
                                                        <asp:BoundField DataField="Company_Name" HeaderText="Company Name" />
                                                        <asp:BoundField DataField="ClientName" HeaderText="Client Name" />
                                                        <asp:BoundField DataField="LoginDate" HeaderText="Login Date" DataFormatString="{0:MM/dd/yyyy}" />
                                                        <asp:BoundField DataField="LoginTime" HeaderText="Login Time" />
                                                        <asp:BoundField DataField="IPAddress" HeaderText="IP Address" />
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Nearing Expiration -->
                        <div class="col-md-6 mb-4">
                            <div class="card shadow h-100 d-flex flex-column">
                                <!-- Header with Filter Dropdown -->
                                <div class="card-header bg-custom d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Expiring Soon</h5>
                                    <asp:DropDownList ID="ddlExpirationFilter" runat="server"
                                        AutoPostBack="true"
                                        CssClass="form-select form-select-sm custom-dropdown"
                                        OnSelectedIndexChanged="ddlExpirationFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="Today" Value="Today" />
                                        <asp:ListItem Text="1 Week" Value="7" />
                                        <asp:ListItem Text="1 Month" Value="30" />
                                        <asp:ListItem Text="3 Months" Value="90" />
                                        <asp:ListItem Text="6 Months" Value="180" />
                                        <asp:ListItem Text="1 Year" Value="360" />
                                        <asp:ListItem Text="All" Value="0" />
                                    </asp:DropDownList>
                                </div>

                                <!-- Body with Search + GridView -->
                                <asp:Panel ID="pnlExpiringSearch" runat="server" DefaultButton="btnSearchExpiring">
                                    <div class="card-body p-3 d-flex flex-column">
                                        <!-- Search Bar -->
                                        <div class="form-group mb-3">
                                            <div class="d-flex">
                                                <!-- Search TextBox with Clear 'X' -->
                                                <div class="position-relative flex-grow-1">
                                                    <asp:TextBox ID="txtSearchExpiring" runat="server"
                                                        CssClass="form-control pr-4"
                                                        placeholder="Search by client name..." />

                                                    <!-- Clear Button 'X' -->
                                                    <asp:LinkButton ID="btnClearExpiringSearch" runat="server"
                                                        OnClick="btnClearExpiringSearch_Click"
                                                        ToolTip="Clear Search"
                                                        Style="position: absolute; top: 50%; right: 10px; transform: translateY(-50%); z-index: 2;">
                                                        <i class="fas fa-times text-muted"></i>
                                                    </asp:LinkButton>
                                                </div>

                                                <!-- Search Button -->
                                                <asp:Button ID="btnSearchExpiring" runat="server"
                                                    Text="Search"
                                                    CssClass="btn btn-search ml-2"
                                                    OnClick="btnSearchExpiring_Click" />
                                            </div>

                                            <!-- No results label -->
                                            <asp:Label ID="lblNoExpiringResults" runat="server"
                                                CssClass="text-dark font-italic mt-1 d-block"
                                                Visible="false"
                                                Text="No results found." />
                                        </div>

                                        <!-- GridView -->
                                        <div style="max-height: 335px; overflow-y: auto;" class="flex-grow-1">
                                            <asp:GridView ID="gvNearingExpiration" runat="server"
                                                CssClass="table table-sm table-hover table-bordered mb-0"
                                                AutoGenerateColumns="False"
                                                GridLines="None"
                                                ShowHeaderWhenEmpty="True"
                                                EmptyDataText="No expiring users found.">
                                                <HeaderStyle CssClass="sticky-header" />
                                                <Columns>
                                                    <asp:BoundField DataField="ClientName" HeaderText="Client Name" />
                                                    <asp:BoundField DataField="DateExpiration" HeaderText="Expiration Date" DataFormatString="{0:MM/dd/yyyy}" />
                                                    <asp:BoundField DataField="DaysRemaining" HeaderText="Days Remaining" />
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                </asp:Panel>
                            </div>
                        </div>

                    <!-- Weekly User Login Summary -->
                    <div class="col-md-6 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header bg-custom text-white">
                                <h5 class="mb-0">Weekly User Login Summary</h5>
                            </div>
                            <div class="card-body" style="height: 300px;">
                                <canvas id="loginChart" style="width: 100%; height: 100%;"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Upcoming Client Expirations -->
                    <div class="col-md-6 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header bg-custom text-white">
                                <h5 class="mb-0">Upcoming Client Expirations</h5>
                            </div>
                            <div class="card-body" style="height: 300px;">
                                <canvas id="expiringChart" style="width: 100%; height: 100%;"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Login Chart Script -->
                <script type="text/javascript">
                    function renderLoginChart(dates, counts) {
                        var ctx = document.getElementById('loginChart').getContext('2d');
                        new Chart(ctx, {
                            type: 'line',
                            data: {
                                labels: dates,
                                datasets: [{
                                    label: 'Logins per Day',
                                    data: counts,
                                    backgroundColor: '#215387',
                                    borderColor: '#215387',
                                    fill: false,
                                    tension: 0.1
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: { display: false },
                                    tooltip: { mode: 'index', intersect: false }
                                },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: { stepSize: 1 }
                                    }
                                }
                            }
                        });
                    }
                </script>

                <!-- Expiring Clients Chart Script -->
                <script type="text/javascript">
                    function renderExpiringChart(labels, data) {
                        const ctx = document.getElementById('expiringChart').getContext('2d');
                        new Chart(ctx, {
                            type: 'bar',
                            data: {
                                labels: labels,
                                datasets: [{
                                    label: 'Expiring Clients',
                                    data: data,
                                    backgroundColor: '#215387'
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: { stepSize: 1 }
                                    }
                                },
                                plugins: {
                                    legend: {
                                        display: false
                                    }
                                }
                            }
                        });
                    }
                </script>
                            
                    <!-- Subscription Status Table and Pie Chart -->
                    <div class="row mb-4">
                        <div class="col-md-12">
                            <div class="card shadow">
                                <!-- Header with Filter -->
                                <div class="card-header bg-custom d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Subscription Status</h5>
                                    <asp:DropDownList ID="ddlSubscriptionFilter" runat="server"
                                        AutoPostBack="true"
                                        CssClass="form-select form-select-sm custom-dropdown"
                                        OnSelectedIndexChanged="ddlSubscriptionFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="All" Value="All" />
                                        <asp:ListItem Text="Active" Value="Active" />
                                        <asp:ListItem Text="Expired" Value="Expired" />
                                    </asp:DropDownList>
                                </div>

                                <!-- Body: Search + Table + Pie Chart -->
                                <div class="card-body">
                                    <div class="row">
                                        <!-- Left: Search + Scrollable Table -->
                                        <div class="col-md-7">
                                            <asp:Panel ID="pnlSubscriptionSearch" runat="server" DefaultButton="btnSearchSubscription">
                                                <!-- Search Controls -->
                                                <div class="form-group mb-3">
                                                    <div class="d-flex">
                                                        <!-- Textbox with clear 'X' -->
                                                        <div class="position-relative flex-grow-1">
                                                            <asp:TextBox ID="txtSearchSubscription" runat="server"
                                                                CssClass="form-control pr-4"
                                                                placeholder="Search by client name..." />

                                                            <!-- Clear Button inside textbox -->
                                                            <asp:LinkButton ID="btnClearSubscriptionSearch" runat="server"
                                                                OnClick="btnClearSubscriptionSearch_Click"
                                                                ToolTip="Clear Search"
                                                                Style="position: absolute; top: 50%; right: 10px; transform: translateY(-50%); z-index: 2;">
                                                                <i class="fas fa-times text-muted"></i>
                                                            </asp:LinkButton>
                                                        </div>

                                                        <!-- Search Button -->
                                                        <asp:Button ID="btnSearchSubscription" runat="server"
                                                            Text="Search"
                                                            CssClass="btn btn-search ml-2"
                                                            OnClick="btnSearchSubscription_Click" />
                                                    </div>

                                                    <!-- No results label -->
                                                    <asp:Label ID="lblNoSubscriptionResults" runat="server"
                                                        CssClass="text-danger font-italic mt-1 d-block"
                                                        Visible="false"
                                                        Text="No matching results found." />
                                                </div>
                                            </asp:Panel>

                                            <!-- Scrollable GridView -->
                                            <div class="scroll-container">
                                                <asp:GridView ID="gvSubscriptions" runat="server"
                                                    CssClass="table table-sm table-hover table-bordered fixed-table"
                                                    AutoGenerateColumns="False"
                                                    GridLines="None"
                                                    ShowHeaderWhenEmpty="True"
                                                    EmptyDataText="No subscriptions found."
                                                    UseAccessibleHeader="true">
                                                    <HeaderStyle CssClass="sticky-header" />
                                                    <Columns>
                                                        <asp:BoundField DataField="ClientName" HeaderText="Client Name">
                                                            <ItemStyle Width="40%" />
                                                            <HeaderStyle Width="40%" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="DateExpiration" HeaderText="Expiration Date" DataFormatString="{0:MM/dd/yyyy}">
                                                            <ItemStyle Width="30%" />
                                                            <HeaderStyle Width="30%" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Status" HeaderText="Status">
                                                            <ItemStyle Width="30%" />
                                                            <HeaderStyle Width="30%" />
                                                        </asp:BoundField>
                                                    </Columns>
                                                </asp:GridView>
                                            </div>
                                        </div>

                                        <!-- Right: Pie Chart -->
                                        <div class="col-md-5">
                                            <div class="position-relative h-100">
                                                <div class="position-absolute top-0 start-0 m-2">
                                                    <span class="fs-6 fw-semibold text-dark">
                                                        Total: <span id="totalClientsLabel">0</span>
                                                    </span>
                                                </div>
                                                <canvas id="subscriptionChart" width="400" height="200" style="margin-top: 2rem;"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Hidden Fields for Chart Data -->
                    <asp:HiddenField ID="hiddenActive" runat="server" />
                    <asp:HiddenField ID="hiddenExpired" runat="server" />
                    <asp:HiddenField ID="hiddenTotalClients" runat="server" />

                    <!-- Chart Script -->
                    <script>
                        document.addEventListener("DOMContentLoaded", function () {
                            var activeCount = parseInt(document.getElementById('<%= hiddenActive.ClientID %>').value) || 0;
                            var expiredCount = parseInt(document.getElementById('<%= hiddenExpired.ClientID %>').value) || 0;
                            var totalClients = parseInt(document.getElementById('<%= hiddenTotalClients.ClientID %>').value) || 0;

                            document.getElementById("totalClientsLabel").innerText = totalClients;

                            var ctx = document.getElementById('subscriptionChart').getContext('2d');
                            new Chart(ctx, {
                                type: 'pie',
                                data: {
                                    labels: ['Active', 'Expired'],
                                    datasets: [{
                                        data: [activeCount, expiredCount],
                                        backgroundColor: ['#9abddc', '#0077b6']
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    plugins: {
                                        legend: { position: 'bottom' },
                                        title: { display: false }
                                    }
                                }
                            });
                        });
                    </script>   
                </div>  
            </div> 
        </div> 
    </form>
</body>
</html>