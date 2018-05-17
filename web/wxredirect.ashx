<%@ WebHandler Language="C#" Class="wxredirect" %>

using System;
using System.Web;
using System.Net;
using System.Text.RegularExpressions;

public class wxredirect : IHttpHandler
{

    HttpRequest Request;
    HttpResponse Response;
    public void ProcessRequest(HttpContext context)
    {
        this.Request = context.Request;
        this.Response = context.Response;

        string key = (Request.PathInfo ?? string.Empty).Replace("/", string.Empty);






    }




    void EchoHtml(string url)
    {

        string tikets = GetTicket(url);

        Response.ContentType = "text/html;charset=utf-8";
        Response.Write(@"<!DOCTYPE html>");
        Response.Write(@"<html>");
        Response.Write(@"<head>");
        Response.Write(@"<meta charset=""utf-8"">");
        Response.Write(@"<meta name=""viewport"" content=""width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=0"">");
        Response.Write(@"<meta name=""apple-mobile-web-app-capable"" content=""yes"">");
        Response.Write(@"<meta name=""apple-mobile-web-app-status-bar-style"" content=""black"">");
        Response.Write(@"<meta name=""format-detection"" content=""telephone=no"">");
        Response.Write(@"<title>跳转中</title>");
        Response.Write(@"</head>");
        Response.Write(@"<body>");
        Response.Write(@"<div style=""text-align: center;font-size: 18px;margin: 100px 0 30px 0;"">正在前往微信客户端</div>");
        Response.Write(@"<a href=""javascript:document.location.reload();"" style=""width: 90%;background: #1AAD19;text-align: center;color: #fff;margin: 0 auto;box-sizing: border-box;font-size: 18px;line-height: 2.55555556;border-radius: 5px;display: block;text-decoration: none;"">重新跳转</a>");

        Response.Write(@"<script>if(/baiduboxapp/i.test(navigator.userAgent)){window.location.replace(""bdbox://utils?action=sendIntent&minver=7.4&params=%7B%22intent%22%3A%22" + tikets + @"%23Intent%3Bend%22%7D"");}else{window.location.replace(""" + tikets + @""");} </script>");
        Response.Write(@"</body>");
        Response.Write(@"</html>");
    }



    string GetTicket(string url)
    {
        url = url.Replace("http://", string.Empty);
        url = url.Replace("https://", string.Empty);


        string link = "http://wq.jd.com/mjgj/link/GetOpenLink?rurl=http://wqs.jd.com/ad/jump.shtml?curl=http://h5.m.jd.com/active/openappextend/switchpage.html?murl=//e-m.jd.com/refresh.html?refreshLink%3D%2F%2F" + HttpUtility.UrlEncode(url) + "&openlink=1";

        using (var wc = new WebClient())
        {
            wc.Headers.Set(HttpRequestHeader.UserAgent, "Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_2 like Mac OS X; zh-CN) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/15B202 UCBrowser/11.7.7.1031 Mobile  AliApp(TUnionSDK/0.1.20)");

            wc.Headers.Set(HttpRequestHeader.Referer, "https://m.mall.qq.com/release/?busid=mxd2&ADTAG=jcp.h5.index.dis");
            wc.Headers.Set("X-UCBrowser-UA", "dv(iPh9,2);pr(UCBrowser/11.7.7.1031);ov(11_1_2);ss(0x0);bt(UC);pm(0);bv(0);nm(0);im(0);nt(2);");
            wc.Headers.Set(HttpRequestHeader.ContentType, "application/x-www-form-urlencoded; charset=UTF-8");



            byte[] data = wc.DownloadData(link);

            string content = System.Text.Encoding.GetEncoding("utf-8").GetString(data);
            if (!string.IsNullOrEmpty(content))
            {
                var match = System.Text.RegularExpressions.Regex.Match(content, @"openlink"":""(?<link>.*?)""", System.Text.RegularExpressions.RegexOptions.IgnoreCase);

                if (match.Success)
                {
                    Response.Write(match.Groups["link"].Value);
                }
            }

        }

        return null;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}