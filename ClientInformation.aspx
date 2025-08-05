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
            border-top-left-radius: 16px;
            border-top-right-radius: 16px;
            border-bottom-left-radius: 0;
            border-bottom-right-radius: 0;
        }


        .yellow-header {
        background: linear-gradient(90deg, #215387, #2980b9);
        color: #fff;
        padding: 1.0rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top-left-radius: 16px;
        border-top-right-radius: 16px;
        border-bottom-left-radius: 0;
        border-bottom-right-radius: 0;
        }

        .yellow-header h5 {
            margin: 0;
            font-weight: bold;
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
        .info-card {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 16px 24px;
            border-radius: 16px;
            min-width: 240px;
            flex: 1 1 240px;
            color: white;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s ease;
        }

        .info-card:hover {
            transform: translateY(-4px);
        }

        .icon-circle {
            width: 48px;
            height: 48px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .info-count {
            font-size: 1.25rem;
            font-weight: bold;
        }

        .bg-total { background: linear-gradient(135deg, #215387, #3b6ba3); }
        .bg-active { background: linear-gradient(135deg, #215387, #3b6ba3); }
        .bg-expired { background: linear-gradient(135deg, #215387, #3b6ba3); }
        .bg-near { background: linear-gradient(135deg, #215387, #3b6ba3); }
        .tile-card {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 20px 30px;
            border-radius: 12px;
            background: linear-gradient(to right, #0f2027, #203a43, #2c5364);
            color: white;
            width: 100%;
        }
        .modern-btn {
            background-color: #215387;
            color: white;
            border-radius: 20px;
            padding: 6px 16px;
            font-size: 0.9rem;
            text-decoration: none !important;
            border: none;
            transition: all 0.3s ease;
        }

        .modern-btn:hover {
            background-color: #1a4169;
            transform: scale(1.05);
        }
        .clientPieChart {
            opacity: 0;
            transform: scale(0.9);
            transition: opacity 0.5s ease, transform 0.5s ease-out;
        }
        .clientPieChart.visible {
            opacity: 1;
            transform: scale(1);
        }



    </style>
</head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
<body>
    <form id="form1" runat="server">
        <div class="container py-5">

            <!-- Summary Stats -->
            <div class="d-flex flex-wrap gap-3 justify-content-center mb-4">
                <div class="info-card bg-total">
                    <div class="icon-circle">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div>
                        <h6>Total Clients</h6>
                        <asp:Label ID="lblTotal" runat="server" CssClass="info-count"></asp:Label>
                    </div>
                </div>
                <div class="info-card bg-active">
                    <div class="icon-circle">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <div>
                        <h6>Active</h6>
                        <asp:Label ID="lblActive" runat="server" CssClass="info-count"></asp:Label>
                    </div>
                </div>
                <div class="info-card bg-expired">
                    <div class="icon-circle">
                        <i class="bi bi-x-circle-fill"></i>
                    </div>
                    <div>
                        <h6>Expired</h6>
                        <asp:Label ID="lblExpired" runat="server" CssClass="info-count"></asp:Label>
                    </div>
                </div>
                <div class="info-card bg-near">
                    <div class="icon-circle">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>
                    <div>
                        <h6>Near Expiration</h6>
                        <asp:Label ID="lblNear" runat="server" CssClass="info-count"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- Alerts -->
            <asp:Panel ID="pnlAlerts" runat="server" CssClass="alert" Visible="false" />


            <!-- Main Card -->
            <div class="card modern-card">
                <div class="yellow-header">
                    <h3 class="fw-bold">
                      <i class="bi bi-people-fill" style="color: white; font-size: 1.5rem;"></i>
                      Client Information
                    </h3>
                    <button type="button" class="modern-btn" onclick="showChartModal()">
                        <i class="bi bi-pie-chart-fill"></i> View Chart Insights
                    </button>
                </div>
                </div>

                <div class="p-4 pt-3">
                    <!-- Search + Filters Row -->
                    <div class="row gx-3 align-items-end mb-4">
                        <div class="col-md-6">
                            <label class="form-label">🔍 Search Company</label>
                            <div class="input-group">
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Enter company name..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
                                <asp:Button ID="btnClear" runat="server" Text="×" OnClick="btnClear_Click" CssClass="btn border-0 bg-transparent text-dark" Style="font-size: 1.2rem; padding: 0 8px;" />
                            </div>
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
        <!-- Chart Modal -->
        <div class="modal fade" id="chartModal" tabindex="-1" aria-labelledby="chartLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header text-white" style="background-color: #215387;">
                        <h5 class="modal-title" id="chartLabel">Client Status Overview</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center">
                    <div style="max-width: 350px; margin: auto;">
                        <canvas id="clientPieChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
            <div class="yellow-header">
                <div class="d-flex justify-content-between align-items-center w-100">
                    <h3 class="fw-bold mb-0">
                        <i class="bi bi-people-fill me-2" style="color: white; font-size: 1.5rem;"></i>
                        Client Information
                    </h3>
                    <button type="button" class="modern-btn" onclick="showChartModal()">
                        <i class="bi bi-pie-chart-fill me-1"></i> View Chart Insights
                    </button>
                </div>
            </div>



        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript">
            function showModal() {
                var modal = new bootstrap.Modal(document.getElementById('detailsModal'));
                modal.show();
            }
        </script>
        <!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script type="text/javascript">

    function showChartModal() {
        const active = parseInt(document.getElementById('<%= lblActive.ClientID %>').innerText);
        const expired = parseInt(document.getElementById('<%= lblExpired.ClientID %>').innerText);
        const near = parseInt(document.getElementById('<%= lblNear.ClientID %>').innerText);

        const chartModalEl = document.getElementById('chartModal');
        const chartModal = new bootstrap.Modal(chartModalEl);

        const canvas = document.getElementById('clientPieChart');
        const ctx = canvas.getContext('2d');

        canvas.classList.remove('visible');

        ctx.clearRect(0, 0, canvas.width, canvas.height);

        chartModal.show();

        chartModalEl.addEventListener('shown.bs.modal', function () {

            // Destroy previous chart instance if exists
            if (window.clientPieChartInstance) {
                window.clientPieChartInstance.destroy();
            }

            setTimeout(function () {
                canvas.classList.add("animate-in");

                window.clientPieChartInstance = new Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: ['Active', 'Expired', 'Near Expiration'],
                        datasets: [{
                            label: 'Client Status',
                            data: [active, expired, near],
                            backgroundColor: [
                                '#9ABDDC', // Active
                                '#215387', // Expired
                                '#FED16A'  // Near Expiration
                            ],
                            borderColor: ['#ffffff'],
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        animation: {
                            animateScale: true,
                            animateRotate: true,
                            duration: 1500,
                            easing: 'easeOutQuart'
                        },
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    font: {
                                        size: 13
                                    }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                        const percentage = ((context.parsed / total) * 100).toFixed(1);
                                        return `${context.label}: ${context.parsed} (${percentage}%)`;
                                    }
                                }
                            }
                        }
                    }
                });
                setTimeout(() => {
                    canvas.classList.add('visible');
                }, 100);
            }, 100);
        }, { once: true });
    }

</script>

       

    </form>
</body>
</html>
