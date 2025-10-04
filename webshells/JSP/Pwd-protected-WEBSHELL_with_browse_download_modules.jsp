<%@ page import="java.io.*, java.net.URLEncoder" %>
<%
    String correctPassword = "secret123";
    String password = request.getParameter("auth");

    if (password == null || !password.equals(correctPassword)) {
        out.println("<h2>Access Denied</h2><p>Provide the correct authentication code as a GET parameter i.e. '?auth=code'.</p>");
        return;
    }

    String pathParam = request.getParameter("path");
    String basePath = (pathParam != null && !pathParam.trim().isEmpty()) ? pathParam : ".";
    String fileToDownload = request.getParameter("file-to-download");

    if (fileToDownload != null) {
        // Handle file download
        File file = new File(basePath, fileToDownload);
        if (!file.exists() || !file.isFile()) {
            out.println("File not found.");
            return;
        }

        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment;filename=\"" + file.getName() + "\"");

        FileInputStream in = new FileInputStream(file);
        OutputStream outStream = response.getOutputStream();
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = in.read(buffer)) != -1) {
            outStream.write(buffer, 0, bytesRead);
        }
        in.close();
        outStream.close();
        return;
    }

    // Directory listing
    File folder = new File(basePath);
    File[] listOfFiles = folder.listFiles();

    // Breadcrumbs
    String[] parts = folder.getCanonicalPath().split(File.separator);
    String breadcrumb = "";
    String cumulativePath = "";
%>
<html>
<head><title>Directory Browser</title></head>
<body>
<h2>Browsing: <%= folder.getCanonicalPath() %></h2>
<p>
<%
    for (String part : parts) {
        if (!part.isEmpty()) {
            cumulativePath += File.separator + part;
            String encodedPath = URLEncoder.encode(cumulativePath, "UTF-8");
            breadcrumb += "<a href='?path=" + encodedPath + "&auth=" + correctPassword + "'>" + part + "</a> / ";
        }
    }
    out.println(breadcrumb);
%>
</p>
<%
    if (listOfFiles != null && folder.isDirectory()) {
        for (File file : listOfFiles) {
            String encodedPath = URLEncoder.encode(folder.getPath(), "UTF-8");
            String encodedFile = URLEncoder.encode(file.getName(), "UTF-8");
            if (file.isDirectory()) {
                out.println("<b>Directory:</b> <a href='?path=" + URLEncoder.encode(file.getPath(), "UTF-8") + "&auth=" + correctPassword + "'>" + file.getName() + "</a><br>");
            } else {
                out.println("File: " + file.getName() + " - <a href='?auth=" + correctPassword + "&path=" + encodedPath + "&file-to-download=" + encodedFile + "'>Download</a><br>");
            }
        }
    } else {
        out.println("Invalid directory or access denied.");
    }
%>
</body>
</html>
