﻿<%@ Page Language="C#" %>

<!DOCTYPE html>

<script runat="server">
    protected void DVE_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        GV.DataBind();
    }

    protected void DVI_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        GV.DataBind();
    }

    protected void GV_SelectedIndexChanged(object sender, EventArgs e)
    {
        DVE.DataBind();
    }


</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="formMain" runat="server">
        <div>




            <table border="0" style="width: 100%">
                <tr>
                    <td style="vertical-align: top">
                        <asp:GridView ID="GV" runat="server" AutoGenerateColumns="False" DataKeyNames="id" DataSourceID="SDS" AllowPaging="True" OnSelectedIndexChanged="GV_SelectedIndexChanged" Width="960px" PageSize="50">
                            <Columns>
                                <asp:BoundField DataField="id" HeaderText="id" InsertVisible="False" ReadOnly="True" SortExpression="id" />
                                <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" />
                                <asp:BoundField DataField="link" HeaderText="link" SortExpression="link" />
                                <asp:BoundField DataField="date" HeaderText="date" SortExpression="date" />
                                <asp:BoundField DataField="enddate" HeaderText="enddate" SortExpression="enddate" />
                                <asp:BoundField DataField="code" HeaderText="code" ReadOnly="True" SortExpression="code" />
                                <asp:BoundField DataField="cou" HeaderText="cou" ReadOnly="True" SortExpression="cou" />

                                <asp:CommandField ShowSelectButton="True" />

                                <asp:TemplateField HeaderText="地址">
                                    <ItemTemplate>
                                        <a href="<%#"http://"+Request.Url.Host+ "/wxredirect.ashx/go?code="+Eval("code")%>" target="_blank">打开地址</a>
                                    </ItemTemplate>
                                </asp:TemplateField>

                            </Columns>
                        </asp:GridView>

                        <asp:SqlDataSource ID="SDS" runat="server" ConnectionString="<%$ ConnectionStrings:default %>" SelectCommand="SELECT [id], [name], [link], [date], [enddate], [code],cou FROM [url.data] ORDER BY [id] DESC"></asp:SqlDataSource>

                    </td>
                    <td style="vertical-align: top">

                        <asp:SqlDataSource ID="ESDS" runat="server" ConnectionString="<%$ ConnectionStrings:default %>"
                            SelectCommand="SELECT  * FROM [url.data] WHERE ([id] = @id)"
                            InsertCommand="insert into [url.data](name,link,date,enddate,code) values(@name,@link,getDate(),@enddate,@code)"
                            UpdateCommand="update [url.data] set name=@name,link=@link,enddate=@enddate,code=@code where id=@id"
                            DeleteCommand="delete from [url.data] where id=@id">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="GV" Name="id" PropertyName="SelectedValue" Type="Int32" />
                            </SelectParameters>
                        </asp:SqlDataSource>



                        <div style="margin-top: 10px;">
                            <!--
                            <asp:DetailsView ID="DVI" runat="server" Width="480px" AutoGenerateRows="False" DataKeyNames="id" DataSourceID="ESDS" AutoGenerateInsertButton="True" DefaultMode="Insert" OnItemInserted="DVI_ItemInserted" EnableModelValidation="True">
                                <Fields>
                                    <asp:BoundField DataField="id" HeaderText="id" InsertVisible="False" ReadOnly="True" SortExpression="id" />
                                    <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" />
                                    <asp:BoundField DataField="enddate" HeaderText="结束日期" SortExpression="seotitle" />
                                    <asp:BoundField DataField="code" HeaderText="code" SortExpression="author" />
                                    <asp:BoundField DataField="link" HeaderText="链接" SortExpression="link" />
                                </Fields>

                                <HeaderTemplate>
                                    <strong>添加</strong>
                                </HeaderTemplate>
                            </asp:DetailsView>

                                -->
                        </div>


                        <div style="margin-top: 10px;">
                            <asp:DetailsView ID="DVE" runat="server" Width="480px" AutoGenerateRows="False" DataKeyNames="id" DataSourceID="ESDS" AutoGenerateDeleteButton="True" AutoGenerateEditButton="True" DefaultMode="Edit" OnItemUpdated="DVE_ItemUpdated">
                                <Fields>
                                    <asp:BoundField DataField="id" HeaderText="id" InsertVisible="False" ReadOnly="True" SortExpression="id" />
                                    <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" />
                                    <asp:BoundField DataField="enddate" HeaderText="结束日期" SortExpression="seotitle" />
                                    <asp:BoundField DataField="code" HeaderText="code" SortExpression="author" />
                                    <asp:BoundField DataField="link" HeaderText="链接" SortExpression="link" />
                                </Fields>
                                <HeaderTemplate>
                                    <strong>修改</strong>
                                </HeaderTemplate>
                            </asp:DetailsView>

                        </div>


                    </td>
                </tr>
            </table>











        </div>
    </form>
</body>
</html>
