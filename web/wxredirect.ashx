<%@ WebHandler Language="C#" Class="wxredirect" %>

using System;
using System.Web;
using System.Net;
using System.Text.RegularExpressions;
using Newtonsoft.Json;

public class wxredirect : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    HttpRequest Request;
    HttpResponse Response;
    protected HttpContext context;


    public void ProcessRequest(HttpContext context)
    {
        this.Request = context.Request;
        this.Response = context.Response;
        this.context = context;

        switch (Request.PathInfo)
        {
            case "/go":
                golink();
                break;

            case "/code.gif":
                code_gif();
                break;

            case "/genurl":
                genUrl();
                break;

            default:
                break;
        }
    }

    void code_gif()
    {
        Response.ContentType = "image/gif";

        var codeHelper = new Common.Helpers.VerifyCodeHelper();

        string code = null;

        var img = codeHelper.CreateImageCode(out code);       // 输出图片


        context.Session["code"] = code;

        if (img != null)
        {
            img.Save(context.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Gif);
        }

    }


    void golink()
    {
        string code = Request.QueryString["code"] ?? string.Empty;
        EchoHtml(code);
    }



    void genUrl()
    {
        string url = Request["url"];

        if (string.IsNullOrEmpty(url))
        {
            EchoJson(new
            {
                code = -1,
                data = new
                {
                    msg = "url不能为空"
                }
            });
            return;
        }


        if (!Regex.IsMatch(url, @"(mp|game)\.weixin\.qq\.com", RegexOptions.IgnoreCase))
        {

            EchoJson(new
            {
                code = -1,
                data = new
                {
                    msg = "仅支持mp.weixin.qq.com |game.weixin.qq.com 域名下的网址"
                }
            });
            return;
        }

        /*
        string code = Request["code"] ?? string.Empty;

        string scode = null;



        bool ismatch = false;

        if (context.Session["code"] != null)
        {
            scode = context.Session["code"].ToString();
        }

        if (!string.IsNullOrEmpty(scode) && !string.IsNullOrEmpty(code))
        {
            if (scode.Equals(code, StringComparison.OrdinalIgnoreCase))
            {
                ismatch = true;
            }
        }

        if (!ismatch)
        {
            EchoJson(new
            {
                code = -1,
                data = new
                {
                    msg = "验证码校验失败，请重新填写"
                }
            });

            return;
        }
        else
        {
            context.Session["code"] = null;
        }
        */



        string pk = GetUrlPK(url);

        string key = null;

        var db = Common.DB.Factory.CreateDBHelper();

        var existsData = db.GetData("select top 1 code,enddate from [url.data] where pk=@0", pk);

        if (existsData != null)
        {
            EchoJson(new
            {
                code = 0,
                data = new
                {
                    url = "http://" + Request.Url.Host + "/wxredirect.ashx/go?code=" + existsData["code"].ToString(),
                    enddate = Convert.ToDateTime(existsData["enddate"]).ToString("yyyy-MM-dd hh:mm:ss")
                }
            });
            return;
        }



        int num = 0;
        bool exists = false;
        do
        {
            key = GetShortUrl(url);
            exists = db.Exists("select top 1 1 from [url.data] where code=@0", key);
            num++;

        } while (exists && num < 5);

        if (!exists)
        {
            do
            {
                key = GetShortUrl(url + DateTime.Now.Ticks);

                exists = db.Exists("select top 1 1 from [url.data] where code=@0", key);
                num++;

            } while (exists && num < 50);
        }

        object result = null;

        if (!exists)
        {
            var nvc = new Common.DB.NVCollection();
            nvc["name"] = string.Empty;
            nvc["link"] = url;
            nvc["date"] = DateTime.Now;
            nvc["enddate"] = DateTime.Now.AddDays(1);
            nvc["code"] = key;
            nvc["pk"] = pk;

            db.ExecuteNoneQuery("insert into [url.data](name,link,date,enddate,code,pk,cou) values(@name,@link,@date,@enddate,@code,@pk,0)", nvc);

            result = new
            {
                code = 0,
                data = new
                {
                    url = "http://" + Request.Url.Host + "/wxredirect.ashx/go?code=" + key,
                    enddate = Convert.ToDateTime(nvc["enddate"]).ToString("yyyy-MM-dd hh:mm:ss")
                }
            };
        }
        else
        {
            result = new
            {
                code = -1
            };
        }

        EchoJson(result);

    }

    void EchoJson(object data)
    {

        string jsonStr = JsonConvert.SerializeObject(data);

        string callback = Request.QueryString["callback"] ?? string.Empty;


        if (!string.IsNullOrEmpty(callback))
        {
            Response.Write(callback + "(" + jsonStr + ")");
        }
        else
        {
            Response.Write(jsonStr);
        }
    }


    string GetShortUrl(string url)
    {
        var urls = ShortUrl(url);

        if (urls != null)
        {
            var rnd = new Random();

            return urls[rnd.Next(0, urls.Length)];
        }

        return null;
    }

    string[] ShortUrl(string url)
    {
        //可以自定义生成MD5加密字符传前的混合KEY
        string key = "url";
        //要使用生成URL的字符
        string[] chars = new string[]{
            "a" , "b" , "c" , "d" , "e" , "f" , "g" , "h" ,
            "i" , "j" , "k" , "l" , "m" , "n" , "o" , "p" ,
            "q" , "r" , "s" , "t" , "u" , "v" , "w" , "x" ,
            "y" , "z" , "0" , "1" , "2" , "3" , "4" , "5" ,
            "6" , "7" , "8" , "9" , "A" , "B" , "C" , "D" ,
            "E" , "F" , "G" , "H" , "I" , "J" , "K" , "L" ,
            "M" , "N" , "O" , "P" , "Q" , "R" , "S" , "T" ,
            "U" , "V" , "W" , "X" , "Y" , "Z"
        };

        //对传入网址进行MD5加密
        string hex = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(key + url, "md5");


        string[] resUrl = new string[4];
        for (int i = 0; i < 4; i++)
        {
            //把加密字符按照8位一组16进制与0x3FFFFFFF进行位与运算
            int hexint = 0x3FFFFFFF & Convert.ToInt32("0x" + hex.Substring(i * 8, 8), 16);
            string outChars = string.Empty;
            for (int j = 0; j < 6; j++)
            {
                //把得到的值与0x0000003D进行位与运算，取得字符数组chars索引
                int index = 0x0000003D & hexint;
                //把取得的字符相加
                outChars += chars[index];
                //每次循环按位右移5位
                hexint = hexint >> 5;
            }
            //把字符串存入对应索引的输出数组
            resUrl[i] = outChars;
        }
        return resUrl;
    }


    void EchoHtml(string code)
    {

        var db = Common.DB.Factory.CreateDBHelper();

        var data = db.GetData("select top 1 tickets,ticketsdate,enddate,link from [url.data] where code=@0", code);
        if (data == null)
        {

            return;
        }

        string url = data["link"] as string ?? string.Empty;

        DateTime enddate = Convert.ToDateTime(data["enddate"]);

        if (enddate < DateTime.Now)
        {
            Response.Redirect("/exp.html");
            return;
        }


        string tikets = data["tickets"] as string ?? string.Empty;
        bool needUpdate = false;
        if (data["tickets"] == null || data["tickets"] == DBNull.Value)
        {
            tikets = GetTicket(url);
            needUpdate = true;
        }
        else
        {
            if (data["ticketsdate"] != null)
            {
                var ticketsdate = Convert.ToDateTime(data["ticketsdate"]);

                if (ticketsdate < DateTime.Now.AddMinutes(-30))
                {
                    tikets = GetTicket(url);
                    needUpdate = true;
                }
            }
        }

        if (string.IsNullOrEmpty(tikets))
        {
            return;
        }

        if (needUpdate)
        {
            var nvc = new Common.DB.NVCollection();
            nvc["ticketsdate"] = DateTime.Now;
            nvc["tickets"] = tikets;
            nvc["code"] = code;
            db.ExecuteNoneQuery("update [url.data] set tickets=@tickets,ticketsdate=@ticketsdate where code=@code ", nvc);
        }

        db.ExecuteNoneQuery("update [url.data] set cou=cou+1 where code=@0", code);



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

        string lurl = url.ToLower();

        if (lurl.IndexOf("mp.weixin.qq.com") >= 0)
        {
            return GetTicketMPWexin(url);
        }
        else if (lurl.IndexOf("game.weixin.qq.com") >= 0)
        {
            return GetTicketGameWexin(url);
        }

        return null;
    }

    string GetTicketGameWexin(string url)
    {

        Uri uri = null;

        if (!Uri.TryCreate(url, UriKind.Absolute, out uri))
        {
            return null;
        }

        if (string.IsNullOrEmpty(uri.Query))
        {
            return null;
        }



        var query=  HttpUtility.ParseQueryString(uri.Query);

        string topic_id = query["topic_id"];


        if (string.IsNullOrEmpty(topic_id))
        {
            return null;
        }


        string link = "https://game.weixin.qq.com/cgi-bin/comm/openlink?noticeid=90070127&appid=wx58164a91f1821369&url=https%3a%2f%2fgame.weixin.qq.com%2fcgi-bin%2fh5%2fstatic%2fcommunity%2fclub_detail.html%3fappid%3dwx95a3a4d7c627e0xx%26topic_id%3d" + topic_id + "%26key%3d7dc869ac8a00de992f27241f3346bb9bfc948223e63523e60f3c4fb27f190e9cd44b53168bb3e8b76ab961e687a7fc698ec8f07a1c159b522eec9d3e6cc652c97a5bf34813855e27f55cad1ce0728783%26uin%3dMzMxOTMwNTgzNQ%253D%253D%26abtest_cookie%3dAwABAAoADAANAAgAZIgeANWIHgDhiB4A%252FIgeALOJHgD4iR4AGYoeAEyKHgAAAA%253D%253D%26pass_ticket%3dZv88n7fo%252Bw%252By0AlUMhzpKr7nhgDjC63IzRX4opH%252B9t8gTnA5WINVHxQ%252BEWTicx3Iwechat_redirect";

        using (var wc = new WebClient())
        {

            wc.Headers.Set(HttpRequestHeader.UserAgent, "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_2 like Mac OS X; zh-CN) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/15B202 UCBrowser/11.7.7.1031 Mobile  AliApp(TUnionSDK/0.1.20)");

            wc.Headers.Set(HttpRequestHeader.Referer, "https://m.mall.qq.com/release/?busid=mxd2&ADTAG=jcp.h5.index.dis");
            wc.Headers.Set("X-UCBrowser-UA", "dv(iPh9,2);pr(UCBrowser/11.7.7.1031);ov(11_1_2);ss(0x0);bt(UC);pm(0);bv(0);nm(0);im(0);nt(2);");
            wc.Headers.Set(HttpRequestHeader.ContentType, "application/x-www-form-urlencoded; charset=UTF-8");



            byte[] data = wc.DownloadData(link);

            string content = System.Text.Encoding.GetEncoding("utf-8").GetString(data);
            if (!string.IsNullOrEmpty(content))
            {
                var match = System.Text.RegularExpressions.Regex.Match(content, @"href\=""(?<link>.*?)#wechat", System.Text.RegularExpressions.RegexOptions.IgnoreCase);

                if (match.Success)
                {
                    return match.Groups["link"].Value;
                }
            }

        }

        return null;
    }

    string GetTicketMPWexin(string url)
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
                var match = System.Text.RegularExpressions.Regex.Match(content, @"openlink""\:""(?<link>.*?)""", System.Text.RegularExpressions.RegexOptions.IgnoreCase);

                if (match.Success)
                {
                    return match.Groups["link"].Value;
                }
            }

        }

        return null;
    }

    string GetUrlPK(string url)
    {
        string pk = GetMD5(url) + url.Length;

        return pk;
    }

    string GetMD5(string str)
    {
        byte[] b = System.Text.Encoding.Default.GetBytes(str);

        b = new System.Security.Cryptography.MD5CryptoServiceProvider().ComputeHash(b);
        string ret = "";
        for (int i = 0; i < b.Length; i++)
        {
            ret += b[i].ToString("x").PadLeft(2, '0');
        }
        return ret;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}