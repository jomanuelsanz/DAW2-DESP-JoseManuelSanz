<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>HolaTomcatJMS</title>
</head>
<body>
    <h1>¡Hola Tomcat! Soy José Manuel Sanz (JMS)</h1>
    <p>Práctica 1 - DAW2 - Despliegue de Aplicaciones Web</p>
    <p>Servidor: <%= application.getServerInfo() %></p>
    <p>Versión de Java: <%= System.getProperty("java.version") %></p>
    <p>Fecha y hora del servidor: <%= new java.util.Date() %></p>

    <hr>
    <h2>Datos de la petición recibida por Tomcat</h2>
    <p>IP de origen que ve Tomcat (getRemoteAddr): <%= request.getRemoteAddr() %></p>
    <p>Cabecera Host: <%= request.getHeader("Host") %></p>
    <p>X-Forwarded-For: <%= request.getHeader("X-Forwarded-For") %></p>
    <p>X-Real-IP: <%= request.getHeader("X-Real-IP") %></p>
    <p>X-Forwarded-Proto: <%= request.getHeader("X-Forwarded-Proto") %></p>


</body>
</html>